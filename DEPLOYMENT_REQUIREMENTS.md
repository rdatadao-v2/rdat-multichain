# RDAT Multichain Deployment Requirements

## Deployment Wallets

### EVM Chains (Vana & Base)
**Deployer Address**: `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB`
- This is the same deployer used in rdatadao-contracts
- Will be used for both Vana and Base deployments

### Solana
**Needs New Wallet**: We need to create a Solana deployer wallet
- Generate using: `solana-keygen new --outfile deployer.json`
- Save the public key for funding

## Required Funding

### 1. Vana Mainnet
**Deployer**: `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB`
**Required**: **0.5 VANA**
- Contract deployment (OFTAdapter): ~0.1 VANA
- Peer configuration (setPeer calls): ~0.05 VANA
- DVN/Executor configuration: ~0.1 VANA
- Buffer for multiple transactions: ~0.25 VANA

### 2. Base Mainnet
**Deployer**: `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB`
**Required**: **0.01 ETH**
- Contract deployment (OFT): ~0.003 ETH
- Peer configuration: ~0.001 ETH
- DVN/Executor configuration: ~0.002 ETH
- Buffer: ~0.004 ETH

### 3. Solana Mainnet
**Deployer**: `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM`
**Required**: **2.5 SOL**
- Program deployment: ~0.5 SOL
- Account creation and initialization: ~0.5 SOL
- Peer configuration: ~0.2 SOL
- Buffer for rent and transactions: ~0.8 SOL

## Operational Costs (Post-Deployment)

### Bridge Transaction Fees (Per Transfer)
- **Vana → Base**: ~0.05-0.1 VANA + LayerZero fees
- **Base → Vana**: ~0.001-0.002 ETH + LayerZero fees
- **Vana → Solana**: ~0.1-0.2 VANA + LayerZero fees
- **Solana → Vana**: ~0.01-0.02 SOL + LayerZero fees

### Recommended Initial Bridge Liquidity
For testing initial bridges:
- **Vana wallet**: Additional 0.5 VANA for bridge testing
- **Base wallet**: Additional 0.01 ETH for bridge testing
- **Solana wallet**: Additional 0.5 SOL for bridge testing

## Total Funding Summary

| Chain | Wallet | Deployment | Testing | Total Required |
|-------|--------|------------|---------|----------------|
| Vana | `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB` | 0.5 VANA | 0.5 VANA | **1 VANA** |
| Base | `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB` | 0.01 ETH | 0.01 ETH | **0.02 ETH** |
| Solana | `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM` | 2 SOL | 0.5 SOL | **2.5 SOL** |

## Pre-Deployment Checklist

### 1. Wallet Setup
- [ ] Fund Vana deployer with 1 VANA
- [ ] Fund Base deployer with 0.02 ETH
- [x] ✅ Created Solana deployer wallet: `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM`
- [ ] Fund Solana deployer with 2.5 SOL

### 2. Verify Endpoints (CRITICAL)
- [ ] Confirm Vana endpoint: `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa`
  - **ACTION NEEDED**: This needs verification before deployment
  - Most chains use `0x1a44076050125825900e736c501f859c50fE728c`
  - Deploy a test read to verify the correct endpoint

### 3. Configuration
- [ ] Copy `.env.example` to `.env`
- [ ] Add deployer private key
- [ ] Confirm multisig addresses:
  - Vana: `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`
  - Base: `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`

### 4. RDAT Token Preparation
- [ ] Ensure RDAT token holder has approved amounts for testing
- [ ] Have at least 100 RDAT ready for initial bridge tests

## Deployment Order

1. **Vana OFTAdapter** (first - wraps existing token)
2. **Base OFT** (second - satellite chain)
3. **Wire Vana <-> Base** (bidirectional peer setup)
4. **Test Vana -> Base bridge** (small amount)
5. **Test Base -> Vana bridge** (return test)
6. **Solana OFT** (after EVM chains work)
7. **Wire Vana <-> Solana**
8. **Full testing suite**

## Post-Deployment

### Ownership Transfer
After successful deployment and testing:
1. Transfer OFTAdapter ownership to Vana multisig
2. Transfer Base OFT ownership to Base multisig
3. Transfer Solana OFT authority to Solana multisig

### Monitoring
- Monitor first 24-48 hours closely
- Set up alerts for bridge events
- Track total supply consistency across chains

## Emergency Contacts
- Have LayerZero support contact ready
- Multisig signers on standby for any urgent changes
- Bridge pause mechanism ready if needed