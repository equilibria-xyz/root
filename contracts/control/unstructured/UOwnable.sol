// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./UInitializable.sol";
import "../interfaces/IOwnable.sol";
import "../../storage/UStorage.sol";

/**
 * @title UOwnable
 * @notice Library to manage the ownership lifecycle of upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance.
 */
abstract contract UOwnable is IOwnable, UInitializable {
    /// @dev The owner address
    AddressStorage private constant _owner = AddressStorage.wrap(keccak256("equilibria.root.UOwnable.owner"));
    function owner() public view returns (address) { return _owner.read(); }

    /// @dev The pending owner address
    AddressStorage private constant _pendingOwner = AddressStorage.wrap(keccak256("equilibria.root.UOwnable.pendingOwner"));
    function pendingOwner() public view returns (address) { return _pendingOwner.read(); }

    /**
     * @notice Initializes the contract setting `msg.sender` as the initial owner
     */
    function __UOwnable__initialize() internal onlyInitializer {
        _updateOwner(_sender());
    }

    /**
     * @notice Updates the new pending owner
     * @dev Can only be called by the current owner
     *      New owner does not take affect until that address calls `acceptOwner()`
     * @param newPendingOwner New pending owner address
     */
    function updatePendingOwner(address newPendingOwner) public onlyOwner {
        _pendingOwner.store(newPendingOwner);
        emit PendingOwnerUpdated(newPendingOwner);
    }

    /**
     * @notice Accepts and transfers the ownership of the contract to the pending owner
     * @dev Can only be called by the pending owner to ensure correctness. Calls to the `_beforeAcceptOwner` hook
     *      to perform logic before updating ownership.
     */
    function acceptOwner() public {
        _beforeAcceptOwner();

        if (_sender() != pendingOwner()) revert UOwnableNotPendingOwnerError(_sender());

        _updateOwner(pendingOwner());
        updatePendingOwner(address(0));
    }


    /// @dev Hook for inheriting contracts to perform logic before accepting ownership
    function _beforeAcceptOwner() internal virtual {}

    /**
     * @notice Updates the owner address
     * @param newOwner New owner address
     */
    function _updateOwner(address newOwner) private {
        _owner.store(newOwner);
        emit OwnerUpdated(newOwner);
    }

    function _sender() internal view virtual returns (address) {
        return msg.sender;
    }

    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner {
        if (owner() != _sender()) revert UOwnableNotOwnerError(_sender());
        _;
    }
}
