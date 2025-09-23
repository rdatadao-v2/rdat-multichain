# 🔑 Wallet Information for RDAT Multichain Deployment

## ⚠️ SECURITY NOTICE
**THIS FILE CONTAINS PUBLIC ADDRESSES ONLY - NO PRIVATE KEYS**
Private keys and seed phrases should NEVER be stored in this repository.

## Deployment Wallets

### 1. EVM Chains (Vana & Base)
- **Address**: `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB`
- **Private Key Location**: Stored securely offline (from rdatadao-contracts)
- **Used For**: Deploying contracts on Vana and Base mainnet

### 2. Solana
- **Address**: `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM`
- **Keypair File**: `./solana-deployer.json` (gitignored, local only)
- **Used For**: Deploying Solana OFT program

## 🔐 Seed Phrase Storage

⚠️ **CRITICAL**: The seed phrase for the Solana wallet should be:
1. Written down on paper
2. Stored in a secure physical location (safe/vault)
3. Never stored digitally in plain text
4. Never shared via email, Discord, Telegram, etc.
5. Backed up in at least 2 secure locations

## 💰 Funding Requirements

| Wallet | Network | Amount Needed | Status |
|--------|---------|---------------|--------|
| `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB` | Vana | 1 VANA | ⏳ Pending |
| `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB` | Base | 0.02 ETH | ⏳ Pending |
| `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM` | Solana | 2.5 SOL | ⏳ Pending |

## 📋 Balance Check Commands

```bash
# Check Solana balance
solana balance FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM --url mainnet-beta

# Check Vana balance (using cast from Foundry)
cast balance 0x58eCB94e6F5e6521228316b55c465ad2A2938FbB --rpc-url https://rpc.vana.org

# Check Base balance
cast balance 0x58eCB94e6F5e6521228316b55c465ad2A2938FbB --rpc-url https://mainnet.base.org
```

## 🚨 Security Reminders

1. **solana-deployer.json** file:
   - ✅ Is gitignored
   - ✅ Has restricted permissions (600)
   - ⚠️ Should be backed up securely
   - ⚠️ Should be deleted after deployment and keys rotated

2. **After Deployment**:
   - Transfer contract ownership to multisigs
   - Consider rotating deployment keys
   - Secure or destroy deployment wallets

## 📝 Notes

- The Solana wallet was generated on: 2024-09-23
- All deployment wallets are single-signature (not multisig)
- Production contracts will be transferred to multisig ownership post-deployment