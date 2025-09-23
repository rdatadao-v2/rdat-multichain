#!/bin/bash

# RDAT Solana OFT Deployment Script
# Run after build completes

set -e

echo "🚀 RDAT Solana OFT Deployment"
echo "=============================="
echo ""

# Step 1: Check build
echo "✅ Step 1: Checking build..."
if [ -f "target/deploy/oft.so" ]; then
    echo "   Program binary found: target/deploy/oft.so"
else
    echo "   ❌ Error: Build not complete. Run 'anchor build' first"
    exit 1
fi

# Step 2: Deploy program
echo ""
echo "✅ Step 2: Deploying OFT program to Solana mainnet..."
echo "   Program ID: BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f"
echo ""

solana program deploy \
    --program-id target/deploy/oft-keypair.json \
    target/deploy/oft.so \
    -u mainnet-beta \
    --keypair keypair.json \
    --with-compute-unit-price 1000

echo ""
echo "✅ Program deployed successfully!"

# Step 3: Create OFT Store
echo ""
echo "✅ Step 3: Creating OFT Store account..."
echo "   This initializes the LayerZero configuration"
echo ""

# Note: This requires the hardhat tasks to be set up
# pnpm hardhat lz:oft:solana:create \
#     --eid 30168 \
#     --program-id BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f \
#     --shared-decimals 6 \
#     --local-decimals 9

echo "   Run the create command using pnpm hardhat tasks"

# Step 4: Set peer
echo ""
echo "✅ Step 4: Configure Vana as peer..."
echo "   Vana EID: 30330"
echo "   Vana Adapter: 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58"
echo ""

# Note: This also requires hardhat tasks
# pnpm hardhat lz:oft:solana:set-peer \
#     --eid 30168 \
#     --peer-eid 30330 \
#     --peer-address 0xd546C45872eeA596155EAEAe9B8495f02ca4fc58

echo "   Run the set-peer command using pnpm hardhat tasks"

echo ""
echo "=============================="
echo "🎉 Deployment Complete!"
echo ""
echo "Program Address: BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f"
echo "Explorer: https://explorer.solana.com/address/BQWFM5WBsHcAqQszdRtW2r5suRciePEFKeRrEJChax4f"
echo ""
echo "Next steps:"
echo "1. Verify program on explorer"
echo "2. Configure Vana multisig to add Solana peer"
echo "3. Test bridge with small amount"
echo ""