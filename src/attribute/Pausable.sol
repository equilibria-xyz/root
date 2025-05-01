// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Ownable } from "./Ownable.sol";
import { IPausable } from "./interfaces/IPausable.sol";

/// @title Pausable
/// @notice Library to allow for the emergency pausing and unpausing of contract functions
///         by an authorized account.
/// @dev This contract has been extended from the Open Zeppelin library to include an
///      unstructured storage pattern so that it can be safely mixed in with upgradeable
///      contracts without affecting their storage patterns through inheritance.
abstract contract Pausable is IPausable, Ownable {
    /// @custom:storage-location erc7201:equilibria.root.Pausable
    struct PausableStorage {
        address pauser;
        bool paused;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant PausableStorageLocation = 0x3f6e81f1674f7eaca7e8904fa6f14f10175d4d641e37fc18a3df849e00101900;

    /// @dev The erc7201 storage of the mix-in
    function Pausable$() private pure returns (PausableStorage storage $) {
        assembly {
            $.slot := PausableStorageLocation
        }
    }

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
        return Pausable$().pauser;
    }

    /// @dev Whether the contract is paused
    function paused() public view returns (bool) {
        return Pausable$().paused;
    }

    /// @notice Pauses the contract
    /// @dev Can only be called by the pauser
    function pause() external onlyPauser { _pause(); }

    /// @notice Unpauses the contract
    /// @dev Can only be called by the pauser
    function unpause() external onlyPauser { _unpause(); }

    /// @dev Hook for inheriting contracts to update the pauser
    function _updatePauser(address newPauser) internal {
        Pausable$().pauser = newPauser;
        emit PauserUpdated(newPauser);
    }

    /// @dev Hook for inheriting contracts to pause the contract
    function _pause() internal virtual {
        Pausable$().paused = true;
        emit Paused();
    }

    /// @dev Hook for inheriting contracts to unpause the contract
    function _unpause() internal virtual {
        Pausable$().paused = false;
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
