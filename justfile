# Files OpenAI's plugin directory reads: the portable plugin at the ZIP root.
package_files := "plugin.json mcp.json skills assets LICENSE README.md"

# Validate the plugin: Claude's directory checks plus the rules the manifests must keep in sync.
validate:
    #!/usr/bin/env bash
    set -euo pipefail
    # Validate a copy holding only the files git knows (no .DS_Store and other local files the directory rejects).
    copy=$(mktemp -d)
    trap 'rm -rf "$copy"' EXIT
    git ls-files -z --cached --others --exclude-standard | while IFS= read -r -d '' f; do
        [ -e "$f" ] && rsync -R "$f" "$copy/"
    done
    claude plugin validate "$copy" --strict --profile directory
    versions=$(jq -r .version plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json | sort -u)
    if [ "$(echo "$versions" | wc -l)" -ne 1 ]; then
        echo "Manifest versions differ; bump all three together:" >&2
        jq -r '"\(input_filename): \(.version)"' plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json >&2
        exit 1
    fi
    if ! diff <(jq -S '.extensions["com.openai"].interface' plugin.json) <(jq -S .interface .codex-plugin/plugin.json) >&2; then
        echo "The OpenAI interface in plugin.json and .codex-plugin/plugin.json differs (< plugin.json, > .codex-plugin)." >&2
        exit 1
    fi
    echo "Plugin $versions is valid"

# Build the ZIP for OpenAI's plugin submission portal from the committed files.
package-openai: validate
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -n "$(git status --porcelain -- {{package_files}})" ]; then
        echo "Uncommitted changes in the packaged files; commit them first:" >&2
        git status --short -- {{package_files}} >&2
        exit 1
    fi
    version=$(jq -r .version plugin.json)
    mkdir -p dist
    out="dist/snipd-openai-plugin-${version}.zip"
    git archive --format=zip -o "$out" HEAD {{package_files}}
    echo "Built $out from $(git rev-parse --short HEAD)"
