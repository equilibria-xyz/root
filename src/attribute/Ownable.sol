// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Initializable } from "./Initializable.sol";
import { IOwnable } from "./interfaces/IOwnable.sol";
import { Version } from "./types/Version.sol";

/// @title Ownable
/// @notice Library to manage the ownership lifecycle of upgradeable contracts.
/// @dev This contract has been extended from the Open Zeppelin library to include an
///      unstructured storage pattern so that it can be safely mixed in with upgradeable
///      contracts without affecting their storage patterns through inheritance.
abstract contract Ownable is IOwnable, Initializable {
    /// @dev Pass name and version to the Initializable constructor
    constructor(
        string memory name,
        Version version,
        Version versionFrom
    ) Initializable(name, version, versionFrom) {}

    /// @dev The owner address
    address private _owner;
    function owner() public view returns (address) { return _owner; }

    /// @dev The pending owner address
    address private _pendingOwner;
    function pendingOwner() public view returns (address) { return _pendingOwner; }

    /// @notice Initializes the contract setting `msg.sender` as the initial owner
    function __Ownable__initialize() internal onlyInitializer {
        _updateOwner(_sender());
    }

    /// @notice Updates the new pending owner
    /// @dev Can only be called by the current owner
    /// @param newPendingOwner New pending owner address
    function updatePendingOwner(address newPendingOwner) public onlyOwner {
        _pendingOwner = newPendingOwner;
        emit PendingOwnerUpdated(newPendingOwner);
    }

    /// @notice Accepts and transfers the ownership of the contract to the pending owner
    /// @dev Can only be called by the pending owner to ensure correctness. Calls to the `_beforeAcceptOwner` hook
    ///      to perform logic before updating ownership.
    function acceptOwner() public {
        _beforeAcceptOwner();

        if (_sender() != pendingOwner()) revert OwnableNotPendingOwnerError(_sender());

        _updateOwner(pendingOwner());
        updatePendingOwner(address(0));
    }

    /// @dev Hook for inheriting contracts to perform logic before accepting ownership
    function _beforeAcceptOwner() internal virtual {}

    /// @notice Updates the owner address
    /// @param newOwner New owner address
    function _updateOwner(address newOwner) private {
        _owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    function _sender() internal view virtual returns (address) {
        return msg.sender;
    }

    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner {
        if (owner() != _sender()) revert OwnableNotOwnerError(_sender());
        _;
    }
}
