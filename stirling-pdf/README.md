# Stirling-PDF

Self-hosted [Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) — a
locally hosted, web-based PDF toolkit (merge, split, convert, OCR, sign, compress,
and 50+ other operations). This directory contains a Docker Compose setup that runs
the official prebuilt image, so no build from source is required.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/) v2 (`docker compose`)

## Quick start

From this directory:

```bash
docker compose up -d
```

Then open <http://localhost:8080>.

To view logs, stop, or update:

```bash
docker compose logs -f        # follow logs
docker compose down           # stop and remove the container
docker compose pull           # fetch the latest image
docker compose up -d          # recreate with the new image
```

## What's here

| Path                 | Purpose                                                              |
| -------------------- | ------------------------------------------------------------------- |
| `docker-compose.yml` | Service definition using `stirlingtools/stirling-pdf:latest`.       |
| `data/tessdata`      | Tesseract OCR language files (`*.traineddata`). Mounted read/write. |
| `data/configs`       | App configuration (`settings.yml`, `custom_settings.yml`).          |
| `data/customFiles`   | Custom UI / branding assets.                                        |
| `data/logs`          | Persisted application logs.                                         |
| `data/pipeline`      | Pipeline definitions for automated PDF workflows.                   |

The `data/` contents are git-ignored (except the directory structure) since they are
runtime state.

## Configuration

Settings are passed as environment variables in `docker-compose.yml`. The most useful:

| Variable                      | Default        | Description                                            |
| ----------------------------- | -------------- | ----------------------------------------------------- |
| `DISABLE_ADDITIONAL_FEATURES` | `true`         | Disable features that require a Pro license.          |
| `SECURITY_ENABLELOGIN`        | `false`        | Require login (see "Enabling login" below).           |
| `SYSTEM_DEFAULTLOCALE`        | `en-US`        | Default UI language.                                  |
| `SYSTEM_MAXFILESIZE`          | `100`          | Max upload size in MB.                                 |
| `UI_APPNAME`                  | `Stirling-PDF` | Application name shown in the UI.                      |

The full list of options lives in the
[Stirling-PDF documentation](https://docs.stirlingpdf.com).

### Adding OCR languages

Drop the relevant `*.traineddata` files into `data/tessdata/`. They are downloadable
from the [tessdata repository](https://github.com/tesseract-ocr/tessdata). English
(`eng`) ships with the image.

### Enabling login

1. Set `SECURITY_ENABLELOGIN: "true"` in `docker-compose.yml`.
2. Recreate the container: `docker compose up -d`.
3. Log in with the default credentials (`admin` / `stirling`) and change the password
   immediately from the account settings.

## Notes

- This runs the `:latest` tag. For reproducible deployments, pin a specific version
  tag (e.g. `stirlingtools/stirling-pdf:1.0.0`) instead.
- Stirling-PDF processes files locally inside the container; nothing is sent to an
  external service.
