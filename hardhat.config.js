require("@nomicfoundation/hardhat-toolbox")
require("dotenv").config()

module.exports = {
  solidity: { version: "0.8.24", settings: { optimizer: { enabled: true, runs: 200 } } },
  networks: {
    "base-sepolia": { url: "https://sepolia.base.org", accounts: process.env.DEPLOYER_PRIVATE_KEY ? [process.env.DEPLOYER_PRIVATE_KEY] : [], chainId: 84532 },
    base: { url: "https://mainnet.base.org", accounts: process.env.DEPLOYER_PRIVATE_KEY ? [process.env.DEPLOYER_PRIVATE_KEY] : [], chainId: 8453 }
  },
  etherscan: { apiKey: { base: process.env.BASESCAN_API_KEY ?? "", "base-sepolia": process.env.BASESCAN_API_KEY ?? "" } }
}
