# RDAT Multichain - LayerZero V2 Implementation

**Status**: 🟢 **LIVE** - Bridge Operational as of September 23rd, 2025

RDAT is now an omnichain token bridging Vana and Base networks using LayerZero V2 OFT standard.

## Deployed Contracts

### Mainnet Deployments (LIVE)

| Network | Contract Type | Address | Status |
|---------|--------------|---------|--------|
| **Vana** | OFT Adapter | [`0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`](https://vanascan.io/address/0xd546C45872eeA596155EAEAe9B8495f02ca4fc58) | ✅ Live |
| **Base** | RDAT OFT | [`0x77D2713972af12F1E3EF39b5395bfD65C862367C`](https://basescan.org/address/0x77D2713972af12F1E3EF39b5395bfD65C862367C) | ✅ Live |

### Bridge Status
- ✅ Peer connections established
- ✅ Multisig ownership configured
- ✅ Ready for production use
- 📊 Monitor on [LayerZero Scan](https://layerzeroscan.com/)

## Quick Start

### For Users - Bridging RDAT

1. **Vana to Base**: Lock RDAT on Vana to receive on Base
2. **Base to Vana**: Burn RDAT on Base to unlock on Vana
3. See [`TEST_BRIDGE.md`](TEST_BRIDGE.md) for detailed instructions

### For Developers - Deployment (Already Complete)

The deployment process has been completed. For historical reference:
1. Contracts deployed using Foundry
2. Multisig ownership set during deployment
3. Peer connections configured via multisig transactions
4. Bridge tested and operational

## Architecture

- **Vana**: `RdatOFTAdapter` wraps existing RDAT token
- **Base**: `RdatOFT` mints/burns RDAT representations
- **Bridge**: Lock on Vana → Mint on Base | Burn on Base → Unlock on Vana

## Documentation

- [`PLAN.md`](PLAN.md) - Architecture and design decisions
- [`DEPLOYMENT.md`](DEPLOYMENT.md) - Step-by-step deployment guide
- [`foundry/README.md`](foundry/README.md) - Technical implementation

## Key Addresses

| Network | Contract/Purpose | Address |
|---------|-----------------|---------|
| Vana | RDAT Token | `0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E` |
| Vana | **OFT Adapter** | **`0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`** ✅ |
| Vana | LayerZero Endpoint | `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa` |
| Vana | Multisig | `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF` |
| Base | **RDAT OFT** | **`0x77D2713972af12F1E3EF39b5395bfD65C862367C`** ✅ |
| Base | LayerZero Endpoint | `0x1a44076050125825900e736c501f859c50fE728c` |
| Base | Multisig | `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A` |
| Solana | Deployer Wallet | `FFMX53TNrX3fRNXC6uGDZEis9NZpTbEV2d53dcwt4rGM` |

## Implementation

The Foundry implementation in `/foundry` contains:
- Smart contracts (`src/`)
- Deployment scripts (`script/`)
- Fork tests (`test/`)

## Security

- Git hooks prevent accidental key commits
- Multisig ownership for all contracts
- Standard LayerZero contracts (no custom code)
- Fork testing before mainnet deployment