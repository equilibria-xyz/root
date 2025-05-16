// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { Proxy } from "@openzeppelin/contracts/proxy/Proxy.sol";
import { ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMutable, IMutableTransparent } from "./interfaces/IMutable.sol";
import { IImplementation } from "./interfaces/IImplementation.sol";
import { Version, VersionLib } from "./types/Version.sol";

/// @title Mutable
/// @notice A mostly-transparent upgradeable proxy with facilities to prevent deployment errors.
/// @dev The real interface of this proxy is that defined in `IProxy`. This contract does not
///      inherit from that interface to maintain transparency.  Upgradability is implemented using
///      an internal dispatch mechanism.  Proxied contracts must implement `Initializable` (not just
///      the interface) and must return a constant `name` string used for identification.
///      Implementations must be initialized using calldata during deployment and upgrade.
///      Users are exposed to ProxyPausedError when the proxied contract is paused.
contract Mutable is IMutableTransparent, Proxy {
    address private immutable _mutator;
    address private immutable _pauseTarget;

    /// @custom:storage-location erc7201:equilibria.root.Proxy
    struct MutableStorage {
        Version version;
        address paused;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant MutableStorageLocation = 0xb906736fa3fc696e6c19a856e0f8737e348fda5c7f33a32db99da3b92f19a800;

    /// @dev The erc7201 storage of the mix-in
    function Mutable$() private pure returns (MutableStorage storage $) {
        assembly {
            $.slot := MutableStorageLocation
        }
    }

    /// @dev Initializes an upgradeable proxy managed by an instance of a {ProxyAdmin}.
    /// @param implementation The first version of the contract to be proxied.
    /// @param data Contract-specific parameters to be passed to the initializer.
    constructor(IImplementation implementation, bytes memory data) payable {
        _mutator = msg.sender;
        _pauseTarget = address(new MutablePauseTarget());

        _upgrade(implementation, data);

        emit AdminChanged(address(0), msg.sender);
    }

    /// @dev Only allows calls when the proxy is paused.
    modifier whenPaused {
        if (Mutable$().paused == address(0)) revert UnpausedError();
        _;
    }

    /// @dev Only allows calls when the proxy is unpaused.
    modifier whenUnpaused {
        if (Mutable$().paused != address(0)) revert PausedError();
        _;
    }

    /// @dev Single entry point for all calls to the mutable.
    function _fallback() internal virtual override {
        // process mutator calls
        if (msg.sender == _mutator) {
            if (msg.sig == IMutable.upgrade.selector) {
                _dispatchUpgrade();
            } else if (msg.sig == IMutable.pause.selector) {
                _pause();
            } else if (msg.sig == IMutable.unpause.selector) {
                _unpause();
            } else {
                revert MutableDeniedMutatorAccess();
            }

        // pass through all other calls
        } else {
            if (msg.sig == IImplementation.construct.selector) {
                revert MutableDeniedConstructorAccess();
            }
            super._fallback();
        }
    }

    /// @dev Dispatches the upgrade external call to the upgrade function.
    function _dispatchUpgrade() private whenUnpaused {
        (IImplementation newImplementation, bytes memory data) = abi.decode(msg.data[4:], (IImplementation, bytes));
        _upgrade(newImplementation, data);
    }

    /// @dev Upgrades the implementation of the proxy.
    function _upgrade(IImplementation newImplementation, bytes memory data) private {
        // validate the upgrade metadata of the new implementation
        if (
            (_implementation() == address(0) ? VersionLib.from(0, 0, 0) : IImplementation(_implementation()).version())
            != newImplementation.predecessor()
        ) revert MutablePredecessorMismatch();
        if (newImplementation.version() == Mutable$().version) revert MutableVersionMismatch();

        // update the implementation and call its constructor
        ERC1967Utils.upgradeToAndCall(address(newImplementation), abi.encodeCall(IImplementation.construct, (data)));

        // record the new implementation version
        Mutable$().version = newImplementation.version();
    }

    /// @dev Pauses the proxy by setting the implementation to the MutablePauseTarget.
    function _pause() private whenUnpaused {
        Mutable$().paused = _implementation();
        ERC1967Utils.upgradeToAndCall(_pauseTarget, "");
        emit Paused();
    }

    /// @dev Unpauses the proxy by setting the implementation back to the previous implementation.
    function _unpause() private whenPaused {
        ERC1967Utils.upgradeToAndCall(Mutable$().paused, "");
        Mutable$().paused = address(0);
        emit Unpaused();
    }

    /// @dev Returns the implementation of the proxy.
    function _implementation() internal view virtual override returns (address) {
        return ERC1967Utils.getImplementation();
    }
}

/// @title MutablePauseTarget
/// @dev Stub contract Mutable sets as the implementation whenever the proxied contract is paused.
///      This eliminates the need for a storage read to check paused state on each interaction.
contract MutablePauseTarget {
    fallback() external payable virtual {
        revert IMutableTransparent.PausedError();
    }
}