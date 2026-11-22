"""Copy reviewed public assets after checking the complete Tola output tree."""
import hashlib
from pathlib import Path
import shutil
import sys

source, destination = map(Path, sys.argv[1:])
manifest = Path(__file__).with_name("public-assets.sha256")
approved = {}
for line in manifest.read_text().splitlines():
    digest, name = line.split(maxsplit=1)
    approved[name] = digest

files = {}
for path in source.rglob("*"):
    if path.is_symlink():
        sys.exit("Unexpected symlink in review build.")
    if path.is_file():
        files[path.relative_to(source).as_posix()] = path
if files.keys() != approved.keys() | {"index.html"}:
    sys.exit("Review output files changed. Inspect the build before publishing.")
for name, digest in approved.items():
    if hashlib.sha256(files[name].read_bytes()).hexdigest() != digest:
        sys.exit(f"Public asset changed. Review its contents before publishing: {name}")

for name in approved:
    target = destination / name.replace(".tola/", "styles/", 1)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(files[name], target)
