import { ethers } from 'hardhat'
import { EndpointId } from '@layerzerolabs/lz-definitions'
import * as dotenv from 'dotenv'

dotenv.config()

// Chain EIDs
const VANA_EID = 30330 as EndpointId
const BASE_EID = 30184 as EndpointId

async function main() {
  const [sender] = await ethers.getSigners()
  console.log('Testing bridge with account:', sender.address)

  // Get contract addresses
  const vanaAdapterAddress = process.env.VANA_ADAPTER_ADDRESS
  const rdatTokenAddress = process.env.RDAT_TOKEN_ADDRESS

  if (!vanaAdapterAddress || !rdatTokenAddress) {
    throw new Error('Missing contract addresses in .env')
  }

  // Amount to bridge (1 RDAT for testing)
  const amount = ethers.utils.parseEther('1')

  // Get contract instances
  const RdatOFTAdapter = await ethers.getContractFactory('RdatOFTAdapter')
  const vanaAdapter = RdatOFTAdapter.attach(vanaAdapterAddress)

  // Get RDAT token instance for approval
  const RDAT = await ethers.getContractAt('IERC20', rdatTokenAddress)

  // Check balance
  const balance = await RDAT.balanceOf(sender.address)
  console.log(`Current RDAT balance: ${ethers.utils.formatEther(balance)} RDAT`)

  if (balance.lt(amount)) {
    throw new Error('Insufficient RDAT balance')
  }

  // Approve the adapter to spend RDAT
  console.log('Approving RDAT spend...')
  let tx = await RDAT.approve(vanaAdapterAddress, amount)
  await tx.wait()
  console.log('✅ Approval complete')

  // Quote the bridge fee
  console.log('Getting bridge fee quote...')
  const sendParam = {
    dstEid: BASE_EID,
    to: ethers.utils.hexZeroPad(sender.address, 32), // Recipient on Base
    amountLD: amount,
    minAmountLD: amount, // No slippage for testing
    extraOptions: '0x', // Default options
    composeMsg: '0x', // No compose message
    oftCmd: '0x' // No OFT command
  }

  const [nativeFee, lzTokenFee] = await vanaAdapter.quoteSend(sendParam, false)
  console.log(`Bridge fee: ${ethers.utils.formatEther(nativeFee)} VANA`)

  // Send tokens to Base
  console.log(`\nBridging ${ethers.utils.formatEther(amount)} RDAT to Base...`)
  console.log(`Destination EID: ${BASE_EID}`)
  console.log(`Recipient: ${sender.address}`)

  tx = await vanaAdapter.send(
    sendParam,
    { nativeFee, lzTokenFee },
    sender.address, // Refund address
    { value: nativeFee }
  )

  console.log(`Transaction hash: ${tx.hash}`)
  console.log('Waiting for confirmation...')

  const receipt = await tx.wait()
  console.log(`✅ Bridge transaction confirmed in block ${receipt.blockNumber}`)

  // Parse events to find the message nonce
  const sentEvent = receipt.events?.find(e => e.event === 'OFTSent')
  if (sentEvent) {
    const { guid, nonce, amountSentLD } = sentEvent.args
    console.log(`\\n📦 Message Details:`)
    console.log(`  GUID: ${guid}`)
    console.log(`  Nonce: ${nonce}`)
    console.log(`  Amount sent: ${ethers.utils.formatEther(amountSentLD)} RDAT`)
  }

  console.log(`\\n🎉 Bridge test complete!`)
  console.log(`Check your balance on Base in a few minutes.`)
  console.log(`You can track the message at: https://layerzeroscan.com/`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })