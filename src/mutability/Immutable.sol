// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Contract } from "./Contract.sol";

/// @title Immutable
/// @notice Implementation of Contract for non-upgradeable contracts.
abstract contract Immutable is Contract {
    /// @dev Is initializing while inside of the constructor.
    function _constructing() internal view override returns (bool) {
        return !(address(this).code.length > 0);
    }
}

