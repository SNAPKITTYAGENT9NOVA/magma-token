# MAGMA (MGM) Token

**SnapKitty Collective LLC | Bel Esprit D'Accord Trust**
Designed by CIPHER (Cryptographic Agent), co-architecting with NOVA

---

> REGULATORY DISCLAIMER: MAGMA (MGM) is a utility token for internal mesh
> participation within the SnapKitty SACM ecosystem. It is NOT a security,
> investment contract, or financial instrument. No public sale has occurred.
> All distributions are PENDING LEGAL REVIEW by Jessica Lee Westerhoff, CPA,
> and qualified securities counsel. This repository is for internal development
> only and is not a public offering of any kind.
> SnapKitty Collective LLC — EIN 41-5105572 | Bel Esprit D'Accord Trust — EIN 41-6630640

---

## Overview

MAGMA (symbol: MGM) is the native inter-agent protocol token of the SnapKitty
Stochastic Autonomous Compute Mesh (SACM). It tokenizes mesh participation:

- Earned by SACM agents for WORM-sealed, cryptographically verified work
- Spent for mesh access, SEALFORGE tier upgrades, and governance votes
- Proof of work = WORM chain entries (HMAC-SHA256), not mining
- Hard cap: 1,000,000,000 MGM — no infinite mint

**Target chain: Base L2 (Coinbase OP Stack)**

## Repository Structure

```
magma-token/
  contracts/
    MAGMA.sol          — Production ERC-20 contract (OpenZeppelin 5.x)
  MAGMA_TOKENOMICS.md  — Full tokenomics specification
  README.md            — This file
  package.json         — Hardhat dev dependencies
  hardhat.config.js    — Hardhat network/compiler config
```

## Quick Start

```bash
npm install
npx hardhat compile
npx hardhat test
```

## Deployment

Copy `.env.example` to `.env` and fill in:
- `DEPLOYER_PRIVATE_KEY`
- `BASESCAN_API_KEY`
- `BASE_SEPOLIA_RPC`
- `BASE_MAINNET_RPC`

Deploy to Base Sepolia testnet first:
```bash
npm run deploy:sepolia
```

Verify on Basescan:
```bash
npm run verify:sepolia -- --constructor-args <architect_address> <treasury_address> <contract_address>
```

**MAINNET DEPLOYMENT REQUIRES:**
1. Completed legal review by Jessica Lee Westerhoff, CPA
2. Sign-off from qualified securities counsel
3. External Solidity audit (Certik, Trail of Bits, or equivalent)
4. Gnosis Safe multisigs deployed for Treasury and Architect roles

## Key Contract Functions

| Function            | Access          | Description                                     |
|---------------------|-----------------|-------------------------------------------------|
| `wormMint()`        | MINTER_ROLE     | Mint against WORM-verified work event (nonce)   |
| `sealforgeBurn()`   | BURNER_ROLE     | Burn on SEALFORGE tier upgrade                  |
| `governanceWeight()`| Public view     | Returns capped voting weight (max 1% supply)    |
| `emergencyPause()`  | ARCHITECT_ROLE  | Pause all transfers/mints/burns                 |
| `emergencyUnpause()`| ARCHITECT_ROLE  | Unpause the contract                            |
| `remainingMintable()`| Public view   | Tokens remaining before hard cap                |

## Token Distribution

| Allocation         | %   | MGM             |
|--------------------|-----|-----------------|
| Mesh Agent Rewards | 35% | 350,000,000     |
| Treasury           | 25% | 250,000,000     |
| Team & Founders    | 15% | 150,000,000     |
| Ecosystem Fund     | 12% | 120,000,000     |
| Community Rewards  | 8%  | 80,000,000      |
| Reserve (Burn)     | 5%  | 50,000,000      |

See `MAGMA_TOKENOMICS.md` for full specification.

---

*CIPHER (Cryptographic Agent) — co-architecting with NOVA*
*2026-05-21 | PENDING LEGAL REVIEW — NOT FOR PUBLIC DISTRIBUTION*
