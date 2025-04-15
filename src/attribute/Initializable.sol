// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IInitializable } from "./interfaces/IInitializable.sol";

/// @title Initializable
/// @notice Library to manage the initialization lifecycle of upgradeable contracts
/// @dev `Initializable.sol` allows the creation of pseudo-constructors for upgradeable contracts. One
///      `initializer` should be declared per top-level contract. Child contracts can use the `onlyInitializer`
///      modifier to tag their internal initialization functions to ensure that they can only be called
///      from a top-level `initializer` or a constructor.
///      Name and Version are used by Proxy to validate contract upgrades.
abstract contract Initializable is IInitializable {
    bytes32 public immutable nameHash;

    /// @dev Nonzero indicates contract is initialized
    uint256 public immutable version;

    /// @dev The initializing flag
    bool private _initializing;

    constructor(string memory name_, uint256 version_) {
        nameHash = keccak256(bytes(name_));
        version = version_;
    }

    /// @dev Can only be called once per version, `version` is 1-indexed
    modifier initializer() {
        _initializing = true;

        _;

        _initializing = false;
        // TODO: Remove version from the event; has nothing to do with initialization.
        emit Initialized(version);
    }

    /// @dev Can only be called from an initializer or constructor
    modifier onlyInitializer() {
        if (!_constructing() && !_initializing) revert InitializableNotInitializingError();
        _;
    }

    /// @notice Returns whether the contract is currently being constructed
    /// @return Whether the contract is currently being constructed
    function _constructing() private view returns (bool) {
        return !(address(this).code.length > 0);
    }
}
