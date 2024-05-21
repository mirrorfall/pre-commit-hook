#!/bin/bash
GITLEAKS_VERSION=8.18.2
ENABLE_BY_DEFAULT=1

# Function to place the pre-commit script
install_hook_script() {
  mkdir -p .git/hooks
  cat > .git/hooks/pre-commit << EOF
#!/bin/bash

# Function for operating system detection
detect_os() {
  case "\$(uname -s)" in
    Linux*)     OS="Linux" ;;
    Darwin*)    OS="macOS" ;;
    *)          OS="UNKNOWN" ;;
  esac
}

# Function for Gitleaks installation if needed
install_gitleaks() {
  if ! command -v gitleaks &> /dev/null; then
    echo "Gitleaks not found. Installing..."
    case "\${OS}" in
      Linux)
        # Download the tar.gz file
        mkdir temp
        cd temp
        wget https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_arm64.tar.gz
        # Extract the tar.gz file
        tar -xvzf gitleaks_${GITLEAKS_VERSION}_linux_arm64.tar.gz
        # Move the binary to /usr/local/bin
        sudo mv gitleaks /usr/local/bin/
        # Clean up the temp directory
        cd ../
        rm -rf temp
        ;;
      macOS)
        brew install gitleaks 
        ;;
      *)
        echo "Unsupported OS (\${OS}). Please install Gitleaks manually: https://github.com/zricethezav/gitleaks"
        exit 1
        ;;
    esac
  fi
}

# Check if Gitleaks is enabled via git config
if [[ "\$(git config --get hooks.gitleaks.enabled)" != "true" ]]; then
  echo "Gitleaks pre-commit hook is disabled (via git config). Skipping."
  exit 0
fi

# Install and execute Gitleaks
detect_os
install_gitleaks
gitleaks protect -v --staged

# Check for Gitleaks findings and indicate commit failure if relevant
if [[ \$? -ne 0 ]]; then
  echo "Gitleaks found potential secrets. Please review and fix before committing."
  exit 1
fi
EOF
  chmod +x .git/hooks/pre-commit
}

# Install the pre-commit hook
install_hook_script

# Get the value of hooks.gitleaks.enabled from the git config
gitleaks_enabled=$(git config --get hooks.gitleaks.enabled)

# Check the value of ENABLE_BY_DEFAULT
if [ "$ENABLE_BY_DEFAULT" -eq 1 ]; then
  # If ENABLE_BY_DEFAULT is 1, enable the gitleaks hook
  if [ -z "$gitleaks_enabled" ]; then
    # If hooks.gitleaks.enabled is not set, add it
    git config --add hooks.gitleaks.enabled true
  else
    # If hooks.gitleaks.enabled is already set, replace it
    git config --replace-all hooks.gitleaks.enabled true
  fi
else
  # If ENABLE_BY_DEFAULT is not 1, disable the gitleaks hook
  if [ -z "$gitleaks_enabled" ]; then
    # If hooks.gitleaks.enabled is not set, add it
    git config --add hooks.gitleaks.enabled false
  else
    # If hooks.gitleaks.enabled is already set, replace it
    git config --replace-all hooks.gitleaks.enabled false
  fi
fi