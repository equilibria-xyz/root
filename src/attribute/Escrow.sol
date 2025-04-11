// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Ownable } from "src/attribute/Ownable.sol";
import { IEscrow } from "src/attribute/interfaces/IEscrow.sol";

/// @title Escrow
/// @notice An escrow contract that allows depositors to lock funds for specific beneficiaries with token whitelisting
contract Escrow is IEscrow, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    /// @notice Minimum deadline period (1 day in seconds)
    uint96 public constant MINIMUM_DEADLINE = 1 days;

    /// @notice Mapping from beneficiary to their escrow details
    mapping(address => Deposit[]) private deposits;

    /// @notice Mapping of whitelisted tokens
    mapping(address => bool) public whitelistedTokens;

    function initialize(address[] calldata _initialWhitelistedTokens) external initializer(1) {
        __Ownable__initialize();
        uint256 length = _initialWhitelistedTokens.length;
        for (uint256 i = 0; i < length;) {
            whitelistedTokens[_initialWhitelistedTokens[i]] = true;
            emit TokenWhitelisted(_initialWhitelistedTokens[i], true);
            unchecked { ++i; }
        }
    }

    /// @notice Updates the whitelist status of a token
    /// @param token The token address to update
    /// @param status The new whitelist status
    function updateTokenWhitelist(address token, bool status) external onlyOwner {
        whitelistedTokens[token] = status;
        emit TokenWhitelisted(token, status);
    }

    /// @notice Deposits funds into the escrow for a specific beneficiary
    /// @param beneficiary The address of the beneficiary who can withdraw the funds
    /// @param token The token address to deposit
    /// @param amount The amount to deposit
    /// @param deadline The timestamp after which the depositor can reclaim funds if not withdrawn
    function deposit(address beneficiary, address token, uint256 amount, uint256 deadline) external {
        if (amount == 0) revert EscrowZeroAmountError();
        if (!whitelistedTokens[token]) revert EscrowTokenNotWhitelistedError();
        if (deadline < block.timestamp + MINIMUM_DEADLINE) revert EscrowInvalidDeadlineError();

        // Add a new escrow entry for the beneficiary
        deposits[beneficiary].push(Deposit({
            depositor: msg.sender,
            token: token,
            deadline: uint96(deadline),
            amount: amount
        }));

        // Transfer tokens from sender to this contract
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        emit FundsDeposited(msg.sender, beneficiary, token, amount, deadline);
    }

    /// @notice Withdraws funds from the escrow for a specific token
    /// @dev Only the beneficiary can call this function
    /// @param token The token address to withdraw
    function withdraw(address token) external nonReentrant {
        Deposit[] storage beneficiaryDeposits = deposits[msg.sender];
        uint256 length = beneficiaryDeposits.length;
        uint256 amount;

        for (uint256 i = 0; i < length;) {
            if (beneficiaryDeposits[i].token == token) {
                unchecked {
                    amount += beneficiaryDeposits[i].amount;
                }
                // Replace with the last element and pop
                beneficiaryDeposits[i] = beneficiaryDeposits[length - 1];
                beneficiaryDeposits.pop();
                unchecked { --length; }
            } else {
                unchecked { ++i; }
            }
        }

        if (amount == 0) revert EscrowNoFundsDepositedError();

        IERC20(token).safeTransfer(msg.sender, amount);

        emit FundsWithdrawn(msg.sender, token, amount);
    }

    /// @notice Allows depositor to reclaim funds after deadline has passed
    /// @param beneficiary The address of the beneficiary who didn't withdraw the funds
    /// @param token The token address to reclaim
    function reclaimExpiredFunds(address beneficiary, address token) external nonReentrant {
        Deposit[] storage beneficiaryDeposits = deposits[beneficiary];
        uint256 length = beneficiaryDeposits.length;
        uint256 totalReclaimAmount;
        address sender = msg.sender;
        uint256 timestamp = block.timestamp;

        for (uint256 i = 0; i < length;) {
            Deposit storage currentDeposit = beneficiaryDeposits[i];
            if (currentDeposit.token == token &&
                currentDeposit.depositor == sender &&
                timestamp > currentDeposit.deadline) {

                unchecked {
                    totalReclaimAmount += currentDeposit.amount;
                }

                // Replace with the last element and pop
                beneficiaryDeposits[i] = beneficiaryDeposits[length - 1];
                beneficiaryDeposits.pop();
                unchecked { --length; }
            } else {
                unchecked { ++i; }
            }
        }

        if (totalReclaimAmount == 0) revert EscrowNoFundsDepositedError();

        IERC20(token).safeTransfer(sender, totalReclaimAmount);

        emit FundsReclaimed(sender, beneficiary, token, totalReclaimAmount);
    }

    /// @notice Gets all depositors for a specific beneficiary
    /// @param beneficiary The address of the beneficiary
    /// @return depositors An array of depositor addresses
    function getDepositors(address beneficiary) external view returns (address[] memory depositors) {
        Deposit[] storage beneficiaryDeposits = deposits[beneficiary];
        uint256 length = beneficiaryDeposits.length;
        depositors = new address[](length);

        for (uint256 i = 0; i < length;) {
            depositors[i] = beneficiaryDeposits[i].depositor;
            unchecked { ++i; }
        }
    }

    /// @notice Gets the total amount deposited for a specific beneficiary and token
    /// @param beneficiary The address of the beneficiary
    /// @param token The token address
    /// @return totalAmount The total amount deposited
    function getTotalAmount(address beneficiary, address token) external view returns (uint256 totalAmount) {
        Deposit[] storage beneficiaryDeposits = deposits[beneficiary];
        uint256 length = beneficiaryDeposits.length;

        for (uint256 i = 0; i < length;) {
            if (beneficiaryDeposits[i].token == token) {
                unchecked {
                    totalAmount += beneficiaryDeposits[i].amount;
                }
            }
            unchecked { ++i; }
        }
    }

    /// @notice Gets all escrow details for a specific beneficiary
    /// @param beneficiary The address of the beneficiary
    /// @return An array of Escrow structs
    function getDeposits(address beneficiary) external view returns (Deposit[] memory) {
        return deposits[beneficiary];
    }

    /// @notice Checks if a token is whitelisted
    /// @param token The token address to check
    /// @return Whether the token is whitelisted
    function isTokenWhitelisted(address token) external view returns (bool) {
        return whitelistedTokens[token];
    }
}
