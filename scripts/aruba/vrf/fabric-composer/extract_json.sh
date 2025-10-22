#!/bin/bash

extract_json() {
  local json_data
  json_data=$1

  local json_key
  json_key=$2

  local json_cleaned
  json_cleaned=$(echo "$json_data" | sed "s/^'//;s/'$//")

  local return_value
  return_value=$(echo "$json_cleaned" | jq -r --arg key "$json_key" '.[$key]')

  if [ -z "$return_value" ]; then
    echo -e "A chave [$json_key] não foi encontrada em: \n[$json_data]\n" >&2
    exit 1
  fi

  echo "$return_value"
}
