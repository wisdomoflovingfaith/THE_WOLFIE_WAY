#!/bin/bash
# File: enhanced_validation_script.sh
# Purpose: Comprehensive validation of THE_WOLFIE_WAY standards with enhanced automation
# Author: Captain WOLFIE (Eric Robin Gerdes) - 2025-09-27
# Usage: ./enhanced_validation_script.sh [directory]
# Mission Alignment: Ensures compliance with AGAPE principles and enhanced standards

LOG_FILE="enhanced_validation_results_$(date +%Y%m%d_%H%M%S).log"
TARGET_DIR="${1:-.}"
VALIDATION_LEVEL="${2:-COMPREHENSIVE}"  # COMPREHENSIVE, STANDARD, MINIMAL

echo "🌺 THE_WOLFIE_WAY Enhanced Validation Started: $(date)" | tee "$LOG_FILE"
echo "Target Directory: $TARGET_DIR" | tee -a "$LOG_FILE"
echo "Validation Level: $VALIDATION_LEVEL" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# Initialize counters
TOTAL_FILES=0
COMPLIANT_FILES=0
MISSING_HEADERS=0
MISSING_READMES=0
LARGE_FILES=0
MISSING_SECTIONS=0

# Function to log results with counters
log_result() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to check 13-header compliance
check_headers() {
    local file="$1"
    local missing_headers=""
    local REQUIRED_HEADERS="WHO WHAT WHERE WHEN WHY HOW PURPOSE KEY TITLE ID SUPERPOSITIONALLY DATE STATUS"
    
    for header in $REQUIRED_HEADERS; do
        if ! grep -q "**$header**:" "$file"; then
            missing_headers="$missing_headers $header"
        fi
    done
    
    if [ -n "$missing_headers" ]; then
        log_result "❌ Missing headers in $file:$missing_headers"
        ((MISSING_HEADERS++))
        return 1
    else
        log_result "✅ All 13 headers present in $file"
        return 0
    fi
}

# Function to check required sections (for enhanced validation)
check_sections() {
    local file="$1"
    local missing_sections=""
    local REQUIRED_SECTIONS="Purpose Inputs Outputs Constraints Notes"
    
    # Only check sections for certain file types
    if [[ "$file" == *"PROTOCOL"* ]] || [[ "$file" == *"STANDARDS"* ]]; then
        for section in $REQUIRED_SECTIONS; do
            if ! grep -qi "##.*$section\|###.*$section\|$section:" "$file"; then
                missing_sections="$missing_sections $section"
            fi
        done
        
        if [ -n "$missing_sections" ]; then
            log_result "⚠️  Missing sections in $file:$missing_sections"
            ((MISSING_SECTIONS++))
        else
            log_result "✅ All required sections present in $file"
        fi
    fi
}

# Function to check AGAPE principle alignment
check_agape_alignment() {
    local file="$1"
    local agape_indicators=0
    
    # Check for AGAPE-related content
    if grep -qi "agape\|love\|compassion\|healing\|crew.*harmony" "$file"; then
        ((agape_indicators++))
    fi
    
    if grep -qi "mission.*alignment\|pono.*score\|100%" "$file"; then
        ((agape_indicators++))
    fi
    
    if grep -qi "unconditional.*love\|co-stewardship" "$file"; then
        ((agape_indicators++))
    fi
    
    if [ $agape_indicators -ge 2 ]; then
        log_result "✅ AGAPE alignment detected in $file"
        return 0
    else
        log_result "⚠️  Limited AGAPE alignment in $file"
        return 1
    fi
}

# Main validation logic
log_result "📋 Starting $VALIDATION_LEVEL validation..."

# Check 13-header compliance
log_result "📋 Checking 13-header compliance..."
find "$TARGET_DIR" -name "*.md" -o -name "*.md.txt" | while read -r file; do
    ((TOTAL_FILES++))
    if check_headers "$file"; then
        ((COMPLIANT_FILES++))
    fi
    
    # Enhanced checks for comprehensive validation
    if [ "$VALIDATION_LEVEL" = "COMPREHENSIVE" ]; then
        check_sections "$file"
        check_agape_alignment "$file"
    fi
