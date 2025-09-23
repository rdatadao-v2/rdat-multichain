# RDAT Bridge Test Guide

## ✅ Bridge Configuration Confirmed!

### Peer Verification Results:
- **Vana Adapter** recognizes Base OFT ✅
- **Base OFT** recognizes Vana Adapter ✅

## 🌉 Testing the Bridge

### Step 1: Approve RDAT Token
First, approve the Vana adapter to spend your RDAT tokens:

```bash
# Approve 0.001 RDAT (with 18 decimals)
cast send 0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E \
  "approve(address,uint256)" \
  0xd546C45872eeA596155EAEAe9B8495f02ca4fc58 \
  1000000000000000 \
  --rpc-url https://rpc.vana.org \
  --private-key YOUR_PRIVATE_KEY
```

### Step 2: Estimate Bridge Fee
Get the fee required for bridging:

```bash
cast call 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58 \
  "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)" \
  "(30184,0x00000000000000000000000077D2713972af12F1E3EF39b5395bfD65C862367C,1000000000000000,1000000000000000,0x,0x,0x)" \
  false \
  --rpc-url https://rpc.vana.org
```

### Step 3: Send Tokens to Base
Bridge 0.001 RDAT from Vana to Base:

```bash
# Replace FEE_IN_WEI with the fee from Step 2
cast send 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58 \
  "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),address)" \
  "(30184,0x00000000000000000000000077D2713972af12F1E3EF39b5395bfD65C862367C,1000000000000000,1000000000000000,0x,0x,YOUR_ADDRESS_IN_BYTES32)" \
  0x0000000000000000000000000000000000000000 \
  --value FEE_IN_WEI \
  --rpc-url https://rpc.vana.org \
  --private-key YOUR_PRIVATE_KEY
```

### Step 4: Check Balance on Base
After a few minutes, check your balance on Base:

```bash
cast call 0x77D2713972af12F1E3EF39b5395bfD65C862367C \
  "balanceOf(address)" \
  YOUR_ADDRESS \
  --rpc-url https://mainnet.base.org
```

## 🔄 Return Journey (Base → Vana)

### Step 1: Estimate Return Fee
```bash
cast call 0x77D2713972af12F1E3EF39b5395bfD65C862367C \
  "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)" \
  "(30330,0x000000000000000000000000d546C45872eeA596155EAEAe9B8495f02ca4fc58,1000000000000000,1000000000000000,0x,0x,0x)" \
  false \
  --rpc-url https://mainnet.base.org
```

### Step 2: Send Back to Vana
```bash
cast send 0x77D2713972af12F1E3EF39b5395bfD65C862367C \
  "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),address)" \
  "(30330,0x000000000000000000000000d546C45872eeA596155EAEAe9B8495f02ca4fc58,1000000000000000,1000000000000000,0x,0x,YOUR_ADDRESS_IN_BYTES32)" \
  0x0000000000000000000000000000000000000000 \
  --value FEE_IN_WEI \
  --rpc-url https://mainnet.base.org \
  --private-key YOUR_PRIVATE_KEY
```

## 📊 Monitor Your Transaction

Track your cross-chain transaction on LayerZero Scan:
https://layerzeroscan.com/

## 🎉 Success Indicators

1. ✅ Transaction confirmed on source chain
2. ✅ LayerZero Scan shows message delivered
3. ✅ Balance updated on destination chain

## 📝 Important Notes

- Bridge time: Usually 1-3 minutes
- Fees: Paid in native token (VANA on Vana, ETH on Base)
- Minimum amount: Test with small amounts first
- For YOUR_ADDRESS_IN_BYTES32: Pad your address with zeros
  - Example: If your address is `0x123...abc`
  - Bytes32 format: `0x000000000000000000000000123...abc`

## 🚨 Troubleshooting

If tokens don't arrive:
1. Check LayerZero Scan for transaction status
2. Verify you included enough native token for fees
3. Confirm the peer addresses are still set correctly
4. Wait a few more minutes (sometimes it takes longer)

## 🎊 Congratulations!

The RDAT bridge is now fully operational between Vana and Base networks!