#!/usr/bin/env bash

# --------------------------- Info -----------------------------
# We are testing this script in a different repo to make it work.
# https://github.com/helios-network/hip-testing
#
# Thus, to not introduce errors to the public mdBook 
# test first in the above repo before updating scripts in this repo.
# --------------------------------------------------------------

# Ensure we're running with bash 4 or higher (needed for associative arrays)
if ((BASH_VERSINFO[0] < 4)); then
    echo "This script requires bash version 4 or higher"
    echo "Current version: $BASH_VERSION"
    exit 1
fi

# Exit script on error
set -e

# Initialize arrays
declare -A approved_entries_readme=()
declare -A approved_entries_summary=()
declare -A review_entries_readme=()
declare -A review_entries_summary=()
declare -A approved_mips=()
declare -A approved_mds=()
declare -A approved_mgs=()

# Variables
GITHUB_OWNER="helios-network"
GITHUB_REPO="HIP"
API_URL="https://api.github.com"

AUTH_HEADER=$(bash get_auth_token.sh)

# Test if the token is valid
response=$(curl -s -H "$AUTH_HEADER" https://api.github.com/user)
if echo "$response" | jq -e '.message? | contains("Bad credentials")' >/dev/null; then
    echo "❌ ERROR: GitHub authentication failed. Token might be invalid or expired."
    exit 1
fi


# Set up absolute paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR="$SCRIPT_DIR"
SRC_DIR="$WORK_DIR/src"

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found. Please install jq to run this script."
    exit 1
fi

# Remove src folder if it exists
rm -rf "$SRC_DIR"

# Create src folder
mkdir -p "$SRC_DIR"

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found. Please install jq to run this script."
    exit 1
fi

# Remove src folder if it exists
rm -rf src

# Create src folder
mkdir -p src

# Install mdbook-katex
cargo install mdbook-katex

# Generate book.toml file with the correct title and GitHub repository
cat >book.toml <<'EOL'
[book]
title = "HIP"

[output.html]
smart-punctuation = true
no-section-label = true
git-repository-url = "https://github.com/helios-network/HIP"
site-url = "/HIP/"
mathjax-support = true

[output.html.search]
heading-split-level = 0

[output.html.playground]
runnable = false

[preprocessor.katex]
after = ["links"]
output = "html"
leqno = false
fleqn = false
throw-on-error = false
error-color = "#cc0000"
min-rule-thickness = -1.0
max-size = "Infinity"
max-expand = 1000
trust = true
no-css = false
include-src = false
block-delimiter = { left = '$$', right = '$$' }
inline-delimiter = { left = '$', right = '$' }
pre-render = false

[preprocessor.katex.macros]
"\\" = "\\textbackslash"
EOL

# Clone HIP repository
rm -rf HIP_repo
git clone --mirror https://github.com/helios-network/HIP.git HIP_repo

cd HIP_repo

# Fetch all branches
git fetch --all

# Get list of branches
branches=$(git for-each-ref --format='%(refname:short)' refs/heads/)

cd ..

# Function to URL-encode a string using jq
urlencode() {
    local string="${1}"
    local encoded
    encoded=$(jq -rn --arg str "$string" '$str|@uri')
    echo "${encoded}"
}

# Function to sanitize titles for folder names
sanitize_title_for_folder() {
    local title="$1"
    title="${title// /_}"                # Replace spaces with underscores
    title="${title//[\\\`*()#\+!|\/]/}"  # Remove specific special characters
    echo "$title"
}

# Function to sanitize titles for use in SUMMARY.md
sanitize_title_for_summary() {
    local title="$1"
    title="${title//\\/}"      # Remove backslashes
    title="${title//\`/}"      # Remove backticks
    title="${title//\"/}"      # Remove double quotes
    title="${title//\[/}"      # Remove [
    title="${title//\]/}"      # Remove ]
    title="${title//\(/}"      # Remove (
    title="${title//\)/}"      # Remove )
    title="${title//:/ -}"     # Replace colon with hyphen
    title="${title//\*/}"      # Remove asterisks
    title="${title//\$/}"      # Remove dollar signs
    title="${title//_/ }"      # Replace underscores with spaces
    title="${title//\{/}"      # Remove {
    title="${title//\}/}"      # Remove }
    title="${title//</}"       # Remove <
    title="${title//>/}"       # Remove >
    echo "$title"
}

# Update the escape_dollar_signs function to handle Markdown headers and math better
escape_dollar_signs() {
    local file="$1"
    local temp_file="${file}.tmp"
    
    # Check if the source file exists
    if [ ! -f "$file" ]; then
        echo "Warning: Source file $file does not exist, skipping dollar sign escaping"
        return 0
    fi
    
    # Check if we can create and write to the temp file
    if ! touch "$temp_file" 2>/dev/null; then
        echo "Warning: Cannot create temporary file $temp_file, skipping dollar sign escaping"
        return 0
    fi
    
    while IFS= read -r line; do
        # Skip lines that are already properly escaped
        if [[ "$line" =~ ^\\\\ || "$line" =~ ^/\\\\ ]]; then
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # Handle Markdown headers with dollar signs
        if [[ "$line" =~ ^#+ ]]; then
            # This is a header line - escape any dollar signs
            line="${line//\$/\\$}"
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # Handle math expressions
        if [[ "$line" =~ \$\$.+\$\$ ]]; then
            # Block math - preserve as is
            echo "$line" >> "$temp_file"
            continue
        fi
        
        if [[ "$line" =~ \$[^#]+\$ ]]; then
            # Inline math that doesn't contain headers - preserve as is
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # Escape token references
        line="${line//\$L1HELIOS/\\$L1HELIOS}"
        line="${line//\$L2HELIOS/\\$L2HELIOS}"
        line="${line//\$HELIOS/\\$HELIOS}"
        line="${line//\$L1HLS/\\$L1HLS}"
        line="${line//\$L2HLS/\\$L2HLS}"
        line="${line//\$HLS/\\$HLS}"
        line="${line//\$ETH/\\$ETH}"
        
        # Handle special cases in SUMMARY.md
        if [[ "$file" == *"SUMMARY.md" ]]; then
            # Fix markdown links without over-escaping
            line="${line//\]\(/](}"
            # Only escape backslashes that aren't already escaped
            line="${line//\\/\\\\}"
            line="${line//\\\\\\/\\\\}"  # Fix double escapes
        fi
        
        # Handle any remaining standalone dollar signs
        # but only if they're not part of a math expression
        if ! [[ "$line" =~ \$[^#]*\$ ]]; then
            line="${line//\$ /\\$ }"
            line="${line// \$/ \\$}"
        fi
        
        echo "$line" >> "$temp_file" || {
            echo "Warning: Failed to write to $temp_file, keeping original file unchanged"
            rm -f "$temp_file"
            return 0
        }
    done < "$file"
    
    # Only move the temp file if it exists and has content
    if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
        mv "$temp_file" "$file" || {
            echo "Warning: Failed to replace $file with processed version, keeping original file"
            rm -f "$temp_file"
            return 0
        }
    else
        echo "Warning: Temporary file $temp_file is missing or empty, keeping original file"
        rm -f "$temp_file"
    fi
}

# Initialize README and SUMMARY.md
initialize_glossary_and_summary() {
    mkdir -p glossary_parts src
    echo "# Welcome to the Helios Network HIP Book" > src/README.md
    echo "" >> src/README.md

    WIKI_REPO="https://github.com/helios-network/HIP.wiki.git"
    WIKI_DIR="/tmp/hip_wiki"
    GLOSSARY_FILE="src/GLOSSARY.md"

    echo "Fetching glossary from the HIP Wiki..."
    
    # Remove any previous clone
    rm -rf "$WIKI_DIR"

    # Clone the wiki repo
    if git clone --depth=1 "$WIKI_REPO" "$WIKI_DIR"; then
        if [ -f "$WIKI_DIR/Glossary.md" ]; then
            echo "Extracting glossary..."
            cp "$WIKI_DIR/Glossary.md" "$GLOSSARY_FILE"
            echo "Successfully downloaded glossary."
        else
            echo "Error: Glossary file not found in Wiki repository. Using fallback."
            fallback_glossary
        fi
    else
        echo "Error: I failed to clone the Wiki repository. Using fallback."
        fallback_glossary
    fi

    # Cleanup
    rm -rf "$WIKI_DIR"

    # Output the glossary file content for debugging
    echo "DEBUG: Glossary file content:"
    cat "$GLOSSARY_FILE"
    echo "# Summary" > src/SUMMARY.md
    echo "[Glossary](GLOSSARY.md)" >> src/SUMMARY.md
    echo "" >> src/SUMMARY.md
}

# Fallback glossary function
fallback_glossary() {
    cat > "$GLOSSARY_FILE" << 'EOL'
## Glossary

⚠ **Warning**: Failed to fetch the latest glossary from the GitHub Wiki.
Please check [the glossary online](https://github.com/helios-network/HIP/wiki/glossary).

EOL
}


get_standardized_path() {
    local type="$1"    # HD, HG or HIP (uppercase)
    local number="$2"  # number part
    
    # Force type to uppercase and ensure consistent formatting
    type="${type^^}"  # Convert to uppercase
    number="${number#0}"  # Remove leading zeros
    
    # Keep type folder uppercase, but subfolder lowercase
    echo "${type}/${type,,}-${number}"
}

process_readme_files() {
    local base_path="$1"
    local category="$2"
    local type="$3"
    local hip_number="$4"
    local branch="$5"

    local standardized_path=$(get_standardized_path "$type" "$hip_number")
    local folder="$SRC_DIR/$category/$branch/$standardized_path"
    local entry_key="${type^^}|$hip_number"
    
    # Skip if we're trying to add a Review entry but the path contains "Approved"
    if [ "$category" == "Review" ] && [[ "$folder" == *"/Approved/"* ]]; then
        echo "DEBUG: Skipping review entry because path contains 'Approved': $folder"
        return
    fi
    
    # Enhanced duplicate checking
    if [ "$category" == "Review" ]; then
        if [ "${type^^}" == "HIP" ] && [ -n "${approved_mips[$hip_number]}" ]; then
            echo "DEBUG: Skipping review entry for HIP-$hip_number (exists in approved)"
            return
        elif [ "${type^^}" == "HD" ] && [ -n "${approved_mds[$hip_number]}" ]; then
            echo "DEBUG: Skipping review entry for HD-$hip_number (exists in approved)"
            return
        elif [ "${type^^}" == "HG" ] && [ -n "${approved_mgs[$hip_number]}" ]; then
            echo "DEBUG: Skipping review entry for HG-$hip_number (exists in approved)"
            return
        fi
        
        if [ -n "${approved_entries_readme[$entry_key]}" ] || [ -n "${review_entries_readme[$entry_key]}" ]; then
            echo "DEBUG: Skipping duplicate review entry for $type-$hip_number"
            return
        fi
    fi
    
    if [ -d "$folder" ]; then
        if [ -f "$folder/README.md" ]; then
            # Escape dollar signs in the README.md file
            escape_dollar_signs "$folder/README.md"
            
            readme_title=$(head -n 10 "$folder/README.md" | grep -m 1 '^# ' || true)
            if [ -n "$readme_title" ]; then
                readme_title="${readme_title#\# }"
            else
                readme_title="$type-$hip_number"
            fi

            # Create paths - note the difference between README and SUMMARY
            relative_path="${category}/${branch}/${standardized_path}"
            entry_key="${type^^}|$hip_number"
            # For README.md, link to directory without README.md
            readme_entry="- [$readme_title]($relative_path/)"
            # For SUMMARY.md, keep the README.md in the path
            summary_entry="- [$readme_title]($relative_path/README.md)"
            
            if [ "$category" == "Approved" ]; then
                echo "DEBUG: Adding to approved entries: $type-$hip_number"
                approved_entries_readme["$entry_key"]="$readme_entry"
                approved_entries_summary["$entry_key"]="$summary_entry"
                if [ "$type" == "HIP" ]; then
                    approved_mips["$hip_number"]=1
                    echo "DEBUG: Marked HIP-$hip_number as approved"
                elif [ "$type" == "HD" ]; then
                    approved_mds["$hip_number"]=1
                    echo "DEBUG: Marked HD-$hip_number as approved"
                elif [ "$type" == "HG" ]; then
                    approved_mgs["$hip_number"]=1
                    echo "DEBUG: Marked HG-$hip_number as approved"
                fi
            else
                if [ "$type" == "HIP" ] && [ -n "${approved_mips[$hip_number]}" ]; then
                    echo "DEBUG: Skipping review entry for HIP-$hip_number as it exists in approved"
                    return
                elif [ "$type" == "HD" ] && [ -n "${approved_mds[$hip_number]}" ]; then
                    echo "DEBUG: Skipping review entry for HD-$hip_number as it exists in approved"
                    return
                elif [ "$type" == "HG" ] && [ -n "${approved_mgs[$hip_number]}" ]; then
                    echo "DEBUG: Skipping review entry for HG-$hip_number as it exists in approved"
                    return
                fi
                
                echo "DEBUG: Adding to review entries: $type-$hip_number"
                review_entries_readme["$entry_key"]="$readme_entry"
                review_entries_summary["$entry_key"]="$summary_entry"
            fi
        fi
    fi
}

# Function to process the main branch (Approved category)
process_main_branch() {
    local branch="main"
    local category="Approved"

    mkdir -p "$SRC_DIR/$category/$branch"
    branch_temp_dir=$(mktemp -d)
    echo "Created temp directory for main branch: $branch_temp_dir"

    if ! git --git-dir="$WORK_DIR/HIP_repo" --work-tree="$branch_temp_dir" checkout -f "$branch"; then
        echo "Error: Failed to checkout main branch"
        rm -rf "$branch_temp_dir"
        exit 1
    fi

    ls -la "$branch_temp_dir"

    # Copy root-level files (like GLOSSARY.md) into the Approved directory
    if [ -d "$branch_temp_dir" ]; then
        for file in "$branch_temp_dir"/*; do
            if [ -f "$file" ]; then
                echo "Copying root file $(basename "$file") to $SRC_DIR/$category/$branch/"
                cp "$file" "$SRC_DIR/$category/$branch/"
            fi
        done
    fi

    for type in "HD" "HIP" "HG"; do
        if [ -d "$branch_temp_dir/$type" ]; then
            echo "Found directory: $branch_temp_dir/$type"
            
            for folder in "$branch_temp_dir/$type"/*; do
                folder_name=$(basename "$folder")
                # Convert to lowercase for comparison
                lowercase_folder_name=$(echo "$folder_name" | tr '[:upper:]' '[:lower:]')

                if [[ "$lowercase_folder_name" == "${type,,}-0" ]]; then
                    echo "Skipping folder $folder_name in main branch because it is ${type}-0."
                    continue
                fi

                # Make the pattern matching case-insensitive by using shopt
                shopt -s nocasematch
                if [[ ! "$folder_name" =~ ^${type,,}-[0-9]+$ ]]; then
                    echo "Skipping folder $folder_name because it does not match the expected naming convention."
                    continue
                fi
                shopt -u nocasematch

                hip_number=$(echo "$lowercase_folder_name" | grep -o '[0-9]\+')

                if [ -z "$hip_number" ]; then
                    echo "Skipping folder $folder_name in main branch because it does not contain a valid HIP/HD number."
                    continue
                fi

                # Use standardized path for destination
                standardized_path=$(get_standardized_path "$type" "$hip_number")
                dest_dir="$SRC_DIR/$category/$branch/$standardized_path"
                mkdir -p "$dest_dir"

                # Copy the contents
                echo "Copying from $folder/* to $dest_dir/"
                if ! cp -r "$folder"/* "$dest_dir/"; then
                    echo "Error: Failed to copy $folder/* to $dest_dir/"
                    continue
                fi

                if [ -f "$dest_dir/README.md" ] || [ -f "$dest_dir/readme.md" ]; then
                    process_readme_files "src/$category/$branch" "$category" "$type" "$hip_number" "$branch"
                else
                    echo "WARNING: No README.md found in $dest_dir after copying"
                fi
            done
        fi
    done

    echo "Contents of src directory after copying:"
    find src -type f -name "README.md" -exec echo {} \;

    rm -rf "$branch_temp_dir"
}

# In copy_branch_content function:
copy_branch_content() {
    local branch="$1"
    local category="$2"

    branch_url_encoded=$(urlencode "$branch")
    pr_info=$(curl -s -H "$AUTH_HEADER" "$API_URL/repos/$GITHUB_OWNER/$GITHUB_REPO/pulls?head=$GITHUB_OWNER:$branch_url_encoded&state=open")

    # Enhanced error handling for API response
    if [ -z "$pr_info" ]; then
        echo "Error: Empty response from GitHub API for branch $branch"
        return
    fi

    if ! echo "$pr_info" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON response from GitHub API for branch $branch"
        return
    fi

    # Debugging: Print the JSON response to understand its structure
    # echo "DEBUG: JSON response for branch $branch:"
    # echo "$pr_info" | jq .

    # Check if the response is an empty array
    if [ "$(echo "$pr_info" | jq 'length')" -eq 0 ]; then
        echo "No open PR associated with branch $branch. Skipping."
        return
    fi

    # Safely get PR information with null checks

    is_draft=$(echo "$pr_info" | jq -r '.[0].draft // false')
    pr_title=$(echo "$pr_info" | jq -r '.[0].title // empty')

    if [ -z "$pr_title" ]; then
        echo "Error: Could not get PR title for branch $branch"
        return
    fi

    # Check both the draft status and if the title contains [draft] or [Draft]
    if [ "$is_draft" == "true" ] || [[ "$pr_title" =~ \[([Dd]raft)\] ]]; then
        echo "Branch $branch is associated with a draft PR or has [draft] in title. Skipping."
        return
    fi

    mkdir -p "src/$category/$branch"
    branch_temp_dir=$(mktemp -d)
    echo "Created temp directory for branch $branch: $branch_temp_dir"

    if ! git --git-dir=HIP_repo --work-tree="$branch_temp_dir" checkout -f "$branch"; then
        echo "Error: Failed to checkout branch $branch"
        rm -rf "$branch_temp_dir"
        return
    fi

    for type in "HD" "HIP" "HG"; do
        if [ -d "$branch_temp_dir/$type" ]; then
            echo "Found directory: $branch_temp_dir/$type"
            
            # Add check for empty directory
            if [ -z "$(ls -A "$branch_temp_dir/$type")" ]; then
                echo "Directory $branch_temp_dir/$type is empty, skipping"
                continue
            fi
            
            for folder in "$branch_temp_dir/$type"/*; do
                # Check if folder exists and is a directory
                if [ ! -d "$folder" ]; then
                    echo "Skipping non-directory: $folder"
                    continue
                fi
                
                folder_name=$(basename "$folder")
                lowercase_folder_name=$(echo "$folder_name" | tr '[:upper:]' '[:lower:]')

                if [[ "$lowercase_folder_name" == "${type,,}-0" ]]; then
                    continue
                fi

                if [[ ! "$lowercase_folder_name" =~ ^${type,,}-[0-9]+$ ]]; then
                    continue
                fi

                hip_number=$(echo "$lowercase_folder_name" | grep -o '[0-9]\+')

                if [ -z "$hip_number" ]; then
                    continue
                fi

                # Enhanced duplicate checking before processing
                entry_key="${type}|${hip_number}"
                if [ -n "${approved_mips[$hip_number]}" ] && [ "$type" == "HIP" ]; then
                    echo "DEBUG: Skipping HIP-$hip_number in branch $branch (exists in approved)"
                    continue
                elif [ -n "${approved_mds[$hip_number]}" ] && [ "$type" == "HD" ]; then
                    echo "DEBUG: Skipping HD-$hip_number in branch $branch (exists in approved)"
                    continue
                elif [ -n "${approved_mgs[$hip_number]}" ] && [ "$type" == "HG" ]; then
                    echo "DEBUG: Skipping HG-$hip_number in branch $branch (exists in approved)"
                    continue
                elif [ -n "${approved_entries_readme[$entry_key]}" ] || [ -n "${review_entries_readme[$entry_key]}" ]; then
                    echo "DEBUG: Skipping duplicate entry for $type-$hip_number in branch $branch"
                    continue
                fi

                standardized_path=$(get_standardized_path "$type" "$hip_number")
                dest_dir="src/$category/$branch/$standardized_path"
                mkdir -p "$dest_dir"
                
                if [ -d "$folder" ]; then
                    echo "Copying from $folder/* to $dest_dir/"
                    if ! cp -r "$folder"/* "$dest_dir/"; then
                        echo "Error: Failed to copy $folder/* to $dest_dir/"
                        continue
                    fi

                    if [ -f "$dest_dir/README.md" ]; then
                        process_readme_files "src/$category/$branch" "$category" "$type" "$hip_number" "$branch"
                    fi
                fi
            done
        fi
    done

    rm -rf "$branch_temp_dir"
}

initialize_glossary_and_summary

# Process main branch (Approved category)
process_main_branch

# Process other branches (Review category)
for branch in $branches; do
    echo "Processing branch: $branch"
    if [ "$branch" = "main" ]; then
        continue
    fi
    copy_branch_content "$branch" "Review"
done

# Before writing to README.md and SUMMARY.md, add debug:
echo "DEBUG: Number of approved entries: ${#approved_entries_readme[@]}"
echo "DEBUG: Number of review entries: ${#review_entries_readme[@]}"

# In the section that writes to README.md and SUMMARY.md:
for category in "Approved" "Review"; do
    echo "## $category" >> "$SRC_DIR/README.md"
    echo "" >> "$SRC_DIR/README.md"
    echo "- [$category](README.md)" >> "$SRC_DIR/SUMMARY.md"

    declare -a hd_entries_readme
    declare -a hg_entries_readme
    declare -a hip_entries_readme
    declare -a hd_entries_summary
    declare -a hg_entries_summary
    declare -a hip_entries_summary

    # Use the appropriate arrays based on category
    if [ "$category" == "Approved" ]; then
        entries_array=("${!approved_entries_readme[@]}")
    else
        entries_array=("${!review_entries_readme[@]}")
    fi

    # Sort entries by type and number
    for key in "${entries_array[@]}"; do
        IFS='|' read -r type number <<< "$key"
        
        if [ "$category" == "Approved" ]; then
            readme_value="${approved_entries_readme[$key]}"
            summary_value="${approved_entries_summary[$key]}"
        else
            # Skip if this is a review entry but exists in approved arrays
            if [ "$type" == "HIP" ] && [ -n "${approved_mips[$number]}" ]; then
                echo "DEBUG: SKIPPING review entry HIP-$number (exists in approved_mips)"
                continue
            elif [ "$type" == "HD" ] && [ -n "${approved_mds[$number]}" ]; then
                echo "DEBUG: SKIPPING review entry HD-$number (exists in approved_mds)"
                continue
            elif [ "$type" == "HG" ] && [ -n "${approved_mgs[$number]}" ]; then
                echo "DEBUG: SKIPPING review entry HG-$number (exists in approved_mgs)"
                continue
            elif [[ "${review_entries_readme[$key]}" == *"/Approved/"* ]]; then
                echo "DEBUG: SKIPPING review entry $type-$number (path contains Approved)"
                continue
            elif [[ "${review_entries_readme[$key]}" =~ ^.*\(Approved/.*\)$ ]]; then
                echo "DEBUG: SKIPPING review entry $type-$number (link points to Approved)"
                continue
            fi
            
            readme_value="${review_entries_readme[$key]}"
            summary_value="${review_entries_summary[$key]}"
        fi

        # Additional check to ensure the path doesn't contain "Approved"
        if [ "$category" == "Review" ] && [[ "$readme_value" =~ Approved/ ]]; then
            echo "DEBUG: SKIPPING review entry $type-$number (contains Approved in path)"
            continue
        fi

        if [ "$type" == "HD" ]; then
            hd_entries_readme+=("$readme_value")
            hd_entries_summary+=("$summary_value")
        elif [ "$type" == "HG" ]; then
            hg_entries_readme+=("$readme_value")
            hg_entries_summary+=("$summary_value")
        else
            hip_entries_readme+=("$readme_value")
            hip_entries_summary+=("$summary_value")
        fi
    done

    # Before writing entries, filter out any approved entries from review arrays
    if [ "$category" == "Review" ]; then
        # Create temporary arrays
        declare -a filtered_hip_entries_readme
        declare -a filtered_hip_entries_summary
        declare -a filtered_hd_entries_readme
        declare -a filtered_hd_entries_summary
        declare -a filtered_hg_entries_readme
        declare -a filtered_hg_entries_summary

        # Filter HIP entries
        for entry in "${hip_entries_readme[@]}"; do
            if [[ ! "$entry" =~ ^.*\(Approved/.*\)$ ]] && [[ ! "$entry" =~ Approved/ ]]; then
                filtered_hip_entries_readme+=("$entry")
            fi
        done
        for entry in "${hip_entries_summary[@]}"; do
            if [[ ! "$entry" =~ ^.*\(Approved/.*\)$ ]] && [[ ! "$entry" =~ Approved/ ]]; then
                filtered_hip_entries_summary+=("$entry")
            fi
        done

        # Filter HD entries
        for entry in "${hd_entries_readme[@]}"; do
            if [[ ! "$entry" =~ ^.*\(Approved/.*\)$ ]] && [[ ! "$entry" =~ Approved/ ]]; then
                filtered_hd_entries_readme+=("$entry")
            fi
        done
        for entry in "${hd_entries_summary[@]}"; do
            if [[ ! "$entry" =~ ^.*\(Approved/.*\)$ ]] && [[ ! "$entry" =~ Approved/ ]]; then
                filtered_hd_entries_summary+=("$entry")
            fi
        done

        # Filter HG entries
        for entry in "${hg_entries_readme[@]}"; do
            if [[ ! "$entry" =~ ^.*\(Approved/.*\)$ ]] && [[ ! "$entry" =~ Approved/ ]]; then
                filtered_hg_entries_readme+=("$entry")
            fi
        done
        for entry in "${hg_entries_summary[@]}"; do
            if [[ ! "$entry" =~ ^.*\(Approved/.*\)$ ]] && [[ ! "$entry" =~ Approved/ ]]; then
                filtered_hg_entries_summary+=("$entry")
            fi
        done

        # Replace original arrays with filtered ones
        hip_entries_readme=("${filtered_hip_entries_readme[@]}")
        hip_entries_summary=("${filtered_hip_entries_summary[@]}")
        hd_entries_readme=("${filtered_hd_entries_readme[@]}")
        hd_entries_summary=("${filtered_hd_entries_summary[@]}")
        hg_entries_readme=("${filtered_hg_entries_readme[@]}")
        hg_entries_summary=("${filtered_hg_entries_summary[@]}")
    fi

    # Debug output before writing
    if [ "$category" == "Review" ]; then
        echo "DEBUG: Final filtered HIP entries for Review section:"
        printf '%s\n' "${hip_entries_readme[@]}"
    fi

    # Sort arrays
    if [ ${#hd_entries_readme[@]} -gt 0 ]; then
        IFS=$'\n' hd_entries_readme=($(sort -V <<<"${hd_entries_readme[*]}"))
        IFS=$'\n' hd_entries_summary=($(sort -V <<<"${hd_entries_summary[*]}"))
    fi
    if [ ${#hg_entries_readme[@]} -gt 0 ]; then
        IFS=$'\n' hg_entries_readme=($(sort -V <<<"${hg_entries_readme[*]}"))
        IFS=$'\n' hg_entries_summary=($(sort -V <<<"${hg_entries_summary[*]}"))
    fi
    if [ ${#hip_entries_readme[@]} -gt 0 ]; then
        IFS=$'\n' hip_entries_readme=($(sort -V <<<"${hip_entries_readme[*]}"))
        IFS=$'\n' hip_entries_summary=($(sort -V <<<"${hip_entries_summary[*]}"))
    fi
    unset IFS

    if [ ${#hip_entries_readme[@]} -gt 0 ]; then
        echo "### HIPs" >> "$SRC_DIR/README.md"
        echo "  - [HIPs](README.md)" >> "$SRC_DIR/SUMMARY.md"
        for i in "${!hip_entries_readme[@]}"; do
            echo "${hip_entries_readme[$i]}" >> "$SRC_DIR/README.md"
            if [[ "${hip_entries_summary[$i]}" == "- "* ]]; then
                link_line="${hip_entries_summary[$i]#- }"
                link_text="${link_line%%]*}"
                link_text="${link_text#\[}"
                link_url="${link_line##*\(}"
                link_url="${link_url%\)}"
                echo "    - [$link_text]($link_url)" >> "$SRC_DIR/SUMMARY.md"
            fi
        done
    fi

    if [ ${#hd_entries_readme[@]} -gt 0 ]; then
        echo "### HDs" >> "$SRC_DIR/README.md"
        echo "  - [HDs](README.md)" >> "$SRC_DIR/SUMMARY.md"
        for i in "${!hd_entries_readme[@]}"; do
            echo "${hd_entries_readme[$i]}" >> "$SRC_DIR/README.md"
            if [[ "${hd_entries_summary[$i]}" == "- "* ]]; then
                link_line="${hd_entries_summary[$i]#- }"
                link_text="${link_line%%]*}"
                link_text="${link_text#\[}"
                link_url="${link_line##*\(}"
                link_url="${link_url%\)}"
                echo "    - [$link_text]($link_url)" >> "$SRC_DIR/SUMMARY.md"
            fi
        done
    fi

    if [ ${#hg_entries_readme[@]} -gt 0 ]; then
        echo "### HGs" >> "$SRC_DIR/README.md"
        echo "  - [HGs](README.md)" >> "$SRC_DIR/SUMMARY.md"
        for i in "${!hg_entries_readme[@]}"; do
            echo "${hg_entries_readme[$i]}" >> "$SRC_DIR/README.md"
            if [[ "${hg_entries_summary[$i]}" == "- "* ]]; then
                link_line="${hg_entries_summary[$i]#- }"
                link_text="${link_line%%]*}"
                link_text="${link_text#\[}"
                link_url="${link_line##*\(}"
                link_url="${link_url%\)}"
                echo "    - [$link_text]($link_url)" >> "$SRC_DIR/SUMMARY.md"
            fi
        done
    fi

    echo "" >> "$SRC_DIR/README.md"
    echo "" >> "$SRC_DIR/SUMMARY.md"
done

# Build the book
if ! mdbook build; then
    echo "Error: mdbook failed to build. Please check the SUMMARY.md for syntax errors."
    exit 1
fi