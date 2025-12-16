#!/bin/bash

# --- Safety Check: Must be run as root ---
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root. Please use sudo." >&2
   exit 1
fi

# --- Get the optional filter from the first argument ---
FILTER="$1"

# --- Function to get rule numbers to be deleted ---
get_rules_to_delete() {
    if [ -n "$FILTER" ]; then
        # If a filter is provided, find rules matching the filter
        # awk extracts the rule number (e.g., "[1]")
        # sed removes the brackets
        # sort -rn sorts them in reverse numerical order (critical!)
        ufw status numbered | grep -P "$FILTER" | grep -o -P '^\[[0-9 ]+\]' | sed -r 's/\[|\]| //g' | sort -rn
    else
        # If no filter, get all rule numbers
        ufw status numbered | grep -o -P '^\[[0-9 ]+\]' | sed -r 's/\[|\]| //g' | sort -rn
    fi
}

# --- Main Logic ---

echo "Fetching UFW rules..."
RULE_NUMBERS=$(get_rules_to_delete)

# Check if there are any rules to delete
if [ -z "$RULE_NUMBERS" ]; then
    if [ -n "$FILTER" ]; then
        echo "No rules found matching the filter: '$FILTER'"
    else
        echo "No rules found to delete."
    fi
    exit 0
fi

echo ""
echo "=========================== WARNING ==========================="
echo "The following UFW rules have been targeted for DELETION:"
echo "-------------------------------------------------------------"

# Display the actual rules that will be deleted for user confirmation
# The complex grep pattern matches lines starting with the exact rule numbers
EGREP_PATTERN="^\[ ?($(echo "$RULE_NUMBERS" | tr '\n' '|' | sed 's/|$//'))\]"
ufw status numbered | grep -E "$EGREP_PATTERN"

echo "-------------------------------------------------------------"

# --- Confirmation Prompt ---
read -p "Are you sure you want to delete these rules? (y/N): " CONFIRM
# Convert confirmation to lowercase
CONFIRM=${CONFIRM,,}

if [[ "$CONFIRM" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo "Starting deletion process..."

# --- Deletion Loop ---
# Loop through the reverse-sorted list of numbers and delete
for num in $RULE_NUMBERS; do
    echo "Deleting rule #${num}..."
    # Use --force to avoid the interactive prompt for each deletion
    ufw --force delete "$num"
done

echo ""
echo "============================================================="
echo "All targeted rules have been deleted."
echo "Verifying current UFW status:"
echo ""
ufw status
echo "============================================================="