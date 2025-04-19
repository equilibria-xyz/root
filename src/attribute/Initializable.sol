// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IInitializable } from "./interfaces/IInitializable.sol";
import { Version, VersionLib } from "./types/Version.sol";

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

    // TODO: Check whether converting struct and these to 6 uint256s will save code size
    /// @dev Version of this contract
    uint256 internal immutable _version;

    /// @dev Version of the contract this contract is being upgraded from.
    uint256 internal immutable _versionFrom;

    /// @dev True while initializing; stored in named slots to avoid storage collisions
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.root.initializable.initializing");
    /// @dev Populated with version after contract has been initialized
    bytes32 private constant INITIALIZED_VERSION_SLOT = keccak256("equilibria.root.initializable.initializedVersion");

    constructor(string memory name_, Version memory version_, Version memory versionFrom_) {
        nameHash = keccak256(bytes(name_));

        _version = version_.toUnsigned();
        _versionFrom = versionFrom_.toUnsigned();
    }

    /// @notice Returns the version of the contract as a human-readable struct
    function versionReadable() external view returns (Version memory) {
        return VersionLib.from(_version);
    }

    /// @dev Returns an integer representation of contract version
    function version() public view returns (uint256) {
        return _version;
    }

    /// @dev Returns an integer representation of the version this contract will be/was upgraded from
    function versionFrom() public view returns (uint256) {
        return _versionFrom;
    }

    /// @dev Returns true while initializer is executing
    function initializing() internal view returns (bool) {
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
    modifier initializer(Version memory version_) {
        // TODO: Do a code size analysis on hashing the version rather than bit fiddling.
        uint256 initializedVersion_ = StorageSlot.getUint256Slot(INITIALIZED_VERSION_SLOT).value;
        if (initializedVersion_ != 0 && initializedVersion_ == version())
            revert InitializableAlreadyInitializedError();
        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = true;

        // only execute if the version stated in initialization matches the contract version
        if (version_.toUnsigned() == version())
            _;

        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = false;
        StorageSlot.getUint256Slot(INITIALIZED_VERSION_SLOT).value = version();
        emit Initialized();
    }

    /// @dev Can only be called from an initializer or constructor
    modifier onlyInitializer() {
        if (!_constructing() && !StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value)
            revert InitializableNotInitializingError();
        _;
    }
}
