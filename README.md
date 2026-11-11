# Images

Container images used for Omniasoft. Most are a thin layer on top of an upstream image; others are built from a
project that has some limitations. GitHub Actions builds every image for `amd64` and `arm64` and pushes it to
`ghcr.io/omniasoft/images/<image>`, tagged after the version of the software it contains.

| Image             | Description                                                                                                           |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| `php`             | PHP-FPM 8 with common extensions, `wp-cli` and `msmtp`                                                                |
| `frankenphp`      | FrankenPHP app server, unprivileged and without capabilities                                                          |
| `nginx`           | Unprivileged nginx normalized to `www-data` and `/var/www/html`                                                       |
| `stalwart-config` | Applies YAML configurations to a Stalwart mail server running in K8s                                                  |
| `tranquil-pds`    | [Tranquil PDS](https://tangled.org/tranquil.farm/tranquil-pds) built from its release tags with upstream's Dockerfile |
| `tangled-knot`    | [Tangled](https://tangled.org/tangled.org/core) knot (knot2) Git server with built-in SSH                             |
| `tangled-spindle` | [Tangled](https://tangled.org/tangled.org/core) spindle CI runner                                                     |

## External images

Software we package but do not write is built from an upstream Git tag (`source-ref` in `build-<upstream>.yaml`),
which Renovate bumps. The build uses either upstream's Dockerfile (`source/Dockerfile`) or our own, in a directory
named after the upstream (e.g. `tangled/`); knot and spindle share one tag and are bumped together. We never pull
upstream's prebuilt images, so each architecture is really built for, natively on its own runner. Build check
warnings fail the build, so a single-architecture base image cannot slip into the other architecture.

## Staying up to date

Renovate runs nightly, bumps the pinned versions in the Dockerfiles and workflows and automerges them into `main`. A
push to `main` only rebuilds the images that actually changed.

Major upgrades of images are disabled and done manually, as those usually need more than a version bump. Images built
from an external source do follow majors, because every upstream release gets its own immutable tag, so consumers
decide for themselves when to move.
