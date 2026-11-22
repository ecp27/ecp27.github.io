# European Coaching Program website

This is a static website built with [Tola](https://github.com/tola-rs/tola-ssg/),
a Typst-based static site generator. Tola handles routing, site metadata, asset
copying, validation, minification, the sitemap, and the development server.

## Project structure

- `content/index.typ` contains the home-page copy and structured content.
- `content/legal.typ` contains the combined imprint and privacy notice;
  `content/imprint.typ` and `content/privacy.typ` preserve the former URLs.
- `templates/layout.typ` defines the Tola page metadata and shared HTML shell.
- `components/site.typ` contains the reusable content components.
- `assets/css/site.css` contains the visual design.
- `assets/images/` contains portraits and organization logos.
- `tola.toml` contains build, asset, SEO, and development-server settings.

The generated `public/` directory is ignored by Git. Do not edit it by hand.

## Install Tola

This project is tested with Tola 0.7.1. Install it from the
[Tola releases page](https://github.com/tola-rs/tola-ssg/releases/tag/v0.7.1)
or with Cargo:

```sh
cargo install --locked tola --version 0.7.1
```

Confirm the installation with:

```sh
tola --version
```

## Preview locally

From the repository root, run:

```sh
tola serve
```

The development server watches the content, template, and asset directories and
serves the site at <http://127.0.0.1:5277/>.

## Validate and build

Check internal links and asset references:

```sh
tola validate
```

Create a clean production build:

```sh
tola build --clean
```

The generated site is written to `public/`.

## Deployment

The GitHub Actions workflow downloads the pinned Tola 0.7.1 binary, verifies its
checksum, validates the source, builds the site, and deploys `public/` to GitHub
Pages after a push to `main`. In the repository settings, configure **Pages** to
use **GitHub Actions** as its source.

### Application review directory

Run `./scripts/build-review.sh` locally with Tola, Python 3 and npm installed.
It rebuilds `ecp-applications/`, checks every generated file against the
reviewed public asset list, and uses the shared passphrase. To reuse your
passphrase, save it as one line of plain text in `.review-password` at the
repository root. Spaces and shell punctuation are literal. This file is ignored
by Git and stays outside the site build. Without the file, StatiCrypt uses its
usual environment variable or interactive prompt. Commit the
resulting `applications/` to publish the viewer under `/applications/`.
The root Tola preview serves the same path locally.
The optional “Remember me for two months” checkbox lasts 60 days. Keep the
local `ecp-applications/.staticrypt.json` to preserve remembered access across
rebuilds with the same passphrase.

The generated index contains the application records. Only the encrypted
version is copied to the review site. If the asset check fails, inspect the
new output for applicant data before updating `scripts/review/public-assets.sha256`.
