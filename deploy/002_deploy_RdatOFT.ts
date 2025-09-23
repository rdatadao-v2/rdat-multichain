import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, network } = hre
  const { deploy } = deployments
  const { deployer, owner } = await getNamedAccounts()

  console.log(`Deploying RdatOFT on ${network.name}...`)
  console.log(`Deployer: ${deployer}`)
  console.log(`Owner: ${owner}`)

  // Get configuration from environment
  const endpoint = process.env.BASE_ENDPOINT

  if (!endpoint) {
    throw new Error('Missing required environment variable: BASE_ENDPOINT')
  }

  // Deploy RdatOFT
  const deployment = await deploy('RdatOFT', {
    from: deployer,
    args: [
      'RDAT',    // Token name
      'RDAT',    // Token symbol
      endpoint,  // LayerZero endpoint on Base
      owner || deployer // Owner (multisig or deployer)
    ],
    log: true,
    waitConfirmations: network.live ? 5 : 1,
    skipIfAlreadyDeployed: true,
  })

  console.log(`RdatOFT deployed at: ${deployment.address}`)

  // Verify contract if on live network
  if (network.live && process.env.BASESCAN_API_KEY) {
    console.log('Verifying contract on Basescan...')
    try {
      await hre.run('verify:verify', {
        address: deployment.address,
        constructorArguments: ['RDAT', 'RDAT', endpoint, owner || deployer],
      })
      console.log('Contract verified successfully')
    } catch (error) {
      console.error('Verification failed:', error)
    }
  }
}

export default func
func.tags = ['RdatOFT', 'base']
func.dependencies = []