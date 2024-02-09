#!/usr/bin/env bash

echo "Starting the update process..."

# Cleanup function to remove temporary files
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f releases.json
}

# Set trap to execute the cleanup function on script exit
trap cleanup EXIT

# Check for necessary commands
if ! command -v curl &> /dev/null || ! command -v jq &> /dev/null || ! command -v nix-prefetch-url &> /dev/null; then
    echo "Error: Required command(s) not found. Ensure curl, jq, and nix are installed."
    exit 1
fi

# Fetching latest releases information
echo "Fetching the latest releases information..."
if ! curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/apple/pkl/releases > releases.json; then
    echo "Error: Failed to fetch releases information from GitHub."
    exit 1
fi

# Check for update necessity
echo "Checking if an update is needed..."
if ! needs_update=$(jq -s '(.[0][0] | .published_at | fromdateiso8601) > (.[1] | .published_at | fromdateiso8601)' releases.json current.json) ; then
    echo "Error: Failed to compare release dates or parse JSON."
    exit 1
fi

if [ "$needs_update" == "false" ]; then
    echo "No update required."
    exit 0
else
    echo "Update required. Processing..."
    hashes=""
    for row in $(jq -c '.[0].assets[] | select(.name | test("^pkl-(linux-amd64|linux-aarch64|macos-aarch64|macos-amd64)$")) | {name, browser_download_url}' releases.json); do
        echo "Processing asset: $(echo "$row" | jq -r '.name')"
        if ! hash=$(nix-prefetch-url "$(echo "$row" | jq -r '.browser_download_url')" 2>/dev/null); then
            echo "Error: Failed to prefetch URL for $(echo "$row" | jq -r '.name'). Aborting..."
            exit 1
        fi
        if ! hash_json=$(echo "$row" | jq --arg hash "$hash" '{(.name | sub("^pkl-"; "")): $hash}'); then
            echo "Error: Failed to generate hash JSON. Aborting..."
            exit 1
        fi
        if ! hashes=$(echo "$hashes" "$hash_json" | jq -s 'add'); then
            echo "Error: Failed to aggregate hashes. Aborting..."
            exit 1
        fi
    done
    echo "Updating current.json..."
    if echo "$hashes" | jq -s '(.[0][0] | {tag_name, published_at}) * {platforms: .[1]}' releases.json - > current.json; then
        echo "Update successful."
    else
        echo "Error: Failed to update current.json."
        exit 1
    fi
fi
