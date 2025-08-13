#!/bin/bash

# CRDB Zoho Converter - Complete Linux/macOS Cleanup Script
# This script removes all traces of CRDB Zoho Converter from your system

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if script is run with force flag
FORCE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -f, --force     Skip confirmation prompt"
            echo "  -v, --verbose   Show detailed output"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "========================================"
echo "CRDB Zoho Converter - Linux/macOS Cleanup"
echo "========================================"
echo ""

if [ "$FORCE" = false ]; then
    warning "This script will remove ALL traces of CRDB Zoho Converter from your system."
    warning "This includes:"
    warning "  - pipx installations"
    warning "  - Virtual environments"
    warning "  - Build artifacts"
    warning "  - User-specific files"
    echo ""
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Cleanup cancelled by user."
        exit 0
    fi
fi

info "Starting cleanup process..."

# 1. Remove pipx installation
info "Removing pipx installation..."
if command -v pipx &> /dev/null; then
    if pipx list | grep -q "crdb-zoho-converter"; then
        pipx uninstall crdb-zoho-converter
        success "Removed pipx installation: crdb-zoho-converter"
    else
        info "No pipx installation found for crdb-zoho-converter"
    fi
else
    info "pipx not found, skipping pipx cleanup"
fi

# 2. Remove virtual environment
info "Removing virtual environment..."
if [ -d ".venv" ]; then
    rm -rf .venv
    success "Removed virtual environment: .venv"
else
    info "Virtual environment not found: .venv"
fi

# 3. Remove build artifacts
info "Removing build artifacts..."
build_items=("dist" "build" "*.spec" "__pycache__" "*.pyc" "*.pyo")

for item in "${build_items[@]}"; do
    if [ -e "$item" ]; then
        if [ -d "$item" ]; then
            rm -rf "$item"
            success "Removed build directory: $item"
        else
            rm -f "$item"
            success "Removed build file: $item"
        fi
    fi
done

# 4. Remove user-specific files
info "Removing user-specific files..."
user_paths=(
    "$HOME/bin/crdb-convert"
    "$HOME/bin/crdb-inspect"
    "$HOME/.local/bin/crdb-convert"
    "$HOME/.local/bin/crdb-inspect"
    "$HOME/.config/crdb-zoho-converter"
    "$HOME/.cache/crdb-zoho-converter"
)

for user_path in "${user_paths[@]}"; do
    if [ -e "$user_path" ]; then
        if [ -d "$user_path" ]; then
            rm -rf "$user_path"
            success "Removed user directory: $user_path"
        else
            rm -f "$user_path"
            success "Removed user file: $user_path"
        fi
    fi
done

# 5. Remove desktop files and shortcuts
info "Removing desktop files and shortcuts..."
desktop_paths=(
    "$HOME/Desktop/crdb-convert.desktop"
    "$HOME/Desktop/crdb-inspect.desktop"
    "$HOME/.local/share/applications/crdb-convert.desktop"
    "$HOME/.local/share/applications/crdb-inspect.desktop"
    "/usr/share/applications/crdb-convert.desktop"
    "/usr/share/applications/crdb-inspect.desktop"
)

for desktop_path in "${desktop_paths[@]}"; do
    if [ -e "$desktop_path" ]; then
        rm -f "$desktop_path"
        success "Removed desktop file: $desktop_path"
    fi
done

# 6. Remove from PATH in shell configuration files
info "Cleaning shell configuration files..."
shell_configs=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.bash_login"
)

for config_file in "${shell_configs[@]}"; do
    if [ -f "$config_file" ]; then
        # Check if file contains CRDB-related PATH modifications
        if grep -q "CRDB\|crdb\|Zoho\|zoho" "$config_file"; then
            # Create backup
            cp "$config_file" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Remove CRDB-related lines
            sed -i '/CRDB\|crdb\|Zoho\|zoho/d' "$config_file"
            
            success "Cleaned shell configuration: $config_file"
            info "Backup created: ${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
    fi
done

# 7. Remove from system PATH (requires sudo)
info "Cleaning system PATH..."
if [ -w "/etc/environment" ]; then
    if grep -q "CRDB\|crdb\|Zoho\|zoho" "/etc/environment"; then
        sed -i '/CRDB\|crdb\|Zoho\|zoho/d' "/etc/environment"
        success "Cleaned system environment file"
    fi
else
    info "System environment file not writable, skipping system PATH cleanup"
fi

# 8. Remove any remaining Python packages
info "Removing Python packages..."
if command -v pip &> /dev/null; then
    if pip list | grep -q "crdb-zoho-converter"; then
        pip uninstall -y crdb-zoho-converter
        success "Removed Python package: crdb-zoho-converter"
    fi
fi

if command -v pip3 &> /dev/null; then
    if pip3 list | grep -q "crdb-zoho-converter"; then
        pip3 uninstall -y crdb-zoho-converter
        success "Removed Python3 package: crdb-zoho-converter"
    fi
fi

# 9. Final verification
echo ""
info "Performing final verification..."

remaining_items=()
check_paths=(
    ".venv"
    "dist"
    "build"
    "$HOME/bin/crdb-convert"
    "$HOME/.local/bin/crdb-convert"
)

for check_path in "${check_paths[@]}"; do
    if [ -e "$check_path" ]; then
        remaining_items+=("$check_path")
    fi
done

if [ ${#remaining_items[@]} -eq 0 ]; then
    success "All CRDB Zoho Converter files have been successfully removed!"
else
    warning "Some items could not be removed:"
    for item in "${remaining_items[@]}"; do
        warning "  - $item"
    done
    info "You may need to manually remove these items or restart your terminal."
fi

# 10. Check if commands are still available
info "Checking if commands are still available..."
if command -v crdb-convert &> /dev/null; then
    warning "crdb-convert command is still available in PATH"
    which crdb-convert
else
    success "crdb-convert command not found in PATH"
fi

if command -v crdb-inspect &> /dev/null; then
    warning "crdb-inspect command is still available in PATH"
    which crdb-inspect
else
    success "crdb-inspect command not found in PATH"
fi

echo ""
echo "========================================"
echo "Cleanup process completed!"
echo "========================================"

info "It's recommended to restart your terminal to ensure all PATH changes take effect."
info "If you installed via system package manager, you may need to use the appropriate uninstall command."

# Show what was cleaned
if [ "$VERBOSE" = true ]; then
    echo ""
    info "Verbose mode: Summary of cleaned items:"
    info "  - pipx installations"
    info "  - Virtual environments"
    info "  - Build artifacts (dist/, build/, *.spec)"
    info "  - User-specific files and directories"
    info "  - Desktop shortcuts and application files"
    info "  - Shell configuration modifications"
    info "  - Python packages"
fi
