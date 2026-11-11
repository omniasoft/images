# Tangled spindle. Upstream only packages it with Nix (nix/pkgs/spindle.nix): a cgo Go binary linking SQLite
# and hydrant's Rust staticlib (nix/pkgs/hydrant-ffi.nix). This follows that recipe.
FROM golang:1.27-trixie AS modules

ENV GOTOOLCHAIN=local
WORKDIR /src
COPY go.mod go.sum ./
# hydrant's Go module is its whole repository, so the staticlib is built from exactly the commit go.mod pins
RUN go mod download \
    && cp -r "$(go list -m -f '{{.Dir}}' tangled.org/ptr.pet/hydrant)" /hydrant \
    && chmod -R u+w /hydrant

FROM rust:1.99-slim-trixie AS hydrant

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential clang cmake mold perl pkg-config \
    && rm -rf /var/lib/apt/lists/*
# Overrides hydrant's .cargo/config.toml, which wants the "wild" linker on x86_64
ENV RUSTFLAGS="-C linker=clang -C link-arg=-fuse-ld=mold"

WORKDIR /hydrant
COPY --from=modules /hydrant ./
# Its rust-toolchain.toml floats on "stable"; use this image's toolchain instead
RUN rm rust-toolchain.toml \
    && cargo build --release --locked --package hydrant-ffi

FROM modules AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=hydrant /hydrant/target/release/libhydrant_ffi.a /usr/local/lib/
COPY . .
RUN CGO_ENABLED=1 CGO_LDFLAGS="-L/usr/local/lib" \
    go build -trimpath -tags libsqlite3 -ldflags="-s -w" -o /out/spindle ./cmd/spindle

# Forky (testing), not trixie: spindle refuses git older than 2.49 and trixie ships 2.47 (no backport).
# Not Ubuntu either: its archive does not resolve from buildkit on GitHub's runners, Debian's does.
FROM debian:forky-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/* \
    && install -d -o 1000 -g 1000 /data

COPY --from=build /out/spindle /usr/local/bin/spindle

# Database, repos and hydrant default to paths relative to the working directory; only logs do not
ENV SPINDLE_SERVER_LOG_DIR=/data/logs \
    HOME=/data

# Unprivileged uid 1000 (no passwd entry needed). 6555 HTTP (health: /_health)
USER 1000:1000
WORKDIR /data
EXPOSE 6555
ENTRYPOINT ["/usr/local/bin/spindle"]
