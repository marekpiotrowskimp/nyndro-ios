#!/bin/bash

# validate_localizations.sh
# Validates that all localization keys exist across all .strings files
# 
# Usage: ./Scripts/validate_localizations.sh
#
# Exit codes:
#   0 - All keys present (or warnings only in Debug)
#   1 - Missing keys in Release configuration

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOCALIZABLE_DIR="$PROJECT_DIR/Nyndro"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Track issues
MISSING_COUNT=0
EXTRA_COUNT=0

echo "=========================================="
echo "Localization Validation Script"
echo "=========================================="
echo ""

# Find all .lproj directories
LPROJ_DIRS=$(find "$LOCALIZABLE_DIR" -name "*.lproj" -type d | sort)

if [ -z "$LPROJ_DIRS" ]; then
    echo -e "${RED}ERROR: No .lproj directories found in $LOCALIZABLE_DIR${NC}"
    exit 1
fi

echo "Found localization directories:"
for dir in $LPROJ_DIRS; do
    echo "  - $(basename "$dir")"
done
echo ""

# Use English as the reference
REFERENCE_FILE="$LOCALIZABLE_DIR/en.lproj/Localizable.strings"

if [ ! -f "$REFERENCE_FILE" ]; then
    echo -e "${RED}ERROR: Reference file not found: $REFERENCE_FILE${NC}"
    exit 1
fi

# Function to extract keys from a .strings file
extract_keys() {
    local file="$1"
    # Extract keys (text between quotes before the = sign)
    # Handles: "key" = "value"; format
    grep -E '^"[^"]+"\s*=' "$file" 2>/dev/null | \
        sed -E 's/^"([^"]+)".*/\1/' | \
        sort -u
}

# Get reference keys (English)
echo "Extracting keys from reference (en.lproj)..."
REFERENCE_KEYS=$(extract_keys "$REFERENCE_FILE")
REFERENCE_COUNT=$(echo "$REFERENCE_KEYS" | wc -l | tr -d ' ')
echo "  Found $REFERENCE_COUNT keys in English"
echo ""

# Compare each localization to reference
for lproj_dir in $LPROJ_DIRS; do
    lang=$(basename "$lproj_dir" .lproj)
    strings_file="$lproj_dir/Localizable.strings"
    
    if [ ! -f "$strings_file" ]; then
        echo -e "${YELLOW}WARNING: No Localizable.strings in $lang.lproj${NC}"
        continue
    fi
    
    if [ "$lang" = "en" ]; then
        continue  # Skip reference file
    fi
    
    echo "Checking $lang.lproj..."
    
    LANG_KEYS=$(extract_keys "$strings_file")
    LANG_COUNT=$(echo "$LANG_KEYS" | wc -l | tr -d ' ')
    
    # Find missing keys (in English but not in this language)
    MISSING=""
    while IFS= read -r key; do
        if ! echo "$LANG_KEYS" | grep -qxF "$key"; then
            MISSING="$MISSING$key\n"
            ((MISSING_COUNT++)) || true
        fi
    done <<< "$REFERENCE_KEYS"
    
    # Find extra keys (in this language but not in English)
    EXTRA=""
    while IFS= read -r key; do
        if ! echo "$REFERENCE_KEYS" | grep -qxF "$key"; then
            EXTRA="$EXTRA$key\n"
            ((EXTRA_COUNT++)) || true
        fi
    done <<< "$LANG_KEYS"
    
    # Report findings
    if [ -n "$MISSING" ] && [ "$MISSING" != "\n" ]; then
        echo -e "  ${RED}MISSING keys in $lang:${NC}"
        echo -e "$MISSING" | while IFS= read -r key; do
            if [ -n "$key" ]; then
                echo "    - $key"
            fi
        done
    fi
    
    if [ -n "$EXTRA" ] && [ "$EXTRA" != "\n" ]; then
        echo -e "  ${YELLOW}EXTRA keys in $lang (not in English):${NC}"
        echo -e "$EXTRA" | while IFS= read -r key; do
            if [ -n "$key" ]; then
                echo "    - $key"
            fi
        done
    fi
    
    if [ -z "$MISSING" ] || [ "$MISSING" = "\n" ]; then
        if [ -z "$EXTRA" ] || [ "$EXTRA" = "\n" ]; then
            echo -e "  ${GREEN}✓ All $LANG_COUNT keys present${NC}"
        fi
    fi
    echo ""
done

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="

if [ $MISSING_COUNT -gt 0 ]; then
    echo -e "${RED}Missing translations: $MISSING_COUNT${NC}"
fi

if [ $EXTRA_COUNT -gt 0 ]; then
    echo -e "${YELLOW}Extra keys (unused): $EXTRA_COUNT${NC}"
fi

if [ $MISSING_COUNT -eq 0 ] && [ $EXTRA_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ All localizations are complete and synchronized!${NC}"
fi

echo ""

# Determine exit code based on configuration
# Check if we're in Release mode (set by Xcode build)
if [ "$CONFIGURATION" = "Release" ]; then
    if [ $MISSING_COUNT -gt 0 ]; then
        echo -e "${RED}BUILD FAILED: Missing translations in Release build${NC}"
        echo "Add the missing keys to continue."
        exit 1
    fi
else
    # Debug mode or running manually - just warn
    if [ $MISSING_COUNT -gt 0 ]; then
        echo -e "${YELLOW}WARNING: Missing translations (Debug mode - build continues)${NC}"
    fi
fi

echo -e "${GREEN}Validation complete.${NC}"
exit 0
