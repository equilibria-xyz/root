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

    /// @dev Version of this contract
    uint32 public immutable versionMajor;
    uint32 public immutable versionMinor;
    uint32 public immutable versionPatch;

    /// @dev Version of the contract this contract is being upgraded from.
    uint32 public immutable versionFromMajor;
    uint32 public immutable versionFromMinor;
    uint32 public immutable versionFromPatch;

    /// @dev True while initializing
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.root.initializing");
    /// @dev True after contract has been initialized
    bytes32 private constant INITIALIZED_SLOT = keccak256("equilibria.root.initialized");

    constructor(string memory name_, Version memory version_, Version memory versionFrom_) {
        nameHash = keccak256(bytes(name_));

        versionMajor = version_.major;
        versionMinor = version_.minor;
        versionPatch = version_.patch;

        versionFromMajor = versionFrom_.major;
        versionFromMinor = versionFrom_.minor;
        versionFromPatch = versionFrom_.patch;
    }

    function version() public view returns (Version memory) {
        return Version(versionMajor, versionMinor, versionPatch);
    }

    function versionFrom() public view returns (Version memory) {
        return Version(versionFromMajor, versionFromMinor, versionFromPatch);
    }

    /// @dev Can only be called once per version, `version` is 1-indexed
    modifier initializer() {
        if (StorageSlot.getBooleanSlot(INITIALIZED_SLOT).value)
            revert InitializableAlreadyInitializedError();
        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = true;

        _;

        StorageSlot.getBooleanSlot(INITIALIZING_SLOT).value = false;
        StorageSlot.getBooleanSlot(INITIALIZED_SLOT).value = true;
        emit Initialized();
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
