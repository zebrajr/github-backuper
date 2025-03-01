#!/bin/bash

# GitHub Repository Manager with Post-Archiving
# Requires: curl, jq, git, tar

# Usage:
# 1. Set your GitHub API token as an environment variable:
#    export GITHUB_API_TOKEN="your_github_api_token"
#
#   Optionally you can set the GITHUB_API_TOKEN in a "config.txt" file
#
# 2. Run the script: ./github-repos-manager.sh

source config.txt

# Check for required dependencies
for cmd in curl jq git tar; do
    command -v $cmd >/dev/null 2>&1 || { echo "Error: $cmd is required but not installed."; exit 1; }
done

# Verify API token is set
if [ -z "$GITHUB_API_TOKEN" ]; then
    echo "Error: GITHUB_API_TOKEN environment variable is not set."
    exit 1
fi

# Create category directories directly in current location
mkdir -p {private,public,forks}

# Pagination variables
page=1
per_page=100

# Temporary array to track repositories
declare -A repos

# Phase 1: Clone/Update all repositories
echo "Starting repository synchronization..."
while : ; do
    # Make API request
    response=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN" \
        "https://api.github.com/user/repos?page=$page&per_page=$per_page&sort=full_name")

    # Check for API errors
    if echo "$response" | jq -e '.message' >/dev/null 2>&1; then
        echo "API Error: $(echo "$response" | jq -r '.message')"
        exit 1
    fi

    # Process repositories
    while IFS=$'\t' read -r name private fork clone_url; do
        # Determine repository type
        if [ "$fork" = "true" ]; then
            category="forks"
        elif [ "$private" = "true" ]; then
            category="private"
        else
            category="public"
        fi

        repo_path="$category/$name"
        clone_url_with_token="https://${GITHUB_API_TOKEN}@${clone_url#https://}"

        # Store repo path for archiving phase
        repos["$category"]+="$name"$'\n'

        # Clone or update repository
        if [ -d "$repo_path" ]; then
            echo "Updating $repo_path..."
            (cd "$repo_path" && git pull --autostash -q)
        else
            echo "Cloning $clone_url..."
            git clone -q "$clone_url_with_token" "$repo_path"
        fi
    done < <(echo "$response" | jq -r '.[] | [.name, .private, .fork, .clone_url] | @tsv')

    # Check pagination
    if [ "$(echo "$response" | jq 'length')" -lt "$per_page" ]; then
        break
    fi
    ((page++))
done

# Phase 2: Archive repositories after all processing
echo -e "\nStarting archiving process..."
for category in private public forks; do
    echo "Archiving $category repositories..."
    cd "$category" || continue

    # Find all directories (excluding current directory) and create archives
    find . -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d $'\0' dir; do
        repo_name="${dir#./}"
        echo " - Creating ${repo_name}.tar.gz"
        tar -czf "${repo_name}.tar.gz" "$repo_name" --force-local
    done

    cd ..
done

echo -e "\nOperation completed. Repository structure:"
tree -d -L 2 {private,public,forks} 2>/dev/null || echo "Install 'tree' for better directory visualization"
