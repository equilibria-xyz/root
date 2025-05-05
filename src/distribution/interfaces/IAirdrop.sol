// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

/// Inspired by Uniswap https://github.com/Uniswap/merkle-distributor/blob/master/contracts/interfaces/IMerkleDistributor.sol at commit 25a79e8.
interface IAirdrop {
    /// @dev This event is triggered whenever a call to #claim succeeds.
    event Claimed(uint256 index, address indexed account, uint256 amount, bytes32 indexed merkleRoot);

    /// @dev This event is triggered when adding a new distribution
    event DistributionAdded(address indexed token, bytes32 indexed merkleRoot);

    error AlreadyClaimed();
    error InvalidProof();
    error DistributionAlreadyExists();

    /// @notice Returns true if the index has been marked claimed.
    /// @param index The index into the merkle tree
    /// @param merkleRoot The merkle root of the merkle tree
    /// @return True if the index has been marked claimed, false otherwise
    function isClaimed(uint256 index, bytes32 merkleRoot) external view returns (bool);

    /// @notice Claim the given amount of the token to the given address
    /// @param account The address of the claimer
    /// @param index The indexes into the merkle trees
    /// @param amount The amounts of tokens to claim
    /// @param merkleProof An array of bytes32 hashes representing the merkle proofs
    /// @param merkleRoot The merkle root of the merkle tree
    function claim(
        address account,
        uint256[] calldata index,
        uint256[] calldata amount,
        bytes32[][] calldata merkleProof,
        bytes32[] calldata merkleRoot
    ) external;

    /// @notice Add a new distribution to the contract.
    /// @param token The address of the token to distribute
    /// @param merkleRoot The merkle root of the merkle tree containing account balances available to claim
    function addDistributions(address token, bytes32 merkleRoot) external;
}
