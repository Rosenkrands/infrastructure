#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo -e "Please run: sudo ./setup.sh"
    exit 1
fi

# Load environment variables
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    exit 1
fi

source "$SCRIPT_DIR/.env"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Infrastructure Setup Orchestrator    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Track success/failure
SUCCESS_COUNT=0
FAIL_COUNT=0
SCRIPTS_RUN=()

# Function to run a setup script
run_setup_script() {
    local script_name=$1
    local script_path="$SCRIPT_DIR/scripts/$script_name"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Running: $script_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Error: Script not found: $script_path${NC}"
        ((FAIL_COUNT++))
        SCRIPTS_RUN+=("❌ $script_name - NOT FOUND")
        return 1
    fi
    
    if [ ! -x "$script_path" ]; then
        echo -e "${YELLOW}Making script executable...${NC}"
        chmod +x "$script_path"
    fi
    
    # Run the script with environment variables
    if bash "$script_path"; then
        ((SUCCESS_COUNT++))
        SCRIPTS_RUN+=("✓ $script_name - SUCCESS")
        echo -e "${GREEN}✓ $script_name completed successfully${NC}"
    else
        ((FAIL_COUNT++))
        SCRIPTS_RUN+=("❌ $script_name - FAILED")
        echo -e "${RED}✗ $script_name failed${NC}"
        return 1
    fi
    
    echo ""
}

# Run setup scripts
# Add more scripts here as needed
run_setup_script "change-port-for-ssh.sh" || true
run_setup_script "add-gh-actions-user.sh" || true

# Add future setup scripts here:
# run_setup_script "firewall.sh"
# run_setup_script "docker.sh"
# run_setup_script "monitoring.sh"

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Setup Summary                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

for result in "${SCRIPTS_RUN[@]}"; do
    echo -e "  $result"
done

echo ""
echo -e "Total: ${GREEN}$SUCCESS_COUNT succeeded${NC}, ${RED}$FAIL_COUNT failed${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    All Setup Scripts Completed! 🎉     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   Some Setup Scripts Failed            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    exit 1
fi
