// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Ownable as RootOwnable } from "../attribute/Ownable.sol";
import { Derived } from "../mutability/Derived.sol";

/// @title OwnableStub
/// @notice A simple stub contract that can accept ownership but cannot do anything else.
/// @dev This contract is used to relinquish ownership of a contract by transferring ownership to this stub.
contract OwnableStub is Derived, RootOwnable {
    constructor() {
        __Ownable__constructor();
    }

    /// @notice Accepts ownership of the contract
    /// @dev Can only be called by the stub owner to avoid permissionless finalization.
    function acceptOwner(address ownable) external onlyOwner {
        RootOwnable(ownable).acceptOwner();
    }
}
