# RDAT Multichain - LayerZero V2 Implementation

Deploy RDAT as an omnichain token across Vana and Base using LayerZero V2.

## Quick Start

1. **Fund Deployer**: Send 1 VANA + 0.02 ETH to `0x58eCB94e6F5e6521228316b55c465ad2A2938FbB`

2. **Configure Environment**:
```bash
cd foundry
cp ../.env.example .env
# Add DEPLOYER_PRIVATE_KEY from rdatadao-contracts
```

3. **Deploy**:
```bash
# Vana
forge script script/DeployVanaAdapter.s.sol --rpc-url https://rpc.vana.org --broadcast

# Base
forge script script/DeployBaseOFT.s.sol --rpc-url https://mainnet.base.org --broadcast
```

4. **Wire Contracts**:
```bash
# Update .env with deployed addresses, then:
forge script script/WireContracts.s.sol --rpc-url <chain> --broadcast
```

5. **Test Bridge**:
```bash
forge script script/TestBridge.s.sol --rpc-url https://rpc.vana.org --broadcast
```

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