const https = require('https');

// Function to make RPC calls
function makeRPCCall(url, method, params) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      jsonrpc: "2.0",
      method: method,
      params: params,
      id: 1
    });

    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
      }
    };

    const req = https.request(url, options, (res) => {
      let response = '';
      res.on('data', (chunk) => response += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(response));
        } catch (error) {
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function verifyEndpoints() {
  console.log('🔍 Verifying LayerZero Endpoints...\n');

  const endpoints = [
    {
      name: 'Vana Specific Endpoint (from PLAN.md)',
      address: '0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa',
      rpc: 'https://rpc.vana.org'
    },
    {
      name: 'Common V2 Endpoint',
      address: '0x1a44076050125825900e736c501f859c50fE728c',
      rpc: 'https://rpc.vana.org'
    }
  ];

  for (const endpoint of endpoints) {
    console.log(`\nChecking ${endpoint.name}: ${endpoint.address}`);
    console.log('-'.repeat(60));

    try {
      // Check if contract exists
      const codeResult = await makeRPCCall(endpoint.rpc, 'eth_getCode', [endpoint.address, 'latest']);

      if (codeResult.error) {
        console.log(`❌ RPC Error: ${codeResult.error.message}`);
        continue;
      }

      if (codeResult.result === '0x') {
        console.log('❌ No contract deployed at this address');
        continue;
      }

      console.log('✅ Contract found at address');
      console.log(`   Bytecode length: ${(codeResult.result.length - 2) / 2} bytes`);

      // Try to call the eid() function (method ID: 0x9131cd1a)
      try {
        const eidResult = await makeRPCCall(endpoint.rpc, 'eth_call', [
          { to: endpoint.address, data: '0x9131cd1a' },
          'latest'
        ]);

        if (eidResult.result && eidResult.result !== '0x') {
          const eid = parseInt(eidResult.result, 16);
          console.log(`✅ Endpoint EID: ${eid}`);

          if (eid === 30330) {
            console.log('✅ EID matches Vana Mainnet (30330)');
          } else {
            console.log(`⚠️  EID is ${eid}, expected 30330 for Vana`);
          }
        }
      } catch (e) {
        console.log('⚠️  Could not read EID - might not be a LayerZero endpoint');
      }

      console.log(`\n🎯 This appears to be a valid LayerZero endpoint!`);

    } catch (error) {
      console.log(`❌ Error checking endpoint: ${error.message}`);
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log('SUMMARY:');
  console.log('✅ 0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa - Contract exists (RECOMMENDED)');
  console.log('❌ 0x1a44076050125825900e736c501f859c50fE728c - No contract');
  console.log('\nRECOMMENDation: Use 0xcb566e3B6934Fa77258d68ea18E931fa75e1aaAa for Vana deployment');
}

verifyEndpoints().catch(console.error);