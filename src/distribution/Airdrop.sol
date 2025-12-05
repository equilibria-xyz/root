// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Derived } from "../mutability/Derived.sol";
import { Ownable } from "../attribute/Ownable.sol";
import { Token18 } from "../token/types/Token18.sol";
import { UFixed18 } from "../number/types/UFixed18.sol";
import { IAirdrop } from "./interfaces/IAirdrop.sol";

/// @title Airdrop
/// @notice A contract for distributing token airdrops using a merkle tree
/// @dev Inspired by Uniswap https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol at commit 25a79e8
contract Airdrop is IAirdrop, Derived, Ownable {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    mapping(bytes32 merkleRoot => Token18 token) public distributions;
    mapping(bytes32 merkleRoot => mapping(uint256 index => uint256 claimed)) private _claimed;
    EnumerableSet.Bytes32Set private _merkleRoots;

    constructor() {
        __Ownable__constructor();
    }

    /// @inheritdoc IAirdrop
    function addDistributions(Token18 token, bytes32 merkleRoot) external override onlyOwner {
        if (_merkleRoots.contains(merkleRoot)) revert AirdropDistributionAlreadyExists();
        distributions[merkleRoot] = token;
        _merkleRoots.add(merkleRoot);

        emit DistributionAdded(token, merkleRoot);
    }

    /// @notice Withdraw unused tokens from the contract
    /// @param token The token to withdraw
    /// @param amount The amount to withdraw
    function drain(Token18 token, UFixed18 amount) external onlyOwner {
        token.push(msg.sender, amount);
        emit Drained(token, msg.sender, amount);
    }

    /// @notice Remove an invalid/incorrect merkle root
    /// @param merkleRoot The merkle root to remove
    function removeDistribution(bytes32 merkleRoot) external onlyOwner {
        if (!_merkleRoots.contains(merkleRoot)) revert AirdropRootDoesNotExist();
        _merkleRoots.remove(merkleRoot);
        distributions[merkleRoot] = Token18.wrap(address(0));
        emit DistributionRemoved(merkleRoot);
    }

    /// @inheritdoc IAirdrop
    function claim(
        address account,
        uint256[] calldata index,
        UFixed18[] calldata amount,
        bytes32[][] calldata merkleProof,
        bytes32[] calldata merkleRoot
    ) public override {
        for (uint256 i = 0; i < index.length; i++) {
            if (claimed(index[i], merkleRoot[i])) revert AirdropAlreadyClaimed();

            // Verify the merkle proof.
            bytes32 node = keccak256(abi.encodePacked(index[i], account, UFixed18.unwrap(amount[i])));
            if (!MerkleProof.verify(merkleProof[i], merkleRoot[i], node)) revert AirdropInvalidProof();

            // Mark it claimed and send the token.
            _updateClaimed(index[i], merkleRoot[i]);
            distributions[merkleRoot[i]].push(account, amount[i]);

            emit Claimed(index[i], account, amount[i], merkleRoot[i]);
        }
    }

    /// @inheritdoc IAirdrop
    function claimed(uint256 index, bytes32 merkleRoot) public view override returns (bool) {
        (uint256 claimedWordIndex, uint256 claimedBitIndex) = (index / 256, index % 256);
        uint256 claimedWord = _claimed[merkleRoot][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /// @notice Sets the index as claimed
    /// @param index The index to set as claimed
    /// @param merkleRoot The merkle root
    function _updateClaimed(uint256 index, bytes32 merkleRoot) private {
        (uint256 claimedWordIndex, uint256 claimedBitIndex) = (index / 256, index % 256);
        _claimed[merkleRoot][claimedWordIndex] = _claimed[merkleRoot][claimedWordIndex] | (1 << claimedBitIndex);
    }

    /// @inheritdoc IAirdrop
    function merkleRoots() external view override returns (bytes32[] memory) {
        return _merkleRoots.values();
    }
}
