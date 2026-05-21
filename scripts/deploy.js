const { ethers, run, network } = require("hardhat")
const fs = require("fs")
const path = require("path")

async function main() {
  const architect = process.env.ARCHITECT_ADDRESS
  const treasury = process.env.TREASURY_ADDRESS
  if (!architect || !treasury) throw new Error("Set ARCHITECT_ADDRESS and TREASURY_ADDRESS in .env")

  const [deployer] = await ethers.getSigners()
  console.log("[FORGE] Deployer:  ", deployer.address)
  console.log("[FORGE] Architect: ", architect)
  console.log("[FORGE] Treasury:  ", treasury)
  console.log("[FORGE] Network:   ", network.name)

  const FORGE = await ethers.getContractFactory("FORGE")
  const forge = await FORGE.deploy(architect, treasury)
  await forge.waitForDeployment()

  const address = await forge.getAddress()
  const deployTx = forge.deploymentTransaction()
  const receipt = await deployTx.wait()

  console.log("[FORGE] Contract address:", address)
  console.log("[FORGE] TX hash:         ", deployTx.hash)
  console.log("[FORGE] Block:           ", receipt.blockNumber)

  // Save deployment record
  const deploymentsDir = path.join(__dirname, "../deployments")
  if (!fs.existsSync(deploymentsDir)) fs.mkdirSync(deploymentsDir, { recursive: true })
  const record = {
    network: network.name,
    address,
    deployer: deployer.address,
    architect,
    treasury,
    txHash: deployTx.hash,
    blockNumber: receipt.blockNumber,
    timestamp: new Date().toISOString(),
    maxSupply: "21000000",
    symbol: "FRG",
    note: "UTILITY TOKEN ONLY — legal sign-off required before public distribution — Jessica Lee Westerhoff CPA"
  }
  const outFile = path.join(deploymentsDir, `${network.name}.json`)
  fs.writeFileSync(outFile, JSON.stringify(record, null, 2))
  console.log("[FORGE] Deployment record saved to", outFile)

  // Verify on Basescan (skip on hardhat/localhost)
  if (network.name !== "hardhat" && network.name !== "localhost") {
    console.log("[FORGE] Waiting 30s for Basescan indexing...")
    await new Promise(r => setTimeout(r, 30000))
    try {
      await run("verify:verify", {
        address,
        constructorArguments: [architect, treasury],
      })
      console.log("[FORGE] Verified on Basescan")
    } catch (e) {
      console.warn("[FORGE] Verification failed (may already be verified):", e.message)
    }
  }
}

main().catch(e => { console.error(e); process.exit(1) })
