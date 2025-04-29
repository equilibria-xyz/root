// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IImplementation } from "./interfaces/IImplementation.sol";
import { IMutable } from "./interfaces/IMutable.sol";

/// @title Initializable
/// @notice Library to manage the initialization lifecycle of upgradeable contracts
/// @dev `Initializable.sol` allows the creation of pseudo-constructors for upgradeable contracts. One
///      `initializer` should be declared per top-level contract. Child contracts can use the `onlyInitializer`
///      modifier to tag their internal initialization functions to ensure that they can only be called
///      from a top-level `initializer` or a constructor.
abstract contract Implementation is IImplementation {
    /// @dev Can only be called once per version, `version` is 1-indexed
    function __initialize(bytes memory data) internal virtual returns (uint256 version);
}
