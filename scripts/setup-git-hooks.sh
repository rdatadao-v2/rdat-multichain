#!/bin/bash

echo "Setting up Git hooks to prevent committing sensitive files..."

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Checking for sensitive files..."

# Patterns to check for sensitive content
SENSITIVE_PATTERNS=(
    "PRIVATE_KEY"
    "private_key"
    "privateKey"
    "0x[a-fA-F0-9]{64}"  # Ethereum private key pattern
    "-----BEGIN"         # PEM key pattern
)

# Files to check
SENSITIVE_FILES=(
    ".env"
    ".env.local"
    ".env.production"
    "*.key"
    "*.pem"
    "*.pk"
    "*-keypair.json"
    "wallet.json"
    "deployer.json"
)

# Check if any sensitive files are being committed
FOUND_SENSITIVE=0

# Check for sensitive files
for pattern in "${SENSITIVE_FILES[@]}"; do
    files=$(git diff --cached --name-only | grep -E "$pattern" || true)
    if [ ! -z "$files" ]; then
        echo -e "${RED}❌ ERROR: Attempting to commit sensitive file: $files${NC}"
        FOUND_SENSITIVE=1
    fi
done

# Check for sensitive patterns in staged files
for file in $(git diff --cached --name-only); do
    if [ -f "$file" ]; then
        for pattern in "${SENSITIVE_PATTERNS[@]}"; do
            if grep -q "$pattern" "$file"; then
                echo -e "${YELLOW}⚠️  WARNING: File '$file' may contain sensitive data (pattern: $pattern)${NC}"
                echo "Please review this file carefully before committing."

                # For actual private keys, block the commit
                if [[ "$pattern" == "0x[a-fA-F0-9]{64}" ]] && grep -qE "0x[a-fA-F0-9]{64}" "$file"; then
                    echo -e "${RED}❌ ERROR: File '$file' appears to contain a private key!${NC}"
                    FOUND_SENSITIVE=1
                fi
            fi
        done
    fi
done

if [ $FOUND_SENSITIVE -eq 1 ]; then
    echo -e "${RED}"
    echo "========================================="
    echo "  COMMIT BLOCKED: Sensitive data detected"
    echo "========================================="
    echo -e "${NC}"
    echo "Please remove sensitive files/data before committing."
    echo "If this is a false positive, you can bypass with: git commit --no-verify"
    echo "(But please double-check first!)"
    exit 1
else
    echo -e "${GREEN}✅ No sensitive files detected${NC}"
fi
EOF

# Make the hook executable
chmod +x .git/hooks/pre-commit

echo "✅ Git hooks installed successfully!"
echo ""
echo "The pre-commit hook will now:"
echo "  • Check for .env and other sensitive files"
echo "  • Scan for private key patterns"
echo "  • Block commits containing sensitive data"
echo ""
echo "To bypass in emergencies (NOT RECOMMENDED):"
echo "  git commit --no-verify"