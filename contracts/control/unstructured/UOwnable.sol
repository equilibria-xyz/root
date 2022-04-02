// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./UInitializable.sol";

/**
 * @title UOwnable
 * @notice Library to manage the ownership lifecycle of upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance.
 */
abstract contract UOwnable is UStorage, UInitializable {
    event OwnerUpdated(address indexed newOwner);
    event PendingOwnerUpdated(address indexed newPendingOwner);

    error UOwnableNotOwnerError(address sender);
    error UOwnableNotPendingOwnerError(address sender);

    /// @dev The owner address
    bytes32 private constant OWNER_SLOT = keccak256("equilibria.root.UOwnable.owner");
    function owner() public view returns (address) { return _readAddress(OWNER_SLOT); }
    function _setOwner(address newOwner) private { _write(OWNER_SLOT, newOwner); }

    /// @dev The pending owner address
    bytes32 private constant PENDING_OWNER_SLOT = keccak256("equilibria.root.UOwnable.pendingOwner");
    function pendingOwner() public view returns (address) { return _readAddress(PENDING_OWNER_SLOT); }
    function _setPendingOwner(address newPendingOwner) private { _write(PENDING_OWNER_SLOT, newPendingOwner); }

    /**
     * @notice Initializes the contract setting `msg.sender` as the initial owner
     */
    function __UOwnable__initialize() internal onlyInitializer {
        _updateOwner(msg.sender);
    }

    /**
     * @notice Updates the new pending owner
     * @dev Can only be called by the current owner
     *      New owner does not take affect until that address calls `acceptOwner()`
     * @param newPendingOwner New pending owner address
     */
    function updatePendingOwner(address newPendingOwner) public onlyOwner {
        _setPendingOwner(newPendingOwner);
        emit PendingOwnerUpdated(newPendingOwner);
    }

    /**
     * @notice Accepts and transfers the ownership of the contract to the pending owner
     * @dev Can only be called by the pending owner to ensure correctness
     */
    function acceptOwner() external {
        if (msg.sender != pendingOwner()) revert UOwnableNotPendingOwnerError(msg.sender);

        _updateOwner(pendingOwner());
        updatePendingOwner(address(0));
    }

    /**
     * @notice Updates the owner address
     * @param newOwner New owner address
     */
    function _updateOwner(address newOwner) private {
        _setOwner(newOwner);
        emit OwnerUpdated(newOwner);
    }

    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner() {
        if (owner() != msg.sender) revert UOwnableNotOwnerError(msg.sender);
        _;
    }
}
