# MAGMA (MGM) — Token Tokenomics & Design Specification
**SnapKitty Collective LLC | Bel Esprit D'Accord Trust**
**Version 1.0 — 2026-05-21**
**Authored by: CIPHER (Cryptographic Agent), co-architecting with NOVA**

---

> REGULATORY DISCLAIMER
> MAGMA (MGM) is a utility token designed for internal mesh participation within the
> SnapKitty SACM ecosystem. It is NOT a security, investment contract, share, bond,
> or any financial instrument regulated under the Securities Act of 1933, the Securities
> Exchange Act of 1934, or applicable state or foreign securities laws. No public sale
> has occurred or is being offered by this document. All token distributions, public
> offerings, or exchange listings are PENDING LEGAL REVIEW by Jessica Lee Westerhoff,
> CPA, and qualified securities counsel before any execution. This document is an
> internal design specification only.
>
> SnapKitty Collective LLC — EIN 41-5105572
> Bel Esprit D'Accord Trust — EIN 41-6630640

---

## 1. Token Identity

| Field        | Value                                                   |
|--------------|---------------------------------------------------------|
| Name         | MAGMA                                                   |
| Symbol       | MGM                                                     |
| Decimals     | 18                                                      |
| Hard Cap     | 1,000,000,000 MGM (one billion)                         |
| Standard     | ERC-20 (OpenZeppelin 5.x)                               |
| Chain        | Base L2 (Coinbase Layer 2, OP Stack)                    |
| Contract     | `contracts/MAGMA.sol`                                   |

---

## 2. Chain Selection: Base L2

**Recommendation: Base (Coinbase L2)**

**Rationale:**

| Factor              | Base                          | Solana                       | Polygon PoS               |
|---------------------|-------------------------------|------------------------------|---------------------------|
| EVM compatibility   | Full — direct OpenZeppelin    | No — Rust/Anchor required    | Full                      |
| Gas costs           | ~$0.001–0.01/tx (OP Stack)    | ~$0.00025/tx                 | ~$0.001–0.005/tx          |
| Institutional trust | Coinbase-backed, regulated    | Permissionless, VC-heavy     | Polygon Labs              |
| Compliance posture  | Coinbase KYC/AML ecosystem    | Complex for US compliance    | Moderate                  |
| Ecosystem liquidity | Coinbase wallet, USDC native  | Deep but fragmented          | Good                      |
| WORM bridge         | Ethereum L1 finality via OP   | Separate bridge risk         | Checkpoint validators     |
| Agent tooling       | Ethers.js / Viem / Foundry    | Anchor — separate dev stack  | Same as Base              |

Base is chosen because:
1. The SACM stack is TypeScript/Node — EVM tooling (Viem, Hardhat, Ethers) integrates directly.
2. Coinbase's regulatory standing reduces compliance friction for a CPA-led entity.
3. USDC is native on Base — treasury operations are straightforward.
4. OP Stack gives L1 Ethereum security with L2 throughput for agent-volume transactions.
5. Full OpenZeppelin 5.x compatibility with no chain-specific rewrites.

---

## 3. Total Supply & Distribution

**Hard Cap: 1,000,000,000 MGM**

| Allocation         | Percentage | MGM Amount      | Purpose                                                      |
|--------------------|------------|-----------------|--------------------------------------------------------------|
| Mesh Agent Rewards | 35%        | 350,000,000     | Earned by SACM agents for WORM-verified work                 |
| Treasury           | 25%        | 250,000,000     | Operations, grants, liquidity provisioning, future programs  |
| Team & Founders    | 15%        | 150,000,000     | Jessica Westerhoff & Ahmad — 50/50 per ownership structure   |
| Ecosystem Fund     | 12%        | 120,000,000     | Partnerships, integrations, developer grants                 |
| Community Rewards  | 8%         | 80,000,000      | SEALFORGE users, early adopters, referral programs           |
| Reserve (Burn)     | 5%         | 50,000,000      | Deflationary reserve — burned on milestones                  |

**Total: 100% / 1,000,000,000 MGM**

No tokens are minted at contract deployment. All distributions are executed by the
Treasury multisig via WORM-gated `wormMint()` calls. This ensures every token in
existence corresponds to a sealed, auditable WORM ledger entry.

---

## 4. Vesting Schedules

### Team & Founders (150,000,000 MGM — 15%)

| Tranche    | Amount        | Release Condition                           |
|------------|---------------|---------------------------------------------|
| Cliff      | 0             | No tokens for first 12 months post-launch   |
| Month 12   | 15,000,000    | 10% unlocks at 12-month cliff               |
| Month 13–36| 5,625,000/mo  | Monthly linear vest over 24 months          |
| Total vest | 24 months post-cliff (36 months total)                      |

Both founders (Jessica Westerhoff, Ahmad) split 50/50 in accordance with the
Bel Esprit D'Accord Trust ownership structure.

### Treasury (250,000,000 MGM — 25%)

- Controlled by Gnosis Safe multisig (3-of-5 signers minimum)
- No vesting cliff — immediately usable for operational minting
- Governed by quarterly spending proposals voted on by MGM holders

### Ecosystem Fund (120,000,000 MGM — 12%)

- 24-month linear release against approved grant milestones
- Each grant release requires a WORM-sealed approval entry

### Community Rewards (80,000,000 MGM — 8%)

- Distributed on-demand as SEALFORGE users and agents qualify
- No vesting — liquid on receipt (incentive design)

### Mesh Agent Rewards (350,000,000 MGM — 35%)

- Distributed continuously as agents generate verified WORM entries
- Rate governed by the Emission Schedule (see Section 6)

