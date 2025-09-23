# RDAT Bridging User Guide

## ✅ Bridge Status: OPERATIONAL

RDAT can now be bridged between Vana and Base networks!

## Bridging Options

### Option 1: Direct Contract Interaction (Current)
Since this is a newly deployed bridge, it may not yet be integrated into UI interfaces. You can bridge directly using the contracts.

### Option 2: UI Interfaces (Coming Soon)

#### Stargate Finance
- **Status**: Not yet available
- **Why**: Stargate needs to manually add new OFT tokens to their interface
- **Action Required**: Submit a request to Stargate to add RDAT
- **Website**: https://stargate.finance/

#### LayerZero Bridge (Superbridge)
- **Status**: May auto-detect OFT contracts
- **Website**: https://www.superbridge.app/
- **Try**: Connect wallet and see if RDAT appears in token list

#### Other Options
- **Jumper.exchange**: https://jumper.exchange/
- **XY Finance**: https://xy.finance/

## How to Bridge Using Contracts (Available Now)

### Prerequisites
1. RDAT tokens in your wallet
2. Native gas tokens (VANA on Vana, ETH on Base)
3. Web3 wallet (MetaMask, etc.)

### Step 1: Approve the Bridge Contract

#### On Vana Network
1. Go to Vanascan: https://vanascan.io/address/0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E#writeContract
2. Connect your wallet
3. Find `approve` function
4. Enter:
   - Spender: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
   - Amount: Your desired amount (with 18 decimals)
   - Example: For 100 RDAT, enter: `100000000000000000000`
5. Execute transaction

### Step 2: Bridge to Base

1. Go to adapter contract: https://vanascan.io/address/0xd546C45872eeA596155EAEAe9B8495f02ca4fc58#writeContract
2. Connect wallet
3. Use `send` function with these parameters:
   ```
   _sendParam:
   - dstEid: 30184
   - to: [your address in bytes32 format]
   - amountLD: [amount with 18 decimals]
   - minAmountLD: [same as amountLD]
   - extraOptions: 0x
   - composeMsg: 0x
   - oftCmd: 0x

   _fee: [native fee amount - check quoteSend first]
   _refundAddress: [your address]
   ```

### Step 3: Monitor Transaction
- Check LayerZero Scan: https://layerzeroscan.com/
- Wait 1-3 minutes for confirmation
- Check balance on Base: https://basescan.org/address/0x77D2713972af12F1E3EF39b5395bfD65C862367C

## Bridging Back (Base to Vana)

Similar process but using the Base OFT contract:
- Base OFT: `0x77D2713972af12F1E3EF39b5395bfD65C862367C`
- No approval needed (OFT burns its own tokens)
- Use `send` function with dstEid: 30330

## Using Etherscan/Vanascan Interface

### For Technical Users - Easier Method

1. **Get Quote First** (to know the fee):
```javascript
// On Vanascan, go to Read Contract
// Use quoteSend function with:
{
  dstEid: 30184,
  to: "0x00000000000000000000000077D2713972af12F1E3EF39b5395bfD65C862367C",
  amountLD: "1000000000000000000", // 1 RDAT
  minAmountLD: "1000000000000000000",
  extraOptions: "0x",
  composeMsg: "0x",
  oftCmd: "0x"
}
// Returns: [nativeFee, lzTokenFee]
```

2. **Send Tokens**:
- Use the `nativeFee` from above as the payable amount
- Call `send` function with same parameters

## Community Integration Requests

To get RDAT added to bridge UIs, the community should:

1. **Stargate Finance**:
   - Submit integration request via their Discord
   - Provide contract addresses and verification

2. **LayerZero/Superbridge**:
   - May auto-detect, try connecting wallet first
   - If not visible, contact support

3. **Other Bridges**:
   - Each bridge has different integration processes
   - Usually requires community requests or votes

## Important Notes

⚠️ **Gas Fees**: You need native tokens on both chains
- Vana: VANA for gas
- Base: ETH for gas

⚠️ **First Bridge**: Start with small amounts to test

⚠️ **Addresses**: Always verify contract addresses:
- Vana Adapter: `0xd546C45872eeA596155EAEAe9B8495f02ca4fc58`
- Base OFT: `0x77D2713972af12F1E3EF39b5395bfD65C862367C`

## Technical Details for Bridge UI Integration

If you're submitting to bridge interfaces, provide:

```json
{
  "token": "RDAT",
  "vana": {
    "chainId": 1480,
    "eid": 30330,
    "token": "0x2c1CB448cAf3579B2374EFe20068Ea97F72A996E",
    "adapter": "0xd546C45872eeA596155EAEAe9B8495f02ca4fc58"
  },
  "base": {
    "chainId": 8453,
    "eid": 30184,
    "oft": "0x77D2713972af12F1E3EF39b5395bfD65C862367C"
  },
  "standard": "LayerZero V2 OFT"
}
```

## Need Help?

1. Check transaction on LayerZero Scan
2. Verify allowance was set correctly
3. Ensure sufficient gas on both chains
4. Wait up to 5 minutes for cross-chain confirmation

---

*Note: As this is a newly deployed bridge, UI integrations may take time. Direct contract interaction works immediately.*