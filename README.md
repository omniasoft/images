# Images

Container images used for Omniasoft. Most are a thin layer on top of an upstream image; others are built from a
project that has some limitations. GitHub Actions builds every image for `amd64` and `arm64` and pushes it to
`ghcr.io/omniasoft/images/<image>`, tagged after the version of the software it contains.

| Image             | Description                                                                                                                                  |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `php`             | PHP-FPM (5, 7 and 8) with common extensions, `wp-cli` and `msmtp`                                                                            |
| `frankenphp`      | FrankenPHP app server, unprivileged and without capabilities                                                                                 |
| `nginx`           | Unprivileged nginx normalized to `www-data` and `/var/www/html`                                                                              |
| `stalwart-config` | Applies YAML configurations to a Stalwart mail server running in K8s                                                                         |
| `tranquil-pds`    | Mirrored from [Tangled Tranquil.farm](https://tangled.org/tranquil.farm/tranquil-pds) with versions based on Git tags and multi-arch support |

## Staying up to date

Renovate runs nightly, bumps the pinned versions in the Dockerfiles and workflows and automerges them into `main`. A
push to `main` only rebuilds the images that actually changed.

Major upgrades of images are disabled and done manually, as those usually need more than a version bump. Images built
from an external source do follow majors, because every upstream release gets its own immutable tag, so consumers
decide for themselves when to move.
