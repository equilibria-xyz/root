// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { Ownable } from "./Ownable.sol";

/// @title OwnerDelegatable
/// @notice Allows the owner to delegate governance voting power for held tokens
abstract contract OwnerDelegatable is Ownable {
    /// @notice Delegates voting power for a specific token to an address
    /// @dev Can only be called by the owner
    /// @param token The IVotes-compatible token to delegate
    /// @param delegatee The address to delegate voting power to
    function delegate(IVotes token, address delegatee) public virtual onlyOwner {
        token.delegate(delegatee);
    }
}
