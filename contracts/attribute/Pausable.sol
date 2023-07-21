// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./Initializable.sol";
import "./Ownable.sol";
import "./interfaces/IPausable.sol";
import "../storage/Storage.sol";

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
    AddressStorage private constant _pauser = AddressStorage.wrap(keccak256("equilibria.root.UPausable.pauser"));
    function pauser() public view returns (address) { return _pauser.read(); }

    /// @dev Whether the contract is paused
    BoolStorage private constant _paused = BoolStorage.wrap(keccak256("equilibria.root.UPausable.paused"));
    function paused() public view returns (bool) { return _paused.read(); }

    /**
     * @notice Initializes the contract setting `msg.sender` as the initial pauser
     */
    function __UPausable__initialize() internal onlyInitializer {
        __UOwnable__initialize();
        updatePauser(_sender());
    }

    /**
     * @notice Updates the new pauser
     * @dev Can only be called by the current owner
     * @param newPauser New pauser address
     */
    function updatePauser(address newPauser) public onlyOwner {
        _pauser.store(newPauser);
        emit PauserUpdated(newPauser);
    }

    /**
     * @notice Pauses the contract
     * @dev Can only be called by the pauser
     */
    function pause() external onlyPauser {
        _paused.store(true);
        emit Paused();
    }

    /**
     * @notice Unpauses the contract
     * @dev Can only be called by the pauser
     */
    function unpause() external onlyPauser {
        _paused.store(false);
        emit Unpaused();
    }

    /// @dev Throws if called by any account other than the pauser
    modifier onlyPauser {
        if (_sender() != pauser() && _sender() != owner()) revert UPausableNotPauserError(_sender());
        _;
    }

    /// @dev Throws if called when the contract is paused
    modifier whenNotPaused {
        if (paused()) revert UPausablePausedError();
        _;
    }
}
