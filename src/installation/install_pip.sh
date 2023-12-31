#!/bin/bash

# Usage: ensure_pip_pkg <PKG> <pip_UPDATE>
# Takes the name of a package to install if not already installed,
# and optionally a 1 if pip update should be run after installation
# has finished.
ensure_pip_pkg() {
  local pip_package_name="$1"
  local execute_pip_update="$2"

  # shellcheck disable=SC2153
  setup_virtualenv "$VENV_NAME"
  activate_virtualenv "$VENV_NAME"

  # Determine if pip package is installed or not.
  local pip_pckg_exists
  pip_pckg_exists=$(
    pip list | grep -F "$pip_package_name"
    echo $?
  )
  NOTICE "pip_pckg_exists=$pip_pckg_exists"
  # Install pip package if pip package is not yet installed.
  if [ "$pip_pckg_exists" == "1" ]; then
    INFO " ${pip_package_name} is not installed. Installing now."
    pip install "${pip_package_name}" >>/dev/null 2>&1
    # TODO: if the state $? is not 0, then print output.
  else
    NOTICE " ${pip_package_name} is installed"
  fi

  assert_pip_installed "${pip_package_name}" "$VENV_NAME"

  if [ "$execute_pip_update" == "1" ]; then
    NOTICE "Performing pip update"
    #pipenv update
  fi
}

# Verifies pip package is installed.
assert_pip_installed() {
  local pip_package_name="$1"
  local venv_name="$2"

  setup_virtualenv "$venv_name"
  activate_virtualenv "$venv_name"

  # Determine if pip package is installed or not.
  local pip_pckg_exists
  pip_pckg_exists=$(
    pip list | grep -F "$pip_package_name"
    echo $?
  )

  # Throw error if pip package is not yet installed.
  if [ "$pip_pckg_exists" == "1" ]; then
    ERROR "Error, the pip package ${pip_package_name} is not installed."
    exit 3 # TODO: update exit status.
  else
    NOTICE "Verified pip package ${pip_package_name} is installed."
  fi
}

setup_virtualenv() {
  local venv_name="$1"

  # Check if the virtual environment already exists
  if [ ! -d "$venv_name" ]; then
    NOTICE "Creating virtual environment..."
    python3 -m venv "$venv_name" || {
      ERROR "Failed to create virtual environment."
      exit 1
    }
  fi
}

function activate_virtualenv() {
  local venv_name="$1"
  if [ -f "$venv_name/bin/activate" ]; then
    # Activate the virtual environment
    # shellcheck disable=SC1091
    source "$venv_name/bin/activate" || {
      ERROR "Failed to activate virtual environment with PWD=$PWD"
      exit 1
    }
  else
    ERROR "Virtual environment does not exist."
    exit 1
  fi

}
