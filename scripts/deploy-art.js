const { ethers, network, run } = require("hardhat")
const fs = require("fs")
const path = require("path")

async function main() {
  const architect = process.env.ARCHITECT_ADDRESS
  const minter    = process.env.TREASURY_ADDRESS
  if (!architect || !minter) throw new Error("Set ARCHITECT_ADDRESS and TREASURY_ADDRESS in .env")

  const [deployer] = await ethers.getSigners()
  console.log("[FORGEART] Deployer:  ", deployer.address)
  console.log("[FORGEART] Architect: ", architect)
  console.log("[FORGEART] Minter:    ", minter)
  console.log("[FORGEART] Network:   ", network.name)

  const FORGEART = await ethers.getContractFactory("FORGEART")
  const art = await FORGEART.deploy(architect, minter)
  await art.waitForDeployment()

  const address = await art.getAddress()
  const tx = art.deploymentTransaction()
  const receipt = await tx.wait()

  console.log("[FORGEART] Contract:  ", address)
  console.log("[FORGEART] TX:        ", tx.hash)
  console.log("[FORGEART] Block:     ", receipt.blockNumber)
  console.log("[FORGEART] Max supply:", "2,100 tokens")

  const dir = path.join(__dirname, "../deployments")
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })

  const existing = JSON.parse(
    fs.readFileSync(path.join(dir, `${network.name}.json`), "utf8").replace(/\n/g, "").trim()
  )
  existing.forgeArtAddress = address
  existing.forgeArtTxHash  = tx.hash
  existing.forgeArtBlock   = receipt.blockNumber
  fs.writeFileSync(path.join(dir, `${network.name}.json`), JSON.stringify(existing, null, 2))

  console.log("[FORGEART] Deployment record updated")

  if (network.name !== "hardhat" && network.name !== "localhost") {
    console.log("[FORGEART] Waiting 30s for Basescan...")
    await new Promise(r => setTimeout(r, 30000))
    try {
      await run("verify:verify", { address, constructorArguments: [architect, minter] })
      console.log("[FORGEART] Verified on Basescan")
    } catch (e) {
      console.warn("[FORGEART] Verify skipped:", e.message.slice(0, 80))
    }
  }
}

main().catch(e => { console.error(e); process.exit(1) })
