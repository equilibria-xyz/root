// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/crosschain/CrossChainEnabled.sol";
import "../UInitializable.sol";
import "../../../storage/UStorage.sol";

/**
 * @title UCrossChainOwnable
 * @notice Library to manage the cross-chain ownership lifecycle of upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance.
 */
abstract contract UCrossChainOwnable is UInitializable, CrossChainEnabled {
    event OwnerUpdated(address indexed newOwner);
    event PendingOwnerUpdated(address indexed newPendingOwner);

    error UCrossChainOwnableNotCrossChain();
    error UCrossChainOwnableNotOwnerError(address sender);
    error UCrossChainOwnableNotPendingOwnerError(address sender);

    /// @dev The owner address
    AddressStorage private constant _owner = AddressStorage.wrap(keccak256("equilibria.root.UCrossChainOwnable.owner"));
    function owner() public view returns (address) { return _owner.read(); }

    /// @dev The pending owner address
    AddressStorage private constant _pendingOwner = AddressStorage.wrap(keccak256("equilibria.root.UCrossChainOwnable.pendingOwner"));
    function pendingOwner() public view returns (address) { return _pendingOwner.read(); }

    /**
     * @notice Initializes the contract setting `owner` as the initial owner
     * @param owner_ Crosschain owner address
     */
    function __UCrossChainOwnable__initialize(address owner_) internal onlyInitializer {
        if (!_isCrossChain()) revert UCrossChainOwnableNotCrossChain();
        _updateOwner(owner_);
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
     * @dev Can only be called by the pending owner to ensure correctness
     */
    function acceptOwner() external {
        address crossChainSender = _crossChainSender();
        if (crossChainSender != pendingOwner()) revert UCrossChainOwnableNotPendingOwnerError(crossChainSender);

        _updateOwner(pendingOwner());
        updatePendingOwner(address(0));
    }

    /**
     * @notice Updates the owner address
     * @param newOwner New owner address
     */
    function _updateOwner(address newOwner) private {
        _owner.store(newOwner);
        emit OwnerUpdated(newOwner);
    }

    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner() {
        address crossChainSender = _crossChainSender();
        if (owner() != crossChainSender) revert UCrossChainOwnableNotOwnerError(crossChainSender);
        _;
    }
}
