#!/bin/bash

# Set the directory thay holds our music files
DIR="/path/to/music"

# Check if the directory exists
if [[ ! -d "$DIR" ]]; then
    echo "Error: Directory '$DIR' does not exist."
    exit 1
fi

# Create a temporary file to store file prefixes
temp_file=$(mktemp)

# Get a list of unique file prefixes (before " - ")
find "$DIR" -maxdepth 1 -type f -name "* - *" -print0 | while IFS= read -r -d '' file; do
    filename="$(basename -- "$file")"
    
    # Extract text before " - " as the prefix
    if [[ "$filename" =~ ^(.+)\ -\ .* ]]; then
        prefix="${BASH_REMATCH[1]}"
        echo "$prefix" >> "$temp_file"
    fi
done

# Get unique prefixes and sort them
sort -u "$temp_file" | while IFS= read -r prefix; do
    # Create a safe directory name (replace problematic characters if needed)
    safe_prefix="${prefix//[^a-zA-Z0-9 ]/_}"
    
    # Create the directory if it doesn't exist
    mkdir -p "$DIR/$safe_prefix"
    
    # Move matching files into the directory
    find "$DIR" -maxdepth 1 -type f -name "$prefix - *" -exec mv {} "$DIR/$safe_prefix/" \;
done

# Clean up temporary file
rm -f "$temp_file"

echo "Music organized successfully!"
