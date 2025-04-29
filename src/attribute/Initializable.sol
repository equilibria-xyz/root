// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IInitializable } from "./interfaces/IInitializable.sol";

/// @title Initializable
/// @notice Library to manage the initialization lifecycle of upgradeable contracts
/// @dev `Initializable.sol` allows the creation of pseudo-constructors for upgradeable contracts. One
///      `initializer` should be declared per top-level contract. Child contracts can use the `onlyInitializer`
///      modifier to tag their internal initialization functions to ensure that they can only be called
///      from a top-level `initializer` or a constructor.
abstract contract Initializable is IInitializable {
    /// @notice The slot of the initialized version
    bytes32 private constant VERSION_SLOT = keccak256("equilibria.root.Initializable.version");

    /// @notice The slot of the initializing flag
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.root.Initializable.initializing");

    /// @dev Can only be called once per version, `version` is 1-indexed
    modifier initializer(uint256 version) {
        if (version == 0) revert InitializableZeroVersionError();
        if (StorageSlot.getUint256Slot(VERSION_SLOT).value >= version)
            revert InitializableAlreadyInitializedError(version);

        StorageSlot.getUint256Slot(VERSION_SLOT).value = version;
        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = true;

        _;

        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = false;
        emit Initialized(version);
    }

    /// @dev Can only be called from an initializer or constructor
    modifier onlyInitializer() {
        if (!_constructing() && !StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value)
            revert InitializableNotInitializingError();
        _;
    }

    /// @notice Returns whether the contract is currently being constructed
    /// @return Whether the contract is currently being constructed
    function _constructing() private view returns (bool) {
        return !(address(this).code.length > 0);
    }
}
