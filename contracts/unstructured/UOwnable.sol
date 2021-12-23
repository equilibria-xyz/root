// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @title UOwnable
 * @notice Library to manage the ownership lifecycle of upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance.
 */
abstract contract UOwnable {
    /// @dev unstructured storage slot for the owner address
    bytes32 private constant OWNER_SLOT = keccak256("equilibria.utils.UOwnable.owner");

    /// @dev unstructured storage slot for the pending owner address
    bytes32 private constant PENDING_OWNER_SLOT = keccak256("equilibria.utils.UOwnable.pendingOwner");

    event OwnerUpdated(address indexed newOwner);
    event PendingOwnerUpdated(address indexed newPendingOwner);

    error UOwnableNotOwnerError(address sender);
    error UOwnableNotPendingOwnerError(address sender);

    /**
     * @notice Initializes the contract setting `msg.sender` as the initial owner
     */
    function UOwnable__initialize() internal {
        _setOwner(msg.sender);
    }

    /**
     * @notice Returns the address of the current owner
     * @return result Current owner
     */
    function owner() public view returns (address result) {
        bytes32 slot = OWNER_SLOT;
        assembly {
            result := sload(slot)
        }
    }

    /**
     * @notice Returns the address of the pending owner
     * @return result Pending owner
     */
    function pendingOwner() public view returns (address result) {
        bytes32 slot = PENDING_OWNER_SLOT;
        assembly {
            result := sload(slot)
        }
    }

    /**
     * @notice Sets a new pending owner
     * @dev Can only be called by the current owner
     *      New owner does not take affect until that address calls `acceptOwner()`
     * @param newPendingOwner New pending owner address
     */
    function setPendingOwner(address newPendingOwner) external onlyOwner {
        _setPendingOwner(newPendingOwner);
    }

    /**
     * @notice Accepts and transfers the ownership of the contract to the pending owner
     * @dev Can only be called by the pending owner to ensure correctness
     */
    function acceptOwner() external {
        if (msg.sender != pendingOwner()) revert UOwnableNotPendingOwnerError(msg.sender);

        _setOwner(pendingOwner());
        _setPendingOwner(address(0));
    }

    /**
     * @notice Sets the new owner address in unstructured storage
     * @dev Internal helper
     * @param newOwner New owner address to store
     */
    function _setOwner(address newOwner) private {
        bytes32 slot = OWNER_SLOT;
        assembly {
            sstore(slot, newOwner)
        }

        emit OwnerUpdated(newOwner);
    }

    /**
     * @notice Sets the new pending owner address in unstructured storage
     * @dev Internal helper
     * @param newPendingOwner New pending owner address to store
     */
    function _setPendingOwner(address newPendingOwner) private {
        bytes32 slot = PENDING_OWNER_SLOT;
        assembly {
            sstore(slot, newPendingOwner)
        }

        emit PendingOwnerUpdated(newPendingOwner);
    }

    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner() {
        if (owner() != msg.sender) revert UOwnableNotOwnerError(msg.sender);
        _;
    }
}
