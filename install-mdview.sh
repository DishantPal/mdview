#!/usr/bin/env bash
# Installs mdview and makes it the double-click handler for .md files.
set -euo pipefail
cd "$(dirname "$0")"

# Fast C-based converter (pandoc also works as a fallback)
sudo dnf install -y cmark-gfm 2>/dev/null || sudo dnf install -y pandoc

mkdir -p ~/.local/bin ~/.local/share/applications
install -m 755 mdview ~/.local/bin/mdview

# Local copies of the page libraries: offline-friendly and instant to load
vendor="${XDG_DATA_HOME:-$HOME/.local/share}/mdview/vendor"
mkdir -p "$vendor"
dl() { curl -fsSL "$2" -o "$vendor/$1.tmp" && mv "$vendor/$1.tmp" "$vendor/$1" || { rm -f "$vendor/$1.tmp"; echo "warn: could not download $1 (CDN will be used)"; }; }
dl mermaid.min.js      https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js
dl highlight.min.js    https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js
dl github.min.css      https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css
dl github-dark.min.css https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css

cat > ~/.local/share/applications/mdview.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Markdown Viewer
Comment=View Markdown as a styled page
Exec=$HOME/.local/bin/mdview %f
Icon=text-markdown
MimeType=text/markdown;text/x-markdown;
NoDisplay=false
Terminal=false
Categories=Utility;Viewer;
EOF

update-desktop-database ~/.local/share/applications 2>/dev/null || true
xdg-mime default mdview.desktop text/markdown
xdg-mime default mdview.desktop text/x-markdown
echo "Done. Double-click any .md file. Default now: $(xdg-mime query default text/markdown)"
