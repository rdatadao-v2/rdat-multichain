#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Running Security Check...${NC}"
echo "========================================="

ISSUES_FOUND=0

# Check 1: Look for .env files
echo -e "\n${BLUE}1. Checking for .env files...${NC}"
env_files=$(find . -name ".env*" -not -name ".env.example" -type f 2>/dev/null | grep -v node_modules | grep -v .git)
if [ ! -z "$env_files" ]; then
    echo -e "${YELLOW}⚠️  Found .env files:${NC}"
    echo "$env_files"
    echo -e "${YELLOW}   Make sure these are in .gitignore!${NC}"
    ISSUES_FOUND=1
else
    echo -e "${GREEN}✅ No .env files found (except .env.example)${NC}"
fi

# Check 2: Look for private key patterns in files
echo -e "\n${BLUE}2. Scanning for private key patterns...${NC}"
suspicious_files=$(grep -r "0x[a-fA-F0-9]\{64\}" . --exclude-dir=node_modules --exclude-dir=.git --exclude="*.md" 2>/dev/null | head -5)
if [ ! -z "$suspicious_files" ]; then
    echo -e "${RED}❌ Potential private keys found:${NC}"
    echo "$suspicious_files"
    ISSUES_FOUND=1
else
    echo -e "${GREEN}✅ No private key patterns found${NC}"
fi

# Check 3: Verify .gitignore is working
echo -e "\n${BLUE}3. Verifying .gitignore...${NC}"
if [ -f .env ]; then
    git_check=$(git check-ignore .env 2>&1)
    if [ "$?" -eq 0 ]; then
        echo -e "${GREEN}✅ .env is properly ignored by git${NC}"
    else
        echo -e "${RED}❌ .env exists but is NOT ignored by git!${NC}"
        ISSUES_FOUND=1
    fi
fi

# Check 4: Look for wallet files
echo -e "\n${BLUE}4. Checking for wallet files...${NC}"
wallet_files=$(find . -name "*wallet*.json" -o -name "*keypair*.json" -o -name "*.key" -o -name "*.pk" 2>/dev/null | grep -v node_modules | grep -v .git)
if [ ! -z "$wallet_files" ]; then
    echo -e "${RED}❌ Found wallet/key files:${NC}"
    echo "$wallet_files"
    echo -e "${RED}   These should be removed or added to .gitignore!${NC}"
    ISSUES_FOUND=1
else
    echo -e "${GREEN}✅ No wallet/key files found${NC}"
fi

# Check 5: Check git status for sensitive files
echo -e "\n${BLUE}5. Checking git status...${NC}"
sensitive_staged=$(git status --porcelain 2>/dev/null | grep -E "\.env|\.key|\.pk|wallet|private" | grep -v ".env.example")
if [ ! -z "$sensitive_staged" ]; then
    echo -e "${RED}❌ Sensitive files in git:${NC}"
    echo "$sensitive_staged"
    ISSUES_FOUND=1
else
    echo -e "${GREEN}✅ No sensitive files tracked by git${NC}"
fi

# Check 6: Verify git hooks are installed
echo -e "\n${BLUE}6. Checking git hooks...${NC}"
if [ -f .git/hooks/pre-commit ]; then
    echo -e "${GREEN}✅ Pre-commit hook is installed${NC}"
else
    echo -e "${YELLOW}⚠️  Pre-commit hook not installed${NC}"
    echo "   Run: ./scripts/setup-git-hooks.sh"
fi

# Final report
echo ""
echo "========================================="
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ SECURITY CHECK PASSED!${NC}"
    echo "No critical security issues found."
else
    echo -e "${RED}❌ SECURITY ISSUES FOUND!${NC}"
    echo "Please address the issues above before proceeding."
    echo ""
    echo "Quick fixes:"
    echo "  1. Ensure all sensitive files are in .gitignore"
    echo "  2. Remove any committed sensitive files from git history"
    echo "  3. Run: ./scripts/setup-git-hooks.sh"
    echo "  4. Never commit private keys or passwords"
fi
echo "========================================="

exit $ISSUES_FOUND