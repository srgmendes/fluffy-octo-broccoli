# Stirling-PDF

Self-hosted [Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) — a
locally hosted, web-based PDF toolkit (merge, split, convert, OCR, sign, compress,
and 50+ other operations). This directory contains a Docker Compose setup that runs
the official prebuilt image, so no build from source is required.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/) v2 (`docker compose`)

## Quick start

Login is **enabled** by default. Set your admin credentials first:

```bash
cp .env.example .env      # then edit .env and set a real password
docker compose up -d
```

Then open <http://localhost:8080> and sign in with the credentials from your
`.env` (defaults to `admin` / `stirling` if you skip the `.env` step — change it
immediately). See [Authentication](#authentication) below to customize or disable
login.

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
| `docker-compose.yml` | Service definition pinned to `stirlingtools/stirling-pdf:2.14.2`.   |
| `.env.example`       | Template for admin credentials — copy to `.env` (git-ignored).       |
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
| `DISABLE_ADDITIONAL_FEATURES` | `false`        | Must be `false` for the login/security module to work. |
| `DOCKER_ENABLE_SECURITY`      | `true`         | Enables the security module in the Docker image.       |
| `SECURITY_ENABLELOGIN`        | `true`         | Require login (see [Authentication](#authentication)). |
| `SYSTEM_DEFAULTLOCALE`        | `en-US`        | Default UI language.                                  |
| `SYSTEM_MAXFILESIZE`          | `100`          | Max upload size in MB.                                 |
| `UI_APPNAME`                  | `Stirling-PDF` | Application name shown in the UI.                      |

The full list of options lives in the
[Stirling-PDF documentation](https://docs.stirlingpdf.com).

### Adding OCR languages

Drop the relevant `*.traineddata` files into `data/tessdata/`. They are downloadable
from the [tessdata repository](https://github.com/tesseract-ocr/tessdata). English
(`eng`) ships with the image.

## Authentication

Login is enabled out of the box via these variables in `docker-compose.yml`:

- `DISABLE_ADDITIONAL_FEATURES: "false"` and `DOCKER_ENABLE_SECURITY: "true"` turn on
  the security module.
- `SECURITY_ENABLELOGIN: "true"` requires users to sign in.
- `SECURITY_INITIALLOGIN_USERNAME` / `SECURITY_INITIALLOGIN_PASSWORD` seed the first
  admin account. They read from your `.env` file (`STIRLING_ADMIN_USERNAME` /
  `STIRLING_ADMIN_PASSWORD`), falling back to `admin` / `stirling`.
- `SECURITY_LOGINATTEMPTCOUNT: "5"` locks an account after 5 failed attempts;
  `SECURITY_LOGINRESETTIMEMINUTES: "120"` clears the lock after 2 hours.

### Setting your admin credentials

```bash
cp .env.example .env
# edit .env — set STIRLING_ADMIN_USERNAME and a strong STIRLING_ADMIN_PASSWORD
docker compose up -d
```

> **Important:** the initial credentials are applied only on the *first* startup,
> when the user database is created. To change them later, log in and update the
> account from the app's settings (changing `.env` afterward has no effect). If you
> already started the container once with the defaults, either change the password
> in-app or wipe the persisted user data and recreate.

Add more users, roles, and API keys from the admin **Settings → User Management**
screen once logged in.

### Disabling login

If you'd rather run without authentication, set `SECURITY_ENABLELOGIN: "false"` in
`docker-compose.yml` and run `docker compose up -d`.

## Notes

- This is pinned to `stirlingtools/stirling-pdf:2.14.2` for reproducible deployments.
  To upgrade, bump the tag in `docker-compose.yml` to a newer
  [release](https://github.com/Stirling-Tools/Stirling-PDF/releases), then run
  `docker compose pull && docker compose up -d`.
- Stirling-PDF processes files locally inside the container; nothing is sent to an
  external service.
