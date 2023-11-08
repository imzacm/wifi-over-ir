#! /usr/bin/env bash
set -euo pipefail

if ! command -v realpath &> /dev/null; then
  export alias realpath="readlink -f"
fi
script_source=$([[ -z "$BASH_SOURCE" ]] && echo "$0" || echo "$BASH_SOURCE")
script_file=$(realpath "${script_source}")
script_dir=$(dirname -- "${script_file}")

if ! command -v deno &> /dev/null; then
    curl -fsSL https://deno.land/x/install/install.sh | sh
fi

deno run --allow-read="${script_dir}/build" --allow-net https://deno.land/std/http/file_server.ts "${script_dir}/build"
