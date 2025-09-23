# RDAT Multichain Deployment Results

**Date**: September 23rd, 2025
**Status**: ✅ Contracts Deployed - Awaiting Multisig Configuration

## Deployed Contracts

### Vana Mainnet (Chain ID: 1480)
- **RdatOFTAdapter**: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
  - Wraps existing RDAT: `0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E`
  - Owner: `0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF` (Vana Multisig)
  - LayerZero Endpoint: `0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa`

### Base Mainnet (Chain ID: 8453)
- **RdatOFT**: `0x77D2713972af12F1E3EF39b5395bfD65C862367C`
  - New mintable/burnable token
  - Owner: `0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A` (Base Multisig)
  - LayerZero Endpoint: `0x1a44076050125825900e736c501f859c50fE728c`

## Required Multisig Actions

### 1. Vana Multisig (`0xe4F7Eca807C57311e715C3Ef483e72Fa8D5bCcDF`)

Execute on Vana:
```bash
# Set Base OFT as peer
cast send 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58 \
  "setPeer(uint32,bytes32)" \
  30184 \
  0x00000000000000000000000077D2713972af12F1E3EF39b5395bfD65C862367C \
  --rpc-url https://rpc.vana.org
```

### 2. Base Multisig (`0x90013583c66D2bf16327cB5Bc4a647AcceCF4B9A`)

Execute on Base:
```bash
# Set Vana Adapter as peer
cast send 0x77D2713972af12F1E3EF39b5395bfD65C862367C \
  "setPeer(uint32,bytes32)" \
  30330 \
  0x000000000000000000000000d546C45872eeA596155EAEAe9B8495f02ca4fc58 \
  --rpc-url https://mainnet.base.org
```

## Verification Commands

After multisig execution, verify peers are set:

```bash
# Check Vana adapter trusts Base
cast call 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58 \
  "peers(uint32)" 30184 \
  --rpc-url https://rpc.vana.org

# Check Base OFT trusts Vana
cast call 0x77D2713972af12F1E3EF39b5395bfD65C862367C \
  "peers(uint32)" 30330 \
  --rpc-url https://mainnet.base.org
```

## Gas Usage

- Vana deployment: 0.000050807675565348 VANA
- Base deployment: 0.000049796992741253 ETH

## Next Steps

1. ⏳ **Multisigs execute setPeer commands** (required)
2. ⏳ Verify peer configuration
3. ⏳ Test bridge with small amount (0.001 RDAT)
4. ⏳ Monitor on LayerZero Scanner
5. ⏳ Transfer ownership to multisigs (already done during deployment)

## LayerZero Scanner

Monitor bridge activity at: https://layerzeroscan.com/

## Notes

- Contracts deployed with multisig ownership from the start
- No further ownership transfer needed
- Bridge will be operational once setPeer is executed by multisigs