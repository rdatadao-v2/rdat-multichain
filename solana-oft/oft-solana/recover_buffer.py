#!/usr/bin/env python3
from mnemonic import Mnemonic
import hashlib
import base58
import json

# The seed phrase from the failed deployment
seed_phrase = "digital duty laptop sick drum also endorse violin check side voice cushion"

# Generate seed from mnemonic
mnemo = Mnemonic("english")
seed = mnemo.to_seed(seed_phrase, passphrase="")

# Derive Solana keypair (using first 32 bytes as private key)
private_key = seed[:32]
pubkey_bytes = hashlib.sha256(private_key).digest()

# Convert to base58
private_key_b58 = base58.b58encode(private_key).decode()

print(f"Buffer account seed phrase: {seed_phrase}")
print(f"Derived private key (first 32 bytes): {private_key.hex()}")
print(f"Base58 private key: {private_key_b58}")

# We need to find the buffer account address
# Let's check what accounts were created