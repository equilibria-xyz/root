// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { ERC1967Proxy, ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { Initializable, IInitializable, Version, VersionLib } from "src/attribute/Initializable.sol";
import { IProxy } from "./interfaces/IProxy.sol";
import { ProxyAdmin } from "./ProxyAdmin.sol";
import { ProxyPauseTarget } from "./ProxyPauseTarget.sol";

/// @title Proxy
/// @notice A mostly-transparent upgradeable proxy with facilities to prevent deployment errors.
/// @dev The real interface of this proxy is that defined in `IProxy`. This contract does not
///      inherit from that interface to maintain transparency.  Upgradability is implemented using
///      an internal dispatch mechanism.  Proxied contracts must implement `Initializable` (not just
///      the interface) and must return a constant `name` string used for identification.
///      Implementations must be initialized using calldata during deployment and upgrade.
///      Users are exposed to ProxyPausedError when the proxied contract is paused.
contract Proxy is ERC1967Proxy {
    address private immutable _admin;

    // Stored in named slots to avoid storage collision with implementation
    // @dev Prevents any interaction with the proxied contract
    bytes32 private constant PAUSED_SLOT = keccak256("equilibria.root.proxy.paused");
    // @dev Stub contract used when proxy is paused
    bytes32 private constant PAUSED_TARGET_SLOT = keccak256("equilibria.root.proxy.target.paused");
    // @dev Implementation contract used when proxy is unpaused
    bytes32 private constant UNPAUSED_TARGET_SLOT = keccak256("equilibria.root.proxy.target.unpaused");
    // @dev Initialized version of the proxied contract
    bytes32 private constant INITIALIZED_VERSION_SLOT = keccak256("equilibria.root.initializable.initializedVersion");

    /// @notice Proxy will ignore calls to the proxied contract
    event Paused();
    /// @notice Proxy will allow calls to the proxied contract
    event Unpaused();

    // sig: 0xe8d6e8ee
    /// @dev An upgrade attempt was made by someone other than the proxy administrator.
    error ProxyDeniedAdminAccessError();

    // sig: 0x73df0fec
    /// @dev The name provided in the upgrade request does not match the name of this proxy.
    error ProxyNameMismatchError();

    // sig: 0x89d5628b
    /// @dev The proxied contract was not initialized upon deployment/upgrade.  Ensuure the
    ///      contract's `initialize` method was decorated with the `initializer` modifier.
    error ProxyNotInitializedError();

    // sig: 0x9419684e
    /// @dev Interactions with proxied contract are not allowed while paused.
    error ProxyPausedError();

    // sig: 0x3f7d07d5
    /// @dev The upgraded version is not greater than the current version.
    error ProxyVersionMismatchError(Version proxyCurrentVersion, Version requestVersion);

    /// @dev Initializes an upgradeable proxy managed by an instance of a {ProxyAdmin}.
    /// @param implementation The first version of the contract to be proxied.
    /// @param proxyAdmin Administrator who can upgrade the proxy.
    /// @param initParams Contract-specific parameters to be passed to the initializer.
    constructor(Initializable implementation, ProxyAdmin proxyAdmin, bytes memory initParams) payable
        ERC1967Proxy(address(implementation), bytes(abi.encodeCall(IInitializable.initialize, (initParams))))
    {
        _ensureInitialized();
        _admin = address(proxyAdmin);
        ERC1967Utils.changeAdmin(address(proxyAdmin));
        StorageSlot.getAddressSlot(PAUSED_TARGET_SLOT).value = address(new ProxyPauseTarget());
        StorageSlot.getAddressSlot(UNPAUSED_TARGET_SLOT).value = address(implementation);
    }

    /// @dev Returns the administrator of the proxy.
    function _proxyAdmin() internal virtual view returns (address) {
        return _admin;
    }

    /// @dev Handles any non-administrative calls to the proxy.
    function _fallback() internal virtual override {
        // only admin may interact with the proxy
        if (msg.sender == _proxyAdmin()) {
            if (msg.sig == IProxy.upgradeToAndCall.selector) {
                _dispatchUpgrade();
            } else if (msg.sig == IProxy.pause.selector && !paused()) {
                _setPausedImplementation();
                StorageSlot.getBooleanSlot(PAUSED_SLOT).value = true;
                emit Paused();
            } else if (msg.sig == IProxy.unpause.selector && paused()) {
                _setUnpausedImplementation();
                StorageSlot.getBooleanSlot(PAUSED_SLOT).value = false;
                emit Unpaused();
            } else {
                revert ProxyDeniedAdminAccessError();
            }
        // all other callers interact only with the implementation
        } else {
            super._fallback();
        }
    }

    /// @dev Convenience function which checks whether proxy is pointed at the pause target (true)
    ///      or implementation (false).
    function paused() internal virtual view returns (bool) {
        return StorageSlot.getBooleanSlot(PAUSED_SLOT).value;
    }

    /// @dev Updates the implementation of the proxy.
    function _dispatchUpgrade() private {
        // get arguments from the upgrade request
        (
            Initializable newImplementation,
            bytes memory initParams
        ) = abi.decode(msg.data[4:], (Initializable, bytes));

        // if proxy is paused upon upgrade, need to briefly soft-unpause to upgrade
        bool wasPaused = paused();
        if (wasPaused) _setUnpausedImplementation();

        // read the current name and version from storage before calling new initializer
        Initializable old = Initializable(_implementation());
        bytes32 oldNameHash = old.nameHash();
        Version memory oldVersion = old.version();

        // update the implementation and call initializer
        StorageSlot.getAddressSlot(UNPAUSED_TARGET_SLOT).value = address(newImplementation);
        ERC1967Utils.upgradeToAndCall(
            address(newImplementation),
            abi.encodeCall(IInitializable.initialize, (initParams))
        );
        _ensureInitialized();

        // ensure name hash and version are appropriate
        if (oldNameHash != newImplementation.nameHash())
            revert ProxyNameMismatchError();
        if (!oldVersion.eq(newImplementation.versionFrom()))
            revert ProxyVersionMismatchError(oldVersion, newImplementation.version());

        // if proxy was paused before upgrade, re-pause the proxy
        if (wasPaused) _setPausedImplementation();
    }

    function _ensureInitialized() private view {
        Initializable implementation = Initializable(_implementation());
        // TODO: expose the uint256 version in Initializable so we can just compare two uints
        Version memory initializedVersion = VersionLib.from(StorageSlot.getUint256Slot(INITIALIZED_VERSION_SLOT).value);
        if (!initializedVersion.eq(implementation.version())) {
            revert ProxyNotInitializedError();
        }
    }

    function _setPausedImplementation() private {
        ERC1967Utils.upgradeToAndCall(StorageSlot.getAddressSlot(PAUSED_TARGET_SLOT).value, "");
    }

    function _setUnpausedImplementation() private {
        ERC1967Utils.upgradeToAndCall(StorageSlot.getAddressSlot(UNPAUSED_TARGET_SLOT).value, "");
    }
}
