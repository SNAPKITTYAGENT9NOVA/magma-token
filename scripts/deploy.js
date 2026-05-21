const { ethers } = require("hardhat")
async function main() {
  const architect = process.env.ARCHITECT_ADDRESS
  const treasury = process.env.TREASURY_ADDRESS
  if (!architect || !treasury) throw new Error("Set ARCHITECT_ADDRESS and TREASURY_ADDRESS in .env")
  const MAGMA = await ethers.getContractFactory("MAGMA")
  const magma = await MAGMA.deploy(architect, treasury)
  await magma.waitForDeployment()
  console.log("MAGMA deployed to:", await magma.getAddress())
  console.log("Pending: legal sign-off from Jessica Lee Westerhoff CPA before public distribution")
}
main().catch(e => { console.error(e); process.exit(1) })
