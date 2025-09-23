# RDAT Multichain Deployment Guide

> **🎉 STATUS: DEPLOYMENT COMPLETE - BRIDGE OPERATIONAL**
>
> This guide documents the deployment process that was successfully executed on September 23rd, 2025.

## Deployment Summary

### Deployed Contracts
- **Vana OFT Adapter**: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58` ✅
- **Base RDAT OFT**: `0x77D2713972af12F1E3EF39b5395bfD65C862367C` ✅
- **Status**: Bridge fully operational

---

## Historical Reference: Pre-Deployment Checklist

### Environment Setup
- [✓] Foundry installed and updated to latest version
- [✓] `.env` file configured in `/foundry` directory
- [✓] Private key secured with proper permissions
- [✓] Git hooks enabled to prevent key commits

### Wallet Funding
- [✓] Deployer wallet: `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB`
- [✓] Vana: Funded with 1.22 VANA
- [✓] Base: Funded with 0.02 ETH
- [✓] Solana wallet (Phase 2): `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM`

### Verification
- [✓] Existing RDAT token verified at `0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E`
- [✓] Vana endpoint verified at `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa`
- [✓] Base endpoint verified at `0x1a44076050125825900e736c501f859c50fE728c`
- [✓] Total supply confirmed as 100M RDAT

## 🧪 Testing Phase

### Local Testing
```bash
cd foundry

# Run fork tests
forge test --fork-url https://rpc.vana.org -vvv

# Run deployment simulation
forge script script/SimulateDeployment.s.sol --fork-url https://rpc.vana.org -vvv

# Estimate gas costs
forge script script/DeployVanaAdapter.s.sol --rpc-url https://rpc.vana.org --estimate-gas
forge script script/DeployBaseOFT.s.sol --rpc-url https://mainnet.base.org --estimate-gas
```

- [ ] All fork tests passing
- [ ] Deployment simulation successful
- [ ] Gas estimates recorded

## 🚀 Deployment Phase

### Step 1: Deploy Vana OFT Adapter
```bash
forge script script/DeployVanaAdapter.s.sol \
  --rpc-url https://rpc.vana.org \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvv
```
- [ ] Transaction confirmed
- [ ] Contract verified on Vanascan
- [ ] Address recorded: `_____________________`

### Step 2: Deploy Base OFT
```bash
forge script script/DeployBaseOFT.s.sol \
  --rpc-url https://mainnet.base.org \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvv
```
- [ ] Transaction confirmed
- [ ] Contract verified on Basescan
- [ ] Address recorded: `_____________________`

### Step 3: Update Environment Variables
```bash
# Update .env file
VANA_ADAPTER_ADDRESS=<deployed_adapter_address>
BASE_OFT_ADDRESS=<deployed_oft_address>
```
- [ ] `.env` updated with deployed addresses

### Step 4: Wire Contracts - Vana Side
```bash
forge script script/WireContracts.s.sol \
  --rpc-url https://rpc.vana.org \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  -vvv
```
- [ ] Vana adapter peer set to Base OFT
- [ ] Transaction confirmed

### Step 5: Wire Contracts - Base Side
```bash
forge script script/WireContracts.s.sol \
  --rpc-url https://mainnet.base.org \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  -vvv
```
- [ ] Base OFT peer set to Vana adapter
- [ ] Transaction confirmed

## 🔍 Verification Phase

### Peer Configuration
```bash
# Verify Vana adapter trusts Base
cast call $VANA_ADAPTER_ADDRESS "peers(uint32)" 30184 --rpc-url https://rpc.vana.org

# Verify Base OFT trusts Vana
cast call $BASE_OFT_ADDRESS "peers(uint32)" 30330 --rpc-url https://mainnet.base.org
```
- [ ] Vana → Base peer verified
- [ ] Base → Vana peer verified

### Contract State
- [ ] Vana adapter owner is deployer (before transfer)
- [ ] Base OFT owner is deployer (before transfer)
- [ ] Token symbols match (RDAT)
- [ ] Decimals match (18)

## 🧨 Test Transfer

### Small Amount Test (0.001 RDAT)
1. [ ] Approve adapter to spend RDAT
2. [ ] Estimate bridge fees
3. [ ] Execute bridge transaction Vana → Base
4. [ ] Verify receipt on Base
5. [ ] Execute return transaction Base → Vana
6. [ ] Verify tokens returned to Vana

### Monitoring
- [ ] Check LayerZero Scanner: https://layerzeroscan.com/
- [ ] Verify on Vanascan
- [ ] Verify on Basescan

## 🔐 Ownership Transfer

### Transfer Vana Adapter to Multisig
```bash
cast send $VANA_ADAPTER_ADDRESS \
  "transferOwnership(address)" \
  0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF \
  --rpc-url https://rpc.vana.org \
  --private-key $DEPLOYER_PRIVATE_KEY
```
- [ ] Ownership transfer initiated
- [ ] Multisig accepts ownership

### Transfer Base OFT to Multisig
```bash
cast send $BASE_OFT_ADDRESS \
  "transferOwnership(address)" \
  0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A \
  --rpc-url https://mainnet.base.org \
  --private-key $DEPLOYER_PRIVATE_KEY
```
- [ ] Ownership transfer initiated
- [ ] Multisig accepts ownership

## 📢 Post-Deployment

### Documentation
- [ ] Update README with deployed addresses
- [ ] Document gas costs and fees
- [ ] Create user guide for bridging

### Monitoring Setup
- [ ] Set up alerts for bridge activity
- [ ] Monitor total supply across chains
- [ ] Track gas prices for optimization

### Community
- [ ] Prepare announcement
- [ ] Update documentation sites
- [ ] Notify exchanges/partners

## 🚨 Emergency Procedures

### If Deployment Fails
1. Check gas funding
2. Verify RPC endpoints
3. Check contract compilation
4. Review error messages

### If Wiring Fails
1. Verify contract addresses
2. Check EID values
3. Ensure proper ownership
4. Verify endpoint configuration

### If Bridge Test Fails
1. Check peer configuration
2. Verify gas limits
3. Check DVN settings
4. Review LayerZero Scanner

## 📝 Final Sign-off

- [ ] All deployment steps completed
- [ ] All verifications passed
- [ ] Test transfers successful
- [ ] Ownership transferred to multisigs
- [ ] Documentation updated
- [ ] Team notified

**Deployment Completed By**: _____________________
**Date/Time**: _____________________
**Total Gas Used**: _____________________

---

## Notes Section

_Add any deployment notes, issues encountered, or special considerations here_