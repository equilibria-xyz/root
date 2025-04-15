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
    /// @dev Identifies the contract
    string public name;

    /// @dev Nonzero indicates contract is initialized
    uint256 public version;

    /// @dev The initializing flag
    bool private _initializing;

    /// @dev Can only be called once per version, `version` is 1-indexed
    /// @param name_ Identifies the contract, must not change
    modifier initializer(string memory name_, uint256 version_) {
        name = name_;
        version = version_;

        _initializing = true;

        _;

        _initializing = false;
        emit Initialized(version_);
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
