// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IOwnable } from "./interfaces/IOwnable.sol";
import { Attribute } from "./Attribute.sol";

/// @title Ownable
/// @notice Library to manage the ownership lifecycle of upgradeable contracts.
/// @dev This contract has been extended from the Open Zeppelin library to include an
///      unstructured storage pattern so that it can be safely mixed in with upgradeable
///      contracts without affecting their storage patterns through inheritance.
abstract contract Ownable is IOwnable, Attribute {
    /// @custom:storage-location erc7201:equilibria.root.Ownable
    struct OwnableStorage {
        address owner;
        address pendingOwner;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant OwnableStorageLocation = 0x863176706c9b4c9b393005d0714f55de5425abea2a0b5dfac67fac0c9e2ffe00;

    /// @dev The erc7201 storage of the mix-in
    function Ownable$() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := OwnableStorageLocation
        }
    }

    /// @dev The owner address
    function owner() public view returns (address) {
        return Ownable$().owner;
    }

    /// @dev The pending owner address
    function pendingOwner() public view returns (address) {
        return Ownable$().pendingOwner;
    }

    /// @notice Initializes the contract setting `msg.sender` as the initial owner
    // solhint-disable-next-line func-name-mixedcase
    function __Ownable__constructor() internal initializer("Ownable") {
        _updateOwner(msg.sender);
    }

    /// @notice Updates the new pending owner
    /// @dev Can only be called by the current owner
    /// @param newPendingOwner New pending owner address
    function updatePendingOwner(address newPendingOwner) public onlyOwner {
        Ownable$().pendingOwner = newPendingOwner;
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
    // solhint-disable-next-line no-empty-blocks
    function _beforeAcceptOwner() internal virtual {}

    /// @notice Updates the owner address
    /// @param newOwner New owner address
    function _updateOwner(address newOwner) private {
        Ownable$().owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner {
        if (owner() != msg.sender) revert OwnableNotOwnerError(msg.sender);
        _;
    }
}
