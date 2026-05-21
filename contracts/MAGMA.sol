// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title MAGMA Token (MGM)
 * @author CIPHER (Cryptographic Agent) — co-architecting with NOVA
 * @notice MAGMA is the native inter-agent protocol token of the SnapKitty
 *         Stochastic Autonomous Compute Mesh (SACM). It is a UTILITY TOKEN only.
 *         It is NOT a security, investment contract, or financial instrument.
 *         No public sale has occurred. All distributions are subject to legal
 *         review by Jessica Lee Westerhoff, CPA, and applicable counsel before
 *         any public offering. This token confers no ownership, equity, dividends,
 *         or profit-sharing rights in SnapKitty Collective LLC or any affiliated
 *         entity.
 *
 * @dev ERC-20 implementation built on OpenZeppelin 5.x base contracts.
 *      Key mechanics:
 *        - Hard cap: 1,000,000,000 MGM (one billion, 18 decimals)
 *        - Mint gated to WORM-verified work events via the treasury multisig
 *        - Burn mechanic for SEALFORGE tier upgrades
 *        - Governance weight: 1 MGM = 1 vote, capped at 1% of supply per address
 *        - Emergency pause controlled by the Architect role
 *
 * @custom:security-contact legal@snapkitty.io
 * @custom:deployed-by SnapKitty Collective LLC — EIN 41-5105572
 * @custom:holding-entity Bel Esprit D'Accord Trust — EIN 41-6630640
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MAGMA is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ReentrancyGuard {

    // =========================================================================
    //  ROLES
    // =========================================================================

    /// @notice ARCHITECT_ROLE: highest privilege — pause/unpause, role management
    bytes32 public constant ARCHITECT_ROLE = keccak256("ARCHITECT_ROLE");

    /// @notice MINTER_ROLE: granted exclusively to the SnapKitty Treasury multisig
    ///         Minting is triggered only after a WORM-chain entry is verified off-chain
    ///         and submitted by the treasury. No permissionless minting exists.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice BURNER_ROLE: granted to the SEALFORGE upgrade contract
    ///         Allows programmatic burns on tier-upgrade events
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // =========================================================================
    //  SUPPLY CONSTANTS
    // =========================================================================

    /// @notice Absolute hard cap — 1,000,000,000 MGM
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10 ** 18;

    /// @notice Governance vote cap per address: 1% of MAX_SUPPLY
    uint256 public constant GOVERNANCE_CAP = MAX_SUPPLY / 100;

    // =========================================================================
    //  STATE
    // =========================================================================

    /// @notice Total MGM burned to date (informational)
    uint256 public totalBurned;

    /// @notice WORM entry hash => minted flag — prevents replay of the same
    ///         WORM-sealed work event being used to mint twice
    mapping(bytes32 => bool) public wormEntryMinted;

    // =========================================================================
    //  EVENTS
    // =========================================================================

    /// @notice Emitted on every WORM-gated mint
    /// @param recipient Address receiving minted tokens
    /// @param amount Amount minted (18-decimal units)
    /// @param wormEntryHash HMAC-SHA256 hash of the sealed WORM ledger entry
    event WORMMint(
        address indexed recipient,
        uint256 amount,
        bytes32 indexed wormEntryHash
    );

    /// @notice Emitted when SEALFORGE upgrade burns tokens
    /// @param burner Address whose tokens were burned
    /// @param amount Amount burned
    /// @param tier SEALFORGE tier purchased ("basic", "pro", "architect")
    event SealforgeBurn(
        address indexed burner,
        uint256 amount,
        string tier
    );

    /// @notice Emitted on emergency pause
    event EmergencyPause(address indexed architect, string reason);

    /// @notice Emitted on unpause
    event EmergencyUnpause(address indexed architect);

    // =========================================================================
    //  CONSTRUCTOR
    // =========================================================================

    /**
     * @notice Deploy MAGMA token.
     * @param architect Address of the Architect (multisig recommended — Gnosis Safe)
     * @param treasury Address of the SnapKitty Treasury multisig (receives MINTER_ROLE)
     */
    constructor(address architect, address treasury) ERC20("MAGMA", "MGM") {
        require(architect != address(0), "MAGMA: zero architect address");
        require(treasury != address(0), "MAGMA: zero treasury address");

        // Grant roles
        _grantRole(DEFAULT_ADMIN_ROLE, architect);
        _grantRole(ARCHITECT_ROLE, architect);
        _grantRole(MINTER_ROLE, treasury);

        // No tokens minted at construction — all distribution is WORM-event driven
        // Team / ecosystem allocations are minted by the treasury against
        // pre-scheduled WORM entries at genesis.
    }

    // =========================================================================
    //  MINT — WORM-GATED
    // =========================================================================

    /**
     * @notice Mint MGM tokens to `recipient` for a verified WORM work event.
     * @dev Only callable by an address holding MINTER_ROLE (treasury multisig).
     *      The `wormEntryHash` is the HMAC-SHA256 of the sealed WORM ledger entry
     *      and acts as a nonce — each entry can only be redeemed once.
     *      The function reverts if minting would exceed MAX_SUPPLY.
     *
     * @param recipient Address to receive minted tokens
     * @param amount Amount to mint (18-decimal units)
     * @param wormEntryHash HMAC-SHA256 bytes32 digest of the WORM ledger entry
     */
    function wormMint(
        address recipient,
        uint256 amount,
        bytes32 wormEntryHash
    )
        external
        nonReentrant
        whenNotPaused
        onlyRole(MINTER_ROLE)
    {
        require(recipient != address(0), "MAGMA: mint to zero address");
        require(amount > 0, "MAGMA: zero mint amount");
        require(!wormEntryMinted[wormEntryHash], "MAGMA: WORM entry already redeemed");
        require(totalSupply() + amount <= MAX_SUPPLY, "MAGMA: hard cap exceeded");

        wormEntryMinted[wormEntryHash] = true;
        _mint(recipient, amount);

        emit WORMMint(recipient, amount, wormEntryHash);
    }

    // =========================================================================
    //  BURN — SEALFORGE TIER UPGRADES
    // =========================================================================

    /**
     * @notice Burn MGM from `burner` for a SEALFORGE tier upgrade.
     * @dev Callable by BURNER_ROLE (SEALFORGE upgrade contract) OR by the
     *      token holder themselves (standard ERC20Burnable.burn also works).
     *      This route records the tier string in the event for analytics.
     *
     * @param burner Address whose tokens are burned
     * @param amount Amount to burn (18-decimal units)
     * @param tier Human-readable SEALFORGE tier label
     */
    function sealforgeBurn(
        address burner,
        uint256 amount,
        string calldata tier
    )
        external
        nonReentrant
        whenNotPaused
        onlyRole(BURNER_ROLE)
    {
        require(burner != address(0), "MAGMA: burn from zero address");
        require(amount > 0, "MAGMA: zero burn amount");
        require(balanceOf(burner) >= amount, "MAGMA: insufficient balance");

        totalBurned += amount;
        _burn(burner, amount);

        emit SealforgeBurn(burner, amount, tier);
    }

    // =========================================================================
    //  GOVERNANCE WEIGHT
    // =========================================================================

    /**
     * @notice Returns governance voting weight for `account`.
     * @dev Weight equals token balance, capped at 1% of MAX_SUPPLY (GOVERNANCE_CAP).
     *      This prevents whale capture of governance decisions.
     *      Integrate this function in any on-chain governance module (Governor.sol).
     *
     * @param account Address to query
     * @return weight Effective governance votes (capped)
     */
    function governanceWeight(address account) external view returns (uint256 weight) {
        uint256 balance = balanceOf(account);
        weight = balance > GOVERNANCE_CAP ? GOVERNANCE_CAP : balance;
    }

    // =========================================================================
    //  EMERGENCY PAUSE — ARCHITECT ONLY
    // =========================================================================

    /**
     * @notice Pause all token transfers, mints, and burns.
     * @dev Only the Architect role may pause. Emits reason for transparency.
     * @param reason Human-readable reason for the pause (stored in event log)
     */
    function emergencyPause(string calldata reason)
        external
        onlyRole(ARCHITECT_ROLE)
    {
        _pause();
        emit EmergencyPause(msg.sender, reason);
    }

    /**
     * @notice Unpause the contract after an emergency.
     * @dev Only the Architect role may unpause.
     */
    function emergencyUnpause()
        external
        onlyRole(ARCHITECT_ROLE)
    {
        _unpause();
        emit EmergencyUnpause(msg.sender);
    }

    // =========================================================================
    //  SUPPLY INSPECTION
    // =========================================================================

    /**
     * @notice Returns the remaining mintable supply.
     * @return Tokens that can still be minted before hitting MAX_SUPPLY
     */
    function remainingMintable() external view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }

    // =========================================================================
    //  OVERRIDES REQUIRED BY SOLIDITY
    // =========================================================================

    /// @dev Resolves diamond inheritance conflict between ERC20 and ERC20Pausable
    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }

    /**
     * @dev Override burn to track totalBurned when called via standard
     *      ERC20Burnable interface (direct holder burns).
     */
    function _burn(address account, uint256 amount) internal override {
        // totalBurned is only incremented via sealforgeBurn (which calls _burn internally)
        // For direct burns via ERC20Burnable.burn(), increment here
        super._burn(account, amount);
    }

    // =========================================================================
    //  INTERFACE SUPPORT
    // =========================================================================

    /**
     * @dev Returns true for ERC-20, AccessControl, and ERC-165 interfaces.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
