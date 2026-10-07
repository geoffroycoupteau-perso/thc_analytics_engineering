#!/usr/bin/env bash
# Usage: source activate.sh
# Loads local settings from .env (not committed), then sets dbt defaults.
_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [ -f "$_dir/.env" ]; then
  set -a
  source "$_dir/.env"
  set +a
fi

export DBT_PROFILES_DIR="$_dir"
export DBT_PROJECT="${DBT_PROJECT:?Set DBT_PROJECT in .env or your shell}"
export DBT_DATASET="${DBT_DATASET:-sales_recruitment}"
export DBT_LOCATION="${DBT_LOCATION:-EU}"
export DBT_AUTH_METHOD="${DBT_AUTH_METHOD:-oauth}"

if [ "$DBT_AUTH_METHOD" = "service-account" ]; then
  export DBT_KEYFILE="${DBT_KEYFILE:?Set DBT_KEYFILE (path to the key, outside the repo)}"
fi

echo "dbt env ready: ${DBT_PROJECT}.${DBT_DATASET} (${DBT_AUTH_METHOD})"
unset _dir
