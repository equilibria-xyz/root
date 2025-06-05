// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { Token18 } from "../../token/types/Token18.sol";
import { UFixed18 } from "../../number/types/UFixed18.sol";
/// Inspired by Uniswap https://github.com/Uniswap/merkle-distributor/blob/master/contracts/interfaces/IMerkleDistributor.sol at commit 25a79e8.
interface IAirdrop {
    /// @dev This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address indexed account, UFixed18 amount, bytes32 indexed merkleRoot);

    /// @dev This event is triggered when adding a new distribution
    event DistributionAdded(Token18 indexed token, bytes32 indexed merkleRoot);

    /// @dev This event is triggered when removing a distribution
    event DistributionRemoved(bytes32 indexed merkleRoot);

    /// @dev This event is triggered when draining tokens from the contract
    event Drained(Token18 indexed token, address indexed to, UFixed18 amount);

    // sig: 0xe4ca4c0b
    /// @custom:error Airdrop is already claimed
    error AirdropAlreadyClaimed();

    // sig: 0x8738f09b
    /// @custom:error Invalid merkle proof provided
    error AirdropInvalidProof();

    // sig: 0xac4d0508
    /// @custom:error Distribution with same merkle root already exists
    error AirdropDistributionAlreadyExists();

    // sig: 0x0adf5a70
    /// @custom:error Airdrop root does not exist
    error AirdropRootDoesNotExist();

    /// @notice Returns true if the index has been marked claimed.
    /// @param index The index into the merkle tree
    /// @param merkleRoot The merkle root of the merkle tree
    /// @return True if the index has been marked claimed, false otherwise
    function claimed(uint256 index, bytes32 merkleRoot) external view returns (bool);

    /// @notice Claim the given amount of the token to the given address
    /// @param account The address of the claimer
    /// @param index The indexes into the merkle trees
    /// @param amount The amounts of tokens to claim
    /// @param merkleProof An array of bytes32 hashes representing the merkle proofs
    /// @param merkleRoot The merkle root of the merkle tree
    function claim(
        address account,
        uint256[] calldata index,
        UFixed18[] calldata amount,
        bytes32[][] calldata merkleProof,
        bytes32[] calldata merkleRoot
    ) external;

    /// @notice Add a new distribution to the contract.
    /// @param token The address of the token to distribute
    /// @param merkleRoot The merkle root of the merkle tree containing account balances available to claim
    function addDistributions(Token18 token, bytes32 merkleRoot) external;

    /// @notice Remove a distribution from the contract.
    /// @param merkleRoot The merkle root of the merkle tree to remove
    function removeDistribution(bytes32 merkleRoot) external;

    /// @notice Withdraw unused tokens from the contract.
    /// @param token The address of the token to withdraw
    /// @param amount The amount of tokens to withdraw
    function drain(Token18 token, UFixed18 amount) external;

    /// @notice Returns the list of all merkle roots
    /// @return An array of all merkle roots
    function merkleRoots() external view returns (bytes32[] memory);
}
