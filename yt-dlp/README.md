# yt-dlp

Setup docs for the [yt-dlp](https://github.com/yt-dlp/yt-dlp) CLI — a
command-line media downloader (YouTube and hundreds of other sites). This
directory has no application code of its own; it just documents how to
install and use the `yt-dlp` command locally.

## Requirements

- Python 3.9+
- [`pipx`](https://pipx.pypa.io/) (recommended) or `pip3`
- [`ffmpeg`](https://ffmpeg.org/) — optional but recommended; yt-dlp shells
  out to it to merge separate video/audio streams and to extract audio-only
  formats. Install via your OS package manager, e.g. `apt install ffmpeg` /
  `brew install ffmpeg`.

## Install

```bash
cd yt-dlp
./install.sh          # pipx install yt-dlp (falls back to pip3 install --user)
```

Verify:

```bash
yt-dlp --version
```

## Updating / uninstalling

```bash
yt-dlp -U                      # self-update in place
pipx upgrade yt-dlp            # if installed via pipx
pipx uninstall yt-dlp          # remove
```

## Basic usage

```bash
# Download the best available quality to the current directory
yt-dlp 'https://www.youtube.com/watch?v=...'

# Download into this directory's (git-ignored) downloads/ folder
yt-dlp -o 'downloads/%(title)s.%(ext)s' 'https://www.youtube.com/watch?v=...'

# Audio only, extracted to mp3 (requires ffmpeg)
yt-dlp -x --audio-format mp3 'https://www.youtube.com/watch?v=...'

# List available formats without downloading
yt-dlp -F 'https://www.youtube.com/watch?v=...'
```

`downloads/` is git-ignored (only its directory structure is tracked via
`.gitkeep`) — it's a scratch spot for local output, not something to commit.

Full flag reference: `yt-dlp --help` or the
[upstream README](https://github.com/yt-dlp/yt-dlp#readme).

## Sandbox caveat

Downloading requires network egress to the relevant video-hosting domains
(e.g. `youtube.com`, `googlevideo.com`, or whatever site you're pulling
from). In the Claude Code cloud sandbox, make sure the sandbox's egress
policy allows those domains before running `yt-dlp`.