---

## 5. Utility: What MAGMA Buys

MAGMA is the exclusive medium of exchange within the SnapKitty ecosystem.

### SEALFORGE Access
| Tier      | USD Price | MGM Burn (Equivalent)   | What Burns                  |
|-----------|-----------|-------------------------|-----------------------------|
| Basic     | $49/mo    | 490 MGM/mo              | Burned on subscription renewal |
| Pro       | $249/mo   | 2,490 MGM/mo            | Burned on subscription renewal |
| Architect | $2,000+   | 20,000+ MGM             | Burned on tier activation   |

MGM burn rates are pegged to USD value at time of transaction using a Chainlink
price feed (if/when MGM is listed) or treasury-set rate pre-listing.

### Mesh Access
- Agent compute slot reservation: 100 MGM/slot/epoch
- Priority queue for task routing: 500 MGM/boost
- API rate-limit increases: 50 MGM/tier upgrade

### Governance
- 1 MGM = 1 governance vote
- Voting cap: 1% of MAX_SUPPLY (10,000,000 MGM) per address
- Proposals require 1,000,000 MGM staked to submit
- Quorum: 5% of circulating supply

### Premium Features
- WORM ledger export (archival): 200 MGM/export
- Custom HMAC signing keys: 1,000 MGM/key
- Agent persona customization: 250–5,000 MGM
- White-label SEALFORGE instances: 50,000 MGM

---

## 6. Earning Model

### Agents (SACM Mesh)
SACM agents earn MAGMA automatically when their actions are sealed into the WORM chain.

| Work Type                    | MGM Per Event |
|------------------------------|---------------|
| Task completion (standard)   | 10 MGM        |
| Knowledge ingestion (FSM)    | 25 MGM        |
| Cross-agent coordination     | 50 MGM        |
| Anomaly detection / alert    | 100 MGM       |
| Governance vote participation| 5 MGM         |

The Treasury multisig submits `wormMint()` calls daily in batch, using the HMAC-SHA256
hash of each WORM entry as the nonce. No entry can be double-spent.

### Human Users
| Activity                        | MGM Earned     |
|---------------------------------|----------------|
| SEALFORGE onboarding            | 100 MGM        |
| First seal creation             | 50 MGM         |
| Referral (per converted user)   | 200 MGM        |
| Bug report (verified)           | 500–5,000 MGM  |
| Governance proposal (passed)    | 1,000 MGM      |

---

## 7. Deflationary Mechanics

MAGMA is designed to be deflationary over time:

1. **SEALFORGE Burns** — every subscription renewal and tier upgrade burns MGM permanently.
2. **Reserve Burns** — 50,000,000 MGM reserve is burned against milestones
   ($500k ARR, $1M ARR, $3M ARR).
3. **Governance Burns** — failed proposals burn 50% of the staked submission bond.
4. **Hard Cap** — once 1,000,000,000 MGM are minted, no further minting is possible.

At $3M ARR (the revenue target), estimated annual burn from SEALFORGE subscriptions:
- Assume 5,000 Basic, 500 Pro, 50 Architect users
- Annual burn: (5,000 × 5,880) + (500 × 29,880) + (50 × 240,000)
- = 29,400,000 + 14,940,000 + 12,000,000 = **~56,340,000 MGM/year**
- At that emission rate, circulating supply contracts meaningfully within 3 years.

---

## 8. Governance Architecture

MAGMA governance uses a two-phase model:

**Phase 1 (Pre-DAO, current):**
- Architect multisig controls all upgrades and emergency functions
- MGM holders can submit non-binding sentiment votes
- Treasury operates under CPA oversight (Jessica Lee Westerhoff)

**Phase 2 (Post-$1M ARR):**
- On-chain Governor.sol module deployed
- `governanceWeight()` integrated as vote oracle
- 1% cap enforced per address
- Timelock: 48-hour delay on all passed proposals

---

## 9. Security Architecture

| Layer               | Mechanism                                         |
|---------------------|---------------------------------------------------|
| WORM nonce          | `wormEntryMinted[bytes32]` mapping prevents replay |
| Role separation     | ARCHITECT / MINTER / BURNER — no single key rules |
| Emergency pause     | `emergencyPause(reason)` — Architect only          |
| Hard cap            | `require(totalSupply() + amount <= MAX_SUPPLY)`   |
| Reentrancy guard    | OpenZeppelin `ReentrancyGuard` on mint/burn       |
| Multisig            | Gnosis Safe 3-of-5 for Treasury/Architect roles   |
| Governance cap      | `governanceWeight()` caps at 1% MAX_SUPPLY        |

---

## 10. Deployment Checklist

- [ ] Deploy Gnosis Safe 3-of-5 multisig for Treasury
- [ ] Deploy Gnosis Safe 3-of-5 multisig for Architect
- [ ] Deploy `MAGMA.sol` on Base Sepolia testnet
- [ ] Verify contract on Basescan
- [ ] Run WORM genesis mint (team/ecosystem allocations)
- [ ] Grant BURNER_ROLE to SEALFORGE upgrade contract address
- [ ] Legal review completed by Jessica Lee Westerhoff, CPA
- [ ] Qualified securities counsel sign-off before any public distribution
- [ ] Audit by external Solidity auditor (Certik, Trail of Bits, or equivalent)
- [ ] Deploy to Base mainnet

---

*CIPHER (Cryptographic Agent) — co-architecting with NOVA*
*SnapKitty SACM Mesh | 2026-05-21*
*PENDING LEGAL REVIEW — NOT FOR PUBLIC DISTRIBUTION*
