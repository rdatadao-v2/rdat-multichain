# Vana-Solana Peer Configuration Guide

**Date**: September 23, 2025
**Status**: Solana OFT Deployed, Awaiting Peer Configuration

## Overview

Both Solana and Vana sides need to be configured to recognize each other as valid peers for the LayerZero V2 bridge to function. This requires multisig transactions on both chains.

## Solana Configuration (Complete)

The Solana OFT program has been deployed and configured:
- **Program ID**: `BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f`
- **OFT Store**: `FkVGPvVoE3oYoz6EDuJ3ZP2D9aSgM5HHuxk3jf9ckU35`
- **SPL Token**: `HVGrNMrX2uNsFhdvS73BgvGzHVb7VwPHYQwgteC7WR8y`
- **Escrow**: `ADreZbhDXJh3XfcQq6dheTPuHp8WriJ2Jzyvwuxvd7Bx`

## Vana Configuration (Required)

### Multisig Transaction Required

The Vana OFT Adapter needs to add Solana as a trusted peer. This requires a multisig transaction on Vana.

**Contract**: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
**Function**: `setPeer`
**Parameters**:
```solidity
setPeer(
    uint32 _eid,        // 30168 (Solana Mainnet EndpointId)
    bytes32 _peer       // 0xdb278d34e03c5e5ec8286b0e22748f15d49b5eb5d4d24909b6a69883097d80ac
)
```

### Converting Solana Address to bytes32

The Solana OFT Store address needs to be converted to bytes32 format for the EVM contract:
1. Solana address (base58): `FkVGPvVoE3oYoz6EDuJ3ZP2D9aSgM5HHuxk3jf9ckU35`
2. Convert to hex: Use LayerZero's address converter or script below
3. Pad to bytes32: Add leading zeros if needed

### Verification Script

```javascript
// Convert Solana base58 to bytes32 for EVM
const { PublicKey } = require('@solana/web3.js');
const solanaAddress = 'FkVGPvVoE3oYoz6EDuJ3ZP2D9aSgM5HHuxk3jf9ckU35';
const pubkey = new PublicKey(solanaAddress);
const bytes32 = '0x' + pubkey.toBuffer().toString('hex').padStart(64, '0');
console.log('Solana address as bytes32:', bytes32);
```

## Configuration Options

### Gas Settings (Enforced Options)

**Vana → Solana**:
- Gas: 300,000 Compute Units
- Value: 2,039,280 lamports (for SPL token account rent)

**Solana → Vana**:
- Gas: 150,000 gas units
- Value: 0

### Rate Limits (Optional)

Consider setting rate limits to prevent exploitation:
- Daily limit: 1,000,000 RDAT
- Per-transaction limit: 100,000 RDAT

## Multisig Process

### For Vana Multisig Signers

1. **Access Safe**: Go to the Vana Gnosis Safe interface
2. **Create Transaction**:
   - Target: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
   - Function: `setPeer`
   - eid: `30168`
   - peer: (converted bytes32 address from above)
3. **Confirm**: Requires 2/3 signatures
4. **Execute**: After signatures collected

### Verification After Configuration

Once the peer is set on Vana:

1. **Check Peer Configuration**:
```javascript
// Read peer from Vana contract
const peer = await oftAdapter.peers(30168);
console.log('Configured Solana peer:', peer);
```

2. **Test Small Transfer**:
- Send 0.001 RDAT from Vana to Solana
- Monitor on [LayerZero Scan](https://layerzeroscan.com)
- Verify receipt on Solana

## Troubleshooting

### Common Issues

1. **"Invalid peer" error**: Peer address not set or incorrect format
2. **"Insufficient gas" error**: Increase gas limits in enforced options
3. **"Not trusted" error**: Peer configuration incomplete on one side

### Support Resources

- LayerZero Discord: [#dev-support](https://discord.gg/layerzero)
- Documentation: [LayerZero V2 Docs](https://docs.layerzero.network/v2)
- Explorer: [LayerZero Scan](https://layerzeroscan.com)

## Next Steps After Configuration

1. ✅ Set peer on Vana via multisig
2. ⏳ Configure Solana peer settings (if needed)
3. ⏳ Test small bridge transaction
4. ⏳ Monitor and verify
5. ⏳ Public announcement

## Important Notes

- **Security**: Never rush peer configuration. Double-check addresses
- **Testing**: Always test with small amounts first
- **Monitoring**: Watch LayerZero Scan for transaction status
- **Recovery**: If issues occur, peers can be updated via multisig

---

**Current Status**: Awaiting Vana multisig transaction to set Solana as peer