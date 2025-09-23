#!/bin/bash

echo "========================================"
echo "Creating Solana Deployer Wallet"
echo "========================================"
echo ""

# Check if solana CLI is installed
if ! command -v solana &> /dev/null; then
    echo "Error: Solana CLI is not installed."
    echo "Please install it first:"
    echo "sh -c \"\$(curl -sSfL https://release.solana.com/stable/install)\""
    exit 1
fi

# Create the wallet
echo "Generating new Solana wallet..."
solana-keygen new --outfile ./solana-deployer.json --no-bip39-passphrase

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Wallet created successfully!"
    echo "   File: ./solana-deployer.json"
    echo ""

    # Get the public key
    PUBKEY=$(solana-keygen pubkey ./solana-deployer.json)
    echo "📋 Wallet Address: $PUBKEY"
    echo ""
    echo "⚠️  IMPORTANT:"
    echo "   1. Save the seed phrase shown above in a secure location"
    echo "   2. Keep solana-deployer.json file secure (contains private key)"
    echo "   3. Add this file to .gitignore (already added)"
    echo ""
    echo "💰 Funding Required: 2.5 SOL"
    echo "   Send SOL to: $PUBKEY"
    echo ""
    echo "To check balance:"
    echo "   solana balance $PUBKEY --url mainnet-beta"
else
    echo "❌ Failed to create wallet"
    exit 1
fi