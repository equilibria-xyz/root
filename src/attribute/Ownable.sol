// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IOwnable } from "./interfaces/IOwnable.sol";
import { Attribute } from "../mutability/Attribute.sol";

/// @title Ownable
/// @notice Library to manage the ownership lifecycle of upgradeable contracts.
/// @dev This contract has been extended from the Open Zeppelin library to include an
///      unstructured storage pattern so that it can be safely mixed in with upgradeable
///      contracts without affecting their storage patterns through inheritance.
abstract contract Ownable is IOwnable, Attribute {
    /// @dev The slot of the owner address
    bytes32 private constant OWNER_SLOT = keccak256("equilibria.root.Ownable.owner");

    /// @dev The slot of the pending owner address
    bytes32 private constant PENDING_OWNER_SLOT = keccak256("equilibria.root.Ownable.pendingOwner");

    /// @dev The owner address
    function owner() public view returns (address) {
        return StorageSlot.getAddressSlot(OWNER_SLOT).value;
    }

    /// @dev The pending owner address
    function pendingOwner() public view returns (address) {
        return StorageSlot.getAddressSlot(PENDING_OWNER_SLOT).value;
    }

    /// @notice Initializes the contract setting `msg.sender` as the initial owner
    function __Ownable__constructor() initializer("Ownable") internal {
        _updateOwner(msg.sender);
    }

    /// @notice Updates the new pending owner
    /// @dev Can only be called by the current owner
    /// @param newPendingOwner New pending owner address
    function updatePendingOwner(address newPendingOwner) public onlyOwner {
        StorageSlot.getAddressSlot(PENDING_OWNER_SLOT).value = newPendingOwner;
        emit PendingOwnerUpdated(newPendingOwner);
    }

    /// @notice Accepts and transfers the ownership of the contract to the pending owner
    /// @dev Can only be called by the pending owner to ensure correctness. Calls to the `_beforeAcceptOwner` hook
    ///      to perform logic before updating ownership.
    function acceptOwner() public {
        _beforeAcceptOwner();

        if (msg.sender != pendingOwner()) revert OwnableNotPendingOwnerError(msg.sender);

        _updateOwner(pendingOwner());
        updatePendingOwner(address(0));
    }

    /// @dev Hook for inheriting contracts to perform logic before accepting ownership
    function _beforeAcceptOwner() internal virtual {}

    /// @notice Updates the owner address
    /// @param newOwner New owner address
    function _updateOwner(address newOwner) private {
        StorageSlot.getAddressSlot(OWNER_SLOT).value = newOwner;
        emit OwnerUpdated(newOwner);
    }

    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner {
        if (owner() != msg.sender) revert OwnableNotOwnerError(msg.sender);
        _;
    }
}
