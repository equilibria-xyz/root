    // SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IInitializable } from "./interfaces/IInitializable.sol";
import { Version } from "./types/Version.sol";

/// @title Initializable
/// @notice Library to manage the initialization lifecycle of upgradeable contracts
/// @dev `Initializable.sol` allows the creation of pseudo-constructors for upgradeable contracts. One
///      `initializer` should be declared per top-level contract. Child contracts can use the `onlyInitializer`
///      modifier to tag their internal initialization functions to ensure that they can only be called
///      from a top-level `initializer` or a constructor.
///      Name and Version are used by Proxy to validate contract upgrades.
abstract contract Initializable is IInitializable {
    /// @dev Hash of the contract name, used to ensure the correct contract is being upgraded.
    bytes32 public immutable nameHash;
    /// @notice The slot of the initialized version
    bytes32 private constant VERSION_SLOT = keccak256("equilibria.root.Initializable.version");

    /// @dev Version of this contract
    Version public immutable version;
    /// @notice The slot of the initializing flag
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.root.Initializable.initializing");

    /// @dev Version of the contract this contract is being upgraded from.
    Version public immutable target;

    constructor(string memory name_, Version version_, Version target_) {
        nameHash = keccak256(bytes(name_));

        version = version_;
        target = target_;
    }

    /// @dev Returns true while initializer is executing
    function _initializing() internal view returns (bool) {
        return StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value;
    }

    /// @dev Returns whether the contract is currently being constructed
    /// @return Whether the contract is currently being constructed
    function _constructing() private view returns (bool) {
        return !(address(this).code.length > 0);
    }

    /// @dev Can only be called once per version, `version` is 1-indexed.
    ///      Prevents execution of initialize function if versions do not match.
    /// @param version_ The version for which initialization logic pertains.
    modifier initializer(Version version_) {

        bytes32 initializedVersion_ = StorageSlot.getBytes32Slot(VERSION_SLOT).value;
        if (initializedVersion_ != bytes32(0) && initializedVersion_ == Version.unwrap(version))
            revert InitializableAlreadyInitializedError();

        // only execute if the version stated in initialization matches the contract version
        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = true;
        if (version_ == version) _;
        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = false;

        StorageSlot.getBytes32Slot(VERSION_SLOT).value = Version.unwrap(version);
        emit Initialized(version);
    }

    /// @dev Can only be called from an initializer or constructor
    modifier onlyInitializer {
        if (!_constructing() && !_initializing()) revert InitializableNotInitializingError();
        _;
    }
}
