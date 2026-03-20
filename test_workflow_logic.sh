#!/bin/bash

# Test script to validate the workflow template detection logic locally
# This simulates what the GitHub Actions workflow does

set -e

echo "==================================="
echo "Testing Workflow Template Detection"
echo "==================================="
echo ""

# Simulate the changed-files output with escaped quotes (as GitHub Actions provides it)
SIMULATED_GITHUB_OUTPUT='[\"AndroidNativeKotlinTemplate\",\"ReactNativeTemplate\",\"iOSNativeSwiftTemplate\"]'

echo "1. Simulated GitHub Actions output (with escaped quotes):"
echo "   $SIMULATED_GITHUB_OUTPUT"
echo ""

# Apply the sed fix to remove escaped quotes
CHANGED_FILES=$(echo "$SIMULATED_GITHUB_OUTPUT" | sed 's/\\//g')

echo "2. After sed removal of backslashes:"
echo "   $CHANGED_FILES"
echo ""

# Test jq parsing
echo "3. Testing jq parsing..."
if jq -r '.[]' <<< "$CHANGED_FILES" > /dev/null 2>&1; then
    echo "   ✅ jq parsing successful!"
    echo "   Parsed values:"
    for file in $(jq -r '.[]' <<< "$CHANGED_FILES"); do
        echo "      - $file"
    done
else
    echo "   ❌ jq parsing failed!"
    exit 1
fi
echo ""

# Get list of all templates from templates.json
if [ ! -f "templates.json" ]; then
    echo "❌ Error: templates.json not found. Run this script from the repo root."
    exit 1
fi

TEMPLATES=$(jq -r '.[].path' templates.json)

echo "4. Valid templates from templates.json:"
echo "$TEMPLATES" | sed 's/^/      - /'
echo ""

# Extract template directories from changed files
CHANGED_TEMPLATES=()
for file in $(jq -r '.[]' <<< "$CHANGED_FILES"); do
    # Get the first directory component
    TEMPLATE_DIR=$(echo "$file" | cut -d'/' -f1)

    # Check if it's a valid template
    if echo "$TEMPLATES" | grep -q "^${TEMPLATE_DIR}$"; then
        # Add to array if not already present
        if [[ ! " ${CHANGED_TEMPLATES[@]} " =~ " ${TEMPLATE_DIR} " ]]; then
            CHANGED_TEMPLATES+=("$TEMPLATE_DIR")
        fi
    fi
done

echo "5. Detected changed templates:"
if [ ${#CHANGED_TEMPLATES[@]} -gt 0 ]; then
    for template in "${CHANGED_TEMPLATES[@]}"; do
        echo "      - $template"
    done
else
    echo "      (none)"
fi
echo ""

# Convert to JSON array (compact format for GitHub Actions)
echo "6. Testing JSON output format..."
TEMPLATES_JSON=$(printf '%s\n' "${CHANGED_TEMPLATES[@]}" | jq -R . | jq -sc .)

echo "   Compact JSON (single line):"
echo "   $TEMPLATES_JSON"
echo ""

# Verify it's valid JSON
if echo "$TEMPLATES_JSON" | jq . > /dev/null 2>&1; then
    echo "   ✅ Valid JSON format!"
else
    echo "   ❌ Invalid JSON format!"
    exit 1
fi

# Check if it's on a single line (no newlines)
if [[ "$TEMPLATES_JSON" == *$'\n'* ]]; then
    echo "   ❌ Contains newlines (will fail in GitHub Actions)"
    exit 1
else
    echo "   ✅ Single line (compatible with GitHub Actions)"
fi

echo ""
echo "==================================="
echo "✅ All tests passed!"
echo "==================================="
echo ""
echo "Summary:"
echo "  - Templates detected: ${#CHANGED_TEMPLATES[@]}"
echo "  - Output JSON: $TEMPLATES_JSON"
echo "  - has-changes: true"
echo "  - test-all: false"
