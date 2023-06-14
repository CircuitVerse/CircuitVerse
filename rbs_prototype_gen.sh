#!/bin/bash

# Step 1: Take path as argument [dir1]
dir1="$1"

# Step 2: Find all files $file in [dir1] that end in .rb
files=$(find "$dir1" -name "*.rb")

# Step 3: If ./sig/[dir1] does not exist, create it
output_dir="./sig/$dir1"
mkdir -p "$output_dir"

# Step 4: Run `rbs prototype rb $file` on each file and store the output in ./rbs/$file
for file in $files; do
  # Extract the filename without the directory path
  filename=$(basename "$file")
  
  # Change the file extension from .rb to .rbs
  new_filename="${filename%.rb}.rbs"
  
  # Run the command and redirect the output to the respective file in the output directory
  rbs_output=$(rbs prototype rb "$file")
  echo "$rbs_output" > "$output_dir/$new_filename"
done