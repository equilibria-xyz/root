// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Initializable } from "src/attribute/Initializable.sol";
import { Ownable } from "src/attribute/Ownable.sol";
import { IPausable } from "src/attribute/interfaces/IPausable.sol";

/**
 * @title Pausable
 * @notice Library to allow for the emergency pausing and unpausing of contract functions
 *         by an authorized account.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance.
 */
abstract contract Pausable is IPausable, Ownable {
    /// @dev The pauser address
    address private _pauser;
    function pauser() public view returns (address) { return _pauser; }

    /// @dev Whether the contract is paused
    bool private _paused;
    function paused() public view returns (bool) { return _paused; }

    /**
     * @notice Initializes the contract setting `msg.sender` as the initial pauser
     */
    function __Pausable__initialize() internal onlyInitializer {
        __Ownable__initialize();
        updatePauser(_sender());
    }

    /**
     * @notice Updates the new pauser
     * @dev Can only be called by the current owner
     * @param newPauser New pauser address
     */
    function updatePauser(address newPauser) public onlyOwner {
        _pauser = newPauser;
        emit PauserUpdated(newPauser);
    }

    /**
     * @notice Pauses the contract
     * @dev Can only be called by the pauser
     */
    function pause() external onlyPauser {
        _paused = true;
        emit Paused();
    }

    /**
     * @notice Unpauses the contract
     * @dev Can only be called by the pauser
     */
    function unpause() external onlyPauser {
        _paused = false;
        emit Unpaused();
    }

    /// @dev Throws if called by any account other than the pauser
    modifier onlyPauser {
        if (_sender() != pauser() && _sender() != owner()) revert PausableNotPauserError(_sender());
        _;
    }

    /// @dev Throws if called when the contract is paused
    modifier whenNotPaused {
        if (paused()) revert PausablePausedError();
        _;
    }
}
