#!/bin/bash

# Test script showing the OLD behavior (before the fix)
# This demonstrates the jq parsing error

set +e  # Don't exit on error so we can see the failure

echo "==================================="
echo "Testing OLD Workflow (Before Fix)"
echo "==================================="
echo ""

# Simulate the changed-files output with escaped quotes
SIMULATED_GITHUB_OUTPUT='[\"AndroidNativeKotlinTemplate\",\"ReactNativeTemplate\",\"iOSNativeSwiftTemplate\"]'

echo "1. GitHub Actions output (with escaped quotes):"
echo "   $SIMULATED_GITHUB_OUTPUT"
echo ""

# OLD WAY: Store directly in variable (keeps escaped quotes)
CHANGED_FILES='[\"AndroidNativeKotlinTemplate\",\"ReactNativeTemplate\",\"iOSNativeSwiftTemplate\"]'

echo "2. OLD: Stored directly in variable:"
echo "   $CHANGED_FILES"
echo ""

# Try to parse with jq (OLD WAY using echo and pipe)
echo "3. Attempting jq parsing with OLD method..."
echo ""

# This is what the old workflow did - it fails!
echo "   Running: echo '\$CHANGED_FILES' | jq -r '.[]'"
echo ""

if echo '$CHANGED_FILES' | jq -r '.[]' 2>&1; then
    echo "   ✅ Parsing succeeded (unexpected)"
else
    ERROR_OUTPUT=$(echo '$CHANGED_FILES' | jq -r '.[]' 2>&1)
    echo "   ❌ Parsing failed as expected!"
    echo ""
    echo "   Error message:"
    echo "   $ERROR_OUTPUT"
fi

echo ""
echo "==================================="
echo "This is why the workflow was failing!"
echo "==================================="
