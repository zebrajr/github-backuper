#!/bin/bash
# File containing the list of Git repository URLs
REPO_FILE="gitRepos.txt"

# Directory where the repositories will be cloned
CLONE_DIR="repositories"

# Create the directory if it doesn't exist
mkdir -p "$CLONE_DIR"

# Function to convert HTTPS URL to SSH format
convert_to_ssh() {
    local https_url="$1"
    local ssh_url

    # Remove the 'https://' part
    ssh_url="git@${https_url#https://}"

    # Replace '/' with ':' after 'github.com'
    ssh_url="${ssh_url/github.com\//github.com:}"

    # Append '.git' at the end
    ssh_url="${ssh_url}.git"

    echo "$ssh_url"
}

# Read each line from the file
while IFS= read -r repo_url
do
    # Skip lines that start with '#'
    [[ "$repo_url" =~ ^# ]] && continue

    # Convert HTTPS URL to SSH URL
    ssh_repo_url=$(convert_to_ssh "$repo_url")

    # Extract the repo name from the URL
    repo_name=$(basename "$repo_url" .git)

    # Path to the local repository
    repo_path="$CLONE_DIR/$repo_name"

    # Check if the directory exists
    if [ -d "$repo_path" ]; then
        # If the repo is already cloned, fetch and update
        echo "Updating repository: $repo_name"
        git -C "$repo_path" fetch --all
        git -C "$repo_path" pull
    else
        # If the repo is not cloned, clone it using SSH URL
        echo "Cloning repository: $repo_name"
        git clone "$ssh_repo_url" "$repo_path"
    fi
done < "$REPO_FILE"
