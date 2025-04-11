// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IEscrow {
    /// @notice Structure to hold escrow details
    struct Deposit {
        /// @dev Address of the user who deposited the funds
        address depositor;
        /// @dev Address of the token that was deposited
        address token;
        /// @dev Timestamp after which the depositor can reclaim funds if not withdrawn
        uint96 deadline;
        /// @dev Amount of tokens deposited
        uint256 amount;
    }

    /// sig: 0xe448b660
    /// @custom:error Error thrown when trying to withdraw before funds are deposited
    error EscrowNoFundsDepositedError();

    /// sig: 0x4a0ccbbc
    /// @custom:error Error thrown when trying to deposit with zero amount
    error EscrowZeroAmountError();

    /// sig: 0x53642e2d
    /// @custom:error Error thrown when token is not whitelisted
    error EscrowTokenNotWhitelistedError();

    /// sig: 0x02fca5bc
    /// @custom:error Error thrown when deadline is less than minimum required
    error EscrowInvalidDeadlineError();

    /// @notice Event emitted when funds are deposited
    event FundsDeposited(address indexed depositor, address indexed beneficiary, address indexed token, uint256 amount, uint256 deadline);

    /// @notice Event emitted when funds are withdrawn
    event FundsWithdrawn(address indexed beneficiary, address indexed token, uint256 amount);

    /// @notice Event emitted when funds are reclaimed by depositor after deadline
    event FundsReclaimed(address indexed depositor, address indexed beneficiary, address indexed token, uint256 amount);

    /// @notice Event emitted when a token is whitelisted
    event TokenWhitelisted(address indexed token, bool status);

    /// @notice Initialize the contract with initial whitelisted tokens
    /// @param _initialWhitelistedTokens Array of token addresses to whitelist
    function initialize(address[] calldata _initialWhitelistedTokens) external;

    /// @notice Updates the whitelist status of a token
    /// @param token The token address to update
    /// @param status The new whitelist status
    function updateTokenWhitelist(address token, bool status) external;

    /// @notice Deposits funds into the escrow for a specific beneficiary
    /// @param beneficiary The address of the beneficiary who can withdraw the funds
    /// @param token The token address to deposit
    /// @param amount The amount to deposit
    /// @param deadline The timestamp after which the depositor can reclaim funds if not withdrawn
    function deposit(address beneficiary, address token, uint256 amount, uint256 deadline) external;

    /// @notice Withdraws funds from the escrow for a specific token
    /// @param token The token address to withdraw
    function withdraw(address token) external;

    /// @notice Allows depositor to reclaim funds after deadline has passed
    /// @param beneficiary The address of the beneficiary who didn't withdraw the funds
    /// @param token The token address to reclaim
    function reclaimExpiredFunds(address beneficiary, address token) external;

    /// @notice Gets all depositors for a specific beneficiary
    /// @param beneficiary The address of the beneficiary
    /// @return depositors An array of depositor addresses
    function getDepositors(address beneficiary) external view returns (address[] memory depositors);

    /// @notice Gets the total amount deposited for a specific beneficiary and token
    /// @param beneficiary The address of the beneficiary
    /// @param token The token address
    /// @return totalAmount The total amount deposited
    function getTotalAmount(address beneficiary, address token) external view returns (uint256 totalAmount);

    /// @notice Gets all escrow details for a specific beneficiary
    /// @param beneficiary The address of the beneficiary
    /// @return An array of Deposit structs
    function getDeposits(address beneficiary) external view returns (Deposit[] memory);

    /// @notice Checks if a token is whitelisted
    /// @param token The token address to check
    /// @return Whether the token is whitelisted
    function isTokenWhitelisted(address token) external view returns (bool);

    /// @notice Get whitelist status of a token
    /// @param token The token address to check
    /// @return The whitelist status of the token
    function whitelistedTokens(address token) external view returns (bool);
}