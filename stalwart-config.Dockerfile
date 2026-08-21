# We have this FROM here so that our automatic version extractor uses stalwart-cli version information
FROM ghcr.io/stalwartlabs/cli:1.0.12 AS stalwart-cli

FROM debian:13.6-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=stalwart-cli /usr/local/bin/stalwart-cli /usr/bin/stalwart-cli
COPY --from=mikefarah/yq:4.53.6 /usr/bin/yq /usr/bin/yq

RUN stalwart-cli --version && yq --version # Smoke test to ensure our image is solid

COPY --chmod=0755 <<'EOT' /usr/local/bin/entrypoint.sh
#!/bin/sh
set -eu

deadline=$(( $(date +%s) + ${READY_TIMEOUT:=300} ))
until curl -fsS --max-time 3 -o /dev/null "${STALWART_URL}/healthz/ready"; do
  [ "$(date +%s)" -lt "$deadline" ] || { echo "timed out waiting for readiness" >&2; exit 1; }
  echo "waiting for Stalwart readiness..." >&2
  sleep 2
done

# NOTE: We are using cat here to ensure the proper order of the files is used for inter file anchors.
cat /config/*.yaml | yq --yaml-fix-merge-anchor-to-spec=true -o=json -I=0 '.[]' > /tmp/plan.ndjson
stalwart-cli apply --file /tmp/plan.ndjson
EOT

ENV HOME=/tmp \
    XDG_CACHE_HOME=/tmp/.cache

USER 65532:65532
WORKDIR /config

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
