// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { Ownable } from "./Ownable.sol";
import { IPausable } from "./interfaces/IPausable.sol";

/// @title Pausable
/// @notice Library to allow for the emergency pausing and unpausing of contract functions
///         by an authorized account.
/// @dev This contract has been extended from the Open Zeppelin library to include an
///      unstructured storage pattern so that it can be safely mixed in with upgradeable
///      contracts without affecting their storage patterns through inheritance.
abstract contract Pausable is IPausable, Ownable {
    /// @dev The slot of the pauser address
    bytes32 private constant PAUSER_SLOT = keccak256("equilibria.root.Pausable.pauser");

    /// @dev The slot of the paused flag
    bytes32 private constant PAUSED_SLOT = keccak256("equilibria.root.Pausable.paused");

    /// @notice Initializes the contract setting `msg.sender` as the initial pauser
    function __Pausable__constructor() initializer("Pausable") internal {
        _updatePauser(msg.sender);
    }

    /// @notice Updates the new pauser
    /// @dev Can only be called by the current owner
    /// @param newPauser New pauser address
    function updatePauser(address newPauser) public onlyOwner {
        _updatePauser(newPauser);
    }

    /// @dev The pauser address
    function pauser() public view returns (address) {
        return StorageSlot.getAddressSlot(PAUSER_SLOT).value;
    }

    /// @dev Whether the contract is paused
    function paused() public view returns (bool) {
        return StorageSlot.getBooleanSlot(PAUSED_SLOT).value;
    }

    /// @notice Pauses the contract
    /// @dev Can only be called by the pauser
    function pause() external onlyPauser { _pause(); }

    /// @notice Unpauses the contract
    /// @dev Can only be called by the pauser
    function unpause() external onlyPauser { _unpause(); }

    /// @dev Hook for inheriting contracts to update the pauser
    function _updatePauser(address newPauser) internal {
        StorageSlot.getAddressSlot(PAUSER_SLOT).value = newPauser;
        emit PauserUpdated(newPauser);
    }

    /// @dev Hook for inheriting contracts to pause the contract
    function _pause() internal virtual {
        StorageSlot.getBooleanSlot(PAUSED_SLOT).value = true;
        emit Paused();
    }

    /// @dev Hook for inheriting contracts to unpause the contract
    function _unpause() internal virtual {
        StorageSlot.getBooleanSlot(PAUSED_SLOT).value = false;
        emit Unpaused();
    }

    /// @dev Throws if called by any account other than the pauser
    modifier onlyPauser {
        if (msg.sender != pauser() && msg.sender != owner()) revert PausableNotPauserError(msg.sender);
        _;
    }

    /// @dev Throws if called when the contract is paused
    modifier whenNotPaused {
        if (paused()) revert PausablePausedError();
        _;
    }
}
