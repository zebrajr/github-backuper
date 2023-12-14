
# GitHub Offline Backupper

This script automates the process of cloning and updating Git repositories. It reads a list of repository URLs from a text file, checks if each repository is already cloned in a designated directory, and performs an appropriate action: it clones the repository if it's not present, or it updates (fetches and pulls) the repository if it is already cloned.

## Features

- **Automatic Cloning**: Clone repositories that are not already present in the target directory.
- **Repository Updates**: Fetch and pull updates for already cloned repositories.
- **HTTPS to SSH Conversion**: Converts HTTPS Git URLs to the SSH format on the fly.
- **Comment Support**: Allows for comments in the repository list file.

## Getting Started

### Prerequisites

- Git must be installed on your system.
- SSH access set up for your Git account (for repositories cloned over SSH).

### Installation

1. Clone this repository
2. Make ``gitBackupper.sh`` executable with ``chmod +x gitBackuper.sh``
3. Copy the sample text file to your own ``cp gitRepos.sample.txt gitRepos.txt``
4. Add your GitHub URL entries - add the https://github.com/you/repo directly, no need for the ssh version

Made by: [Carlos Sousa](https://carlossousa.tech)
