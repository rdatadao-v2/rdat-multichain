# 🔐 Security Guidelines for RDAT Multichain Deployment

## ⚠️ CRITICAL: Private Key Management

### NEVER DO THIS:
- ❌ **NEVER** commit private keys to git
- ❌ **NEVER** share private keys in Discord, Telegram, Slack, etc.
- ❌ **NEVER** paste private keys in online tools or websites
- ❌ **NEVER** store private keys in plain text files
- ❌ **NEVER** use example/test private keys for mainnet
- ❌ **NEVER** reuse private keys across projects

### ALWAYS DO THIS:
- ✅ Use hardware wallets (Ledger/Trezor) for mainnet deployments
- ✅ Use secure key management systems (AWS KMS, HashiCorp Vault)
- ✅ Keep private keys in encrypted storage
- ✅ Use different keys for development and production
- ✅ Rotate keys regularly
- ✅ Use multisig wallets for contract ownership

## 📁 File Security Checklist

### Files That Should NEVER Be Committed:
```
.env                    # Environment variables with keys
.env.*                  # Any env variant (except .env.example)
*.key                   # Private key files
*.pk                    # Private key files
*.privatekey           # Private key files
*_key.json             # JSON keystore files
*-keypair.json         # Solana keypair files
solana-deployer.json   # Solana wallet file
deployer.json          # Deployer wallet file
wallet.json            # Any wallet file
keystore/              # Keystore directories
secrets/               # Secret directories
private/               # Private directories
```

### Before Every Commit:
1. Run `git status` to check staged files
2. Ensure no sensitive files are included
3. Double-check `.gitignore` is working:
   ```bash
   git check-ignore .env
   # Should output: .env (meaning it's ignored)
   ```

## 🚨 If You Accidentally Commit a Private Key

**IMMEDIATE ACTIONS:**
1. **Transfer all funds** from the compromised wallet immediately
2. **Revoke all permissions** granted to the compromised address
3. **Rotate the key** - generate a new one
4. **Remove from git history**:
   ```bash
   # DO NOT just delete the file - it's still in git history!
   # Use BFG Repo-Cleaner or git filter-branch
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch PATH_TO_FILE" \
     --prune-empty --tag-name-filter cat -- --all
   ```
5. **Force push** to overwrite history (coordinate with team)
6. **Alert the team** about the incident

## 🛡️ Deployment Security Best Practices

### 1. Use a Deployment Checklist
- [ ] All `.env` files are in `.gitignore`
- [ ] No private keys in code or comments
- [ ] Hardware wallet ready for mainnet
- [ ] Multisig addresses verified
- [ ] Contract ownership will be transferred post-deployment

### 2. Secure Environment Setup
```bash
# Create .env from template
cp .env.example .env

# Set restrictive permissions
chmod 600 .env

# Never edit .env in online IDEs (GitHub Codespaces, Gitpod, etc.)
```

### 3. Use Environment Variables Safely
```javascript
// ❌ BAD: Hardcoded key
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

// ✅ GOOD: Environment variable
const privateKey = process.env.DEPLOYER_PRIVATE_KEY;
if (!privateKey) throw new Error("Missing DEPLOYER_PRIVATE_KEY");
```

### 4. Verification Without Exposing Keys
When verifying contracts:
- Use read-only API keys when possible
- Never include constructor arguments with sensitive data
- Use separate verification scripts that don't require private keys

## 🔍 Security Audit Checklist

Before mainnet deployment:
- [ ] All private keys are secured
- [ ] `.gitignore` is properly configured
- [ ] No sensitive data in commit history
- [ ] Multisig wallets configured
- [ ] Emergency pause mechanisms tested
- [ ] Contract ownership transfer plan ready
- [ ] Team members trained on security practices

## 📞 Emergency Contacts

If you suspect a security breach:
1. **Immediate**: Transfer funds to secure wallet
2. **Alert**: Team lead and security officer
3. **Document**: What happened, when, and actions taken
4. **Review**: How to prevent similar incidents

## 🎓 Security Training Resources

- [Ethereum Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)
- [OpenZeppelin Security](https://www.openzeppelin.com/security)
- [Hardware Wallet Guide](https://www.ledger.com/academy)

---

**Remember**: It only takes one leaked private key to lose everything. When in doubt, ask for help!