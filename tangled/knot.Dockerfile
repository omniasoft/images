# Tangled knot (knot2). A copy of upstream's knot2/Containerfile as fixed on master: at v1.20.0 it copies a
# missing knot2/lexicons, pins an amd64-only base and passes the config path without --config. Once a tag
# ships the fix, build-tangled.yaml can use source/knot2/Containerfile instead and this file goes away.
FROM rust:1.100-slim-trixie AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates build-essential cmake perl pkg-config clang mold \
    && rm -rf /var/lib/apt/lists/*
ENV RUSTFLAGS="-C linker=clang -C link-arg=-fuse-ld=mold"

WORKDIR /src
COPY . .
RUN cargo build --release --locked --package knot-server --package knot-migrate

FROM gcr.io/distroless/cc-debian13:latest@sha256:809d04afa1be033c441f76bb0051878c342fb76d0ea236bc6dc94b655fa0fbd6

COPY --from=build /src/target/release/knot-server /src/target/release/knot-migrate /usr/local/bin/

# 5555 HTTP/XRPC (health: /xrpc/_health), 2222 SSH
EXPOSE 5555 2222
ENTRYPOINT ["/usr/local/bin/knot-server"]
CMD ["--config", "/etc/knot/config.toml"]
