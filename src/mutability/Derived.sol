// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Contract } from "./Contract.sol";

/// @title Derived
/// @notice Implementation of Contract for non-upgradeable contracts.
abstract contract Derived is Contract {
    /// @dev Is initializing while inside of the constructor.
    function _constructing() internal view override returns (bool) {
        return !(address(this).code.length > 0);
    }

    /// @dev Hook to define the deployer of the contract.
    function _deployer() internal view override returns (address) {
        return msg.sender;
    }
}

