#!/bin/bash

# Base directory of the code repository
REPO_DIR="$HOME/IThreeM/Startup Repositories/I3M_Engine"

# Function to check if a crate exists on crates.io
check_crate_published() {
  crate_name=$1
  response=$(curl -s -o /dev/null -w "%{http_code}" "https://crates.io/api/v1/crates/$crate_name")
  if [[ "$response" == "200" ]]; then
    echo "published"
  else
    echo "unpublished"
  fi
}

# Function to check dependencies of a crate
get_dependencies() {
  module_dir=$1
  cd "$REPO_DIR/$module_dir" || return
  grep '^\[dependencies\]' -A 20 Cargo.toml | grep -E '^\s*[^# ]+' | awk -F= '{print $1}' | tr -d ' ' | sort
}

# Gather unpublished modules and their dependencies
declare -A publish_order
cd "$REPO_DIR" || exit
module_dirs=($(find . -name "Cargo.toml" -exec dirname {} \; | grep '/i3m'))

for module_dir in "${module_dirs[@]}"; do
  cd "$REPO_DIR/$module_dir" || continue
  crate_name=$(grep -E '^name = ' Cargo.toml | awk -F\" '{print $2}')

  # Verify if crate_name is not empty
  if [[ -z "$crate_name" ]]; then
    echo "Error: Package name could not be extracted for module in directory $module_dir"
    exit 1
  fi

  status=$(check_crate_published "$crate_name")
  if [[ "$status" == "unpublished" ]]; then
    dependencies=($(get_dependencies "$module_dir"))
    publish_order["$crate_name"]="${dependencies[@]}"
  fi
done

# Determine the order of publishing based on dependencies
declare -a publish_sequence
declare -A published_modules

publish_module() {
  local module=$1
  cd "$REPO_DIR" || exit

  # Find module directory and ensure it's not empty
  module_dir=$(find . -type d -name "$module" -print -quit)
  if [[ -z "$module_dir" ]]; then
    echo "Error: Module directory for $module not found."
    exit 1
  fi

  cd "$module_dir" || return

  # Extract the exact package name from Cargo.toml and validate it
  module_name=$(grep -E '^name = ' Cargo.toml | awk -F\" '{print $2}' | tr -d '[:space:]')
  if [[ -z "$module_name" ]]; then
    echo "Error: Package name cannot be empty for module at $module_dir."
    exit 1
  fi

  # Publish using the exact package name from Cargo.toml
  cargo publish --allow-dirty -p "$module_name"

  # Return to the repository root
  cd "$REPO_DIR" || exit
}

resolve_dependencies() {
  for module in "${!publish_order[@]}"; do
    deps=(${publish_order["$module"]})
    ready_to_publish=true

    for dep in "${deps[@]}"; do
      if [[ $dep == i3m* ]] && [[ -z ${published_modules["$dep"]} ]]; then
        ready_to_publish=false
        break
      fi
    done

    if [[ "$ready_to_publish" == true ]] && [[ -z ${published_modules["$module"]} ]]; then
      publish_sequence+=("$module")
      published_modules["$module"]=false
    fi
  done
}

# Publish modules in the correct order with horizontal progress tracking
total_modules=${#publish_order[@]}
published_count=0

display_progress() {
  local progress=$1
  local width=50 # width of the progress bar
  local filled=$((progress * width / 100))
  local empty=$((width - filled))

  printf "["
  printf "%0.s#" $(seq 1 $filled)
  printf "%0.s-" $(seq 1 $empty)
  printf "] %s%% completed\r" "$progress"
}

while [[ ${#publish_sequence[@]} -lt $total_modules ]]; do
  resolve_dependencies

  for module in "${publish_sequence[@]}"; do
    if [[ "${published_modules[$module]}" == false ]]; then
      echo -ne "Publishing $module...\r"
      publish_module "$module"
      published_modules["$module"]=true

      # Update and display progress
      published_count=$((published_count + 1))
      progress=$(( (published_count * 100) / total_modules ))
      display_progress "$progress"
      sleep 1
    fi
  done
done

# Final message and progress bar at 100%
display_progress 100
echo -e "\nPublishing completed for all i3m modules."
