#!/bin/bash

# Comprehensive test comparing OLD vs NEW workflow logic

echo "==========================================================="
echo "WORKFLOW TEMPLATE DETECTION - OLD vs NEW COMPARISON"
echo "==========================================================="
echo ""

# Simulate GitHub Actions output
GITHUB_OUTPUT='[\"AndroidNativeKotlinTemplate\",\"ReactNativeTemplate\",\"iOSNativeSwiftTemplate\"]'

echo "Input: GitHub Actions changed-files output"
echo "       $GITHUB_OUTPUT"
echo ""
echo "-----------------------------------------------------------"
echo ""

# ============================================
# OLD METHOD (FAILS)
# ============================================

echo "❌ OLD METHOD (Before Fix)"
echo "-----------------------------------------------------------"
echo ""
echo "Code:"
echo "  CHANGED_FILES='\${{ ... }}'"
echo "  for file in \$(echo '\$CHANGED_FILES' | jq -r '.[]'); do"
echo ""
echo "Result:"

set +e  # Don't exit on error
OLD_RESULT=$(echo '[\"AndroidNativeKotlinTemplate\",\"ReactNativeTemplate\",\"iOSNativeSwiftTemplate\"]' | jq -r '.[]' 2>&1)
OLD_EXIT=$?
set -e

if [ $OLD_EXIT -eq 0 ]; then
    echo "  ✅ Success (unexpected)"
    echo "  Output: $OLD_RESULT"
else
    echo "  ❌ FAILED with jq parse error"
    echo "  Error: $OLD_RESULT"
fi

echo ""
echo "-----------------------------------------------------------"
echo ""

# ============================================
# NEW METHOD (WORKS)
# ============================================

echo "✅ NEW METHOD (After Fix)"
echo "-----------------------------------------------------------"
echo ""
echo "Code:"
echo "  CHANGED_FILES=\$(echo '\${{ ... }}' | sed 's/\\\\//g')"
echo "  for file in \$(jq -r '.[]' <<< \"\$CHANGED_FILES\"); do"
echo ""
echo "Result:"

set +e
CHANGED_FILES=$(echo "$GITHUB_OUTPUT" | sed 's/\\//g')
NEW_RESULT=$(jq -r '.[]' <<< "$CHANGED_FILES" 2>&1)
NEW_EXIT=$?
set -e

if [ $NEW_EXIT -eq 0 ]; then
    echo "  ✅ SUCCESS - Templates parsed correctly"
    echo "  Parsed templates:"
    while IFS= read -r template; do
        echo "    - $template"
    done <<< "$NEW_RESULT"

    # Test compact JSON output
    echo ""
    echo "  JSON output (compact, single line):"
    COMPACT_JSON=$(echo "$NEW_RESULT" | jq -R . | jq -sc .)
    echo "    $COMPACT_JSON"

    # Validate it's on one line
    if [[ "$COMPACT_JSON" == *$'\n'* ]]; then
        echo "    ❌ Contains newlines"
    else
        echo "    ✅ Single line (GitHub Actions compatible)"
    fi
else
    echo "  ❌ Failed"
    echo "  Error: $NEW_RESULT"
fi

echo ""
echo "==========================================================="
echo "SUMMARY"
echo "==========================================================="
echo ""
echo "OLD: ❌ Fails with 'Invalid numeric literal' jq error"
echo "NEW: ✅ Successfully parses templates and outputs compact JSON"
echo ""
echo "The fix:"
echo "  1. Use 'sed s/\\\\//g' to remove escaped quotes"
echo "  2. Use 'jq -sc' (compact) instead of 'jq -s' (pretty)"
echo ""
