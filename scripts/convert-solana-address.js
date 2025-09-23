#!/usr/bin/env node

const { PublicKey } = require('@solana/web3.js');

// Solana OFT Store address
const solanaAddress = 'FkVGPvVoE3oYoz6EDuJ3ZP2D9aSgM5HHuxk3jf9ckU35';

console.log('Converting Solana address for Vana peer configuration...\n');
console.log('Solana OFT Store Address:', solanaAddress);

try {
    // Create PublicKey object
    const pubkey = new PublicKey(solanaAddress);

    // Convert to bytes32 format for EVM
    const bytes32 = '0x' + pubkey.toBuffer().toString('hex').padStart(64, '0');

    console.log('\nBytes32 format for Vana setPeer():', bytes32);
    console.log('\n=== Vana Multisig Transaction Parameters ===');
    console.log('Contract:', '0xd546C45872eeA596155EAEAe9B8495f02ca4fc58');
    console.log('Function:', 'setPeer');
    console.log('Parameters:');
    console.log('  - _eid (uint32):', '30168');
    console.log('  - _peer (bytes32):', bytes32);

} catch (error) {
    console.error('Error converting address:', error.message);
    process.exit(1);
}