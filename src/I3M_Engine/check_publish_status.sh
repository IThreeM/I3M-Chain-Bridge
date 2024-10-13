#!/bin/bash

# Base directory of the code repository
REPO_DIR="$HOME/IThreeM/Startup Repositories/I3M_Engine"

# Function to check if a crate exists on crates.io
check_crate_published() {
  crate_name=$1
  # Query crates.io API for the crate. If it exists, it will return HTTP status 200
  response=$(curl -s -o /dev/null -w "%{http_code}" "https://crates.io/api/v1/crates/$crate_name")
  if [[ "$response" == "200" ]]; then
    echo "published"
  else
    echo "unpublished"
  fi
}

# List all module directories that start with "i3m" in the workspace
cd "$REPO_DIR" || exit
module_dirs=($(find . -name "Cargo.toml" -exec dirname {} \; | grep '/i3m'))

# Output file for tracking module statuses
output_file="module_publish_status.txt"
echo "Module Publish Status" > $output_file
echo "=====================" >> $output_file

# Loop through each "i3m" module directory and check its publication status
for module_dir in "${module_dirs[@]}"; do
  cd "$REPO_DIR/$module_dir" || continue
  # Extract crate name and version from Cargo.toml
  crate_name=$(grep -E '^name = ' Cargo.toml | awk -F\" '{print $2}')
  crate_version=$(grep -E '^version = ' Cargo.toml | awk -F\" '{print $2}')

  # Check if the crate is published on crates.io
  status=$(check_crate_published "$crate_name")
  echo "$crate_name ($crate_version): $status" | tee -a "$REPO_DIR/$output_file"

  # If unpublished, list dependencies to determine order
  if [[ "$status" == "unpublished" ]]; then
    echo "  Dependencies for $crate_name:" | tee -a "$REPO_DIR/$output_file"
    dependencies=($(grep '^\[dependencies\]' -A 20 Cargo.toml | grep -E '^\s*[^# ]+' | awk -F= '{print $1}' | tr -d ' ' | sort))
    for dependency in "${dependencies[@]}"; do
      dep_status=$(check_crate_published "$dependency")
      echo "    $dependency: $dep_status" | tee -a "$REPO_DIR/$output_file"
    done
  fi
  echo "" >> "$REPO_DIR/$output_file"
done

# Display the output file with status report
cat "$output_file"