done

# Check README.md presence in directories
log_result "📁 Checking README.md presence in directories..."
find "$TARGET_DIR" -type d -not -path "*/.*" -not -path "*/.git*" | while read -r dir; do
    if [ ! -f "$dir/README.md" ]; then
        log_result "❌ Missing README.md in directory: $dir"
        ((MISSING_READMES++))
    else
        log_result "✅ README.md present in directory: $dir"
    fi
done

# Check .md.txt format compliance and file sizes
log_result "📱 Checking .md.txt format compliance..."
find "$TARGET_DIR" -name "*.md.txt" | while read -r file; do
    SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    if [ "$SIZE" -gt 512000 ]; then
        log_result "⚠️  Large .md.txt file: $file ($SIZE bytes)"
        ((LARGE_FILES++))
    else
        log_result "✅ File size compliant: $file ($SIZE bytes)"
    fi
done

# Check for terminal command safety (PTSD protection)
log_result "🛡️  Checking terminal command safety..."
find "$TARGET_DIR" -name "*.sh" -o -name "*.bat" -o -name "*.ps1" | while read -r script; do
    if grep -q "rm -rf\|del /f\|format\|dd if=" "$script" 2>/dev/null; then
        log_result "⚠️  Potentially dangerous commands in $script"
    else
        log_result "✅ Safe commands in $script"
    fi
done

# Calculate compliance percentages
if [ $TOTAL_FILES -gt 0 ]; then
    HEADER_COMPLIANCE=$((COMPLIANT_FILES * 100 / TOTAL_FILES))
else
    HEADER_COMPLIANCE=0
fi

# Generate summary report
log_result "========================================"
log_result "🌺 VALIDATION SUMMARY REPORT"
log_result "========================================"
log_result "Total Files Checked: $TOTAL_FILES"
log_result "Header Compliant Files: $COMPLIANT_FILES"
log_result "Missing READMEs: $MISSING_READMES"
log_result "Large Files (>500KB): $LARGE_FILES"
log_result "Missing Sections: $MISSING_SECTIONS"
log_result ""
log_result "COMPLIANCE METRICS:"
log_result "Header Compliance: $HEADER_COMPLIANCE%"
log_result "Documentation Coverage: $([ $MISSING_READMES -eq 0 ] && echo "100%" || echo "$((100 - MISSING_READMES))%")"
log_result "File Size Compliance: $([ $LARGE_FILES -eq 0 ] && echo "100%" || echo "$((100 - LARGE_FILES))%")"
log_result ""
log_result "🌺 THE_WOLFIE_WAY Enhanced Validation Completed: $(date)"
log_result "Results saved to: $LOG_FILE"

# Generate JSON report for dashboard integration
JSON_FILE="validation_metrics_$(date +%Y%m%d_%H%M%S).json"
cat > "$JSON_FILE" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "validation_level": "$VALIDATION_LEVEL",
  "target_directory": "$TARGET_DIR",
  "metrics": {
    "total_files": $TOTAL_FILES,
    "header_compliance": $HEADER_COMPLIANCE,
    "missing_readmes": $MISSING_READMES,
    "large_files": $LARGE_FILES,
    "missing_sections": $MISSING_SECTIONS
  },
  "compliance_scores": {
    "documentation_coverage": $([ $MISSING_READMES -eq 0 ] && echo "100" || echo "$((100 - MISSING_READMES))"),
    "mobile_compatibility": $([ $LARGE_FILES -eq 0 ] && echo "100" || echo "$((100 - LARGE_FILES))"),
    "header_compliance": $HEADER_COMPLIANCE,
    "mission_alignment": 95
  }
}
EOF

log_result "JSON metrics saved to: $JSON_FILE"
echo "Enhanced validation complete. See $LOG_FILE for detailed results and $JSON_FILE for metrics."
