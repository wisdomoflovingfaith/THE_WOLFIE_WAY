#!/bin/bash
# File: validate_the_wolfie_way.sh
# Purpose: Comprehensive validation of THE_WOLFIE_WAY standards
# Author: Captain WOLFIE (Eric Robin Gerdes) - 2025-09-27
# Usage: ./validate_the_wolfie_way.sh [directory]
# Mission Alignment: Ensures compliance with AGAPE principles

LOG_FILE="validation_results_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="${1:-.}"

echo "🌺 THE_WOLFIE_WAY Validation Started: $(date)" | tee "$LOG_FILE"
echo "Target Directory: $TARGET_DIR" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# Function to log results
log_result() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Check 13-header compliance
log_result "📋 Checking 13-header compliance..."
find "$TARGET_DIR" -name "*.md" -o -name "*.md.txt" | while read -r file; do
    REQUIRED_HEADERS="WHO WHAT WHERE WHEN WHY HOW PURPOSE KEY TITLE ID SUPERPOSITIONALLY DATE STATUS"
    MISSING_HEADERS=""
    
    for header in $REQUIRED_HEADERS; do
        if ! grep -q "**$header**:" "$file"; then
            MISSING_HEADERS="$MISSING_HEADERS $header"
        fi
    done
    
    if [ -n "$MISSING_HEADERS" ]; then
        log_result "❌ Missing headers in $file:$MISSING_HEADERS"
    else
        log_result "✅ All headers present in $file"
    fi
done

# Check README.md presence in directories
log_result "📁 Checking README.md presence in directories..."
find "$TARGET_DIR" -type d -not -path "*/.*" | while read -r dir; do
    if [ ! -f "$dir/README.md" ]; then
        log_result "❌ Missing README.md in directory: $dir"
    else
        log_result "✅ README.md present in directory: $dir"
    fi
done

# Check .md.txt format compliance
log_result "📱 Checking .md.txt format compliance..."
find "$TARGET_DIR" -name "*.md.txt" -size +500k -exec echo "⚠️  Large .md.txt file: {}" \; | tee -a "$LOG_FILE"

# Check file size compliance
log_result "📏 Checking file size compliance..."
find "$TARGET_DIR" -name "*.md.txt" | while read -r file; do
    SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    if [ "$SIZE" -gt 512000 ]; then
        log_result "⚠️  Large file: $file ($SIZE bytes)"
    fi
done

# Summary
log_result "========================================"
log_result "🌺 THE_WOLFIE_WAY Validation Completed: $(date)"
log_result "Results saved to: $LOG_FILE"

echo "Validation complete. See $LOG_FILE for detailed results."
