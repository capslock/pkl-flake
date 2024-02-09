#!/usr/bin/env bash

curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/apple/pkl/releases > releases.json
jq -se '(.[0][0] | .published_at | fromdateiso8601) > (.[1] | .published_at | fromdateiso8601)' releases.json current.json > /dev/null
needs_update=$?

if [ $needs_update ]; then
    hashes=""
    for row in $(jq -c '.[0].assets[] | select(.name | test("^pkl-(linux-amd64|linux-aarch64|macos-aarch64|macos-amd64)$")) | {name, browser_download_url}' releases.json); do
        hash=$(nix-prefetch-url $(echo $row | jq -r '.browser_download_url') 2>/dev/null)
        hash_json=$(echo $row | jq '{(.name | sub("^pkl-"; "")): $hash}' --arg hash $hash)
        hashes=$(echo $hashes $hash_json | jq -s 'add')
    done
    echo $hashes | jq -s '(.[0][0] | {tag_name, published_at}) * {platforms: .[1]}' releases.json - > current.json
fi