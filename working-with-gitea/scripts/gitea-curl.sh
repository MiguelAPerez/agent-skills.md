#!/usr/bin/env bash
# Resolves Gitea credentials from the Claude Desktop or Cursor MCP config,
# then delegates to openstash curl.
#
# Usage: gitea-curl.sh --operation <id> [--param key=value ...]
# All flags are passed through to openstash curl.

set -euo pipefail

_find_creds() {
  for _cfg in \
    "$HOME/Library/Application Support/Claude/claude_desktop_config.json" \
    "$HOME/.cursor/mcp.json"; do
    if [[ -f "$_cfg" ]]; then
      local _host _token
      _host=$(jq -r '.mcpServers.gitea.env.GITEA_HOST // empty' "$_cfg" 2>/dev/null)
      _token=$(jq -r '.mcpServers.gitea.env.GITEA_ACCESS_TOKEN // empty' "$_cfg" 2>/dev/null)
      if [[ -n "$_host" && -n "$_token" ]]; then
        echo "$_host $_token"
        return
      fi
    fi
  done
}

read -r HOST TOKEN <<< "$(_find_creds)"

if [[ -z "${HOST:-}" || -z "${TOKEN:-}" ]]; then
  echo "error: configure the 'gitea' MCP server in Claude or Cursor" >&2
  exit 1
fi

exec openstash curl gitea --host "$HOST" --token "$TOKEN" "$@"
