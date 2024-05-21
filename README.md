# Gitleaks Pre-Commit Hook

This script is a pre-commit hook for Git that runs [Gitleaks](https://github.com/zricethezav/gitleaks), a tool that scans for secrets being accidentally committed into git repos.

## Installation

To use the hook, simply run the inslattation script in the root directory of your git repository:

```bash
./install-pre-commit.sh
```
The script also contains two variables:

`GITLEAKS_VERSION`: This variable is used to specify the version of Gitleaks to be installed. The current script is set to install Gitleaks version 8.18.2.
`ENABLE_BY_DEFAULT`: This variable is used to control whether Gitleaks is enabled by default. If set to 1, Gitleaks will be enabled after installation. If set to 0, Gitleaks will not be enabled after installation.

## How it Works

1. The hook first checks if Gitleaks is enabled via git config. If it's not enabled, the hook skips the rest of the steps and exits with a status code of 0, indicating success.

2. If Gitleaks is enabled, the hook determines the operating system and ensures Gitleaks is installed. If Gitleaks is not installed, it will attempt to install it. For Linux, it downloads the tar.gz file, extracts it, moves the binary to /usr/local/bin, and cleans up the downloaded file. For macOS, it uses Homebrew to install Gitleaks. If the OS is not supported, it prompts the user to install Gitleaks manually.

3. The hook then runs Gitleaks with every commit with the `protect -v --staged` command, which scans the staged files for potential secrets.

4. If Gitleaks finds potential secrets (indicated by a non-zero exit status), the hook prints a message and exits with a status code of 1, indicating failure and preventing the commit. If no secrets are found, the hook completes normally, allowing the commit to proceed.


## Requirements
- wget (for Linux)
- tar (for Linux)
- Homebrew (for macOS)