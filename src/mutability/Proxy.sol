// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { ERC1967Proxy, ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IProxy } from "./interfaces/IProxy.sol";
import { IMutable } from "./interfaces/IMutable.sol";
import { Mutator } from "./Mutator.sol";
import { Version } from "./types/Version.sol";

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
    address private immutable _pausedTarget;
    bytes32 private immutable _nameHash;

    /// @custom:storage-location erc7201:equilibria.root.Proxy
    struct ProxyStorage {
        bool paused;
        address unpausedTarget;
        Version initializedVersion;
    }

    /// @dev The erc7201 storage location of the mix-in
    bytes32 private constant ProxyStorageLocation = 0x712d4fa129c9b501988baa67a9dfe85549492ba43086e0989a19c6f27b2e0e00;

    /// @dev The erc7201 storage of the mix-in
    function Proxy$() private pure returns (ProxyStorage storage $) {
        assembly {
            $.slot := ProxyStorageLocation
        }
    }

    /// @notice Proxy will ignore calls to the proxied contract
    event Paused();
    /// @notice Proxy will allow calls to the proxied contract
    event Unpaused();

    // sig: TODO
    /// @dev An upgrade attempt was made by someone other than the proxy administrator.
    error ProxyDeniedAdminAccess();

    // sig: 0x73df0fec
    /// @dev The name provided in the upgrade request does not match the name of this proxy.
    error ProxyNameMismatchError();

    // sig: 0x9419684e
    /// @dev Interactions with proxied contract are not allowed while paused.
    error ProxyPausedError();

    // sig: 0x3f7d07d5
    /// @dev The version we're upgrading from does not match that expected by the new implementation.
    error ProxyVersionMismatchError(Version proxyCurrentVersion, Version requestVersion);

    /// @dev Initializes an upgradeable proxy managed by an instance of a {ProxyAdmin}.
    /// @param name The name of the contract.
    /// @param implementation The first version of the contract to be proxied.
    /// @param proxyAdmin Administrator who can upgrade the proxy.
    /// @param data Contract-specific parameters to be passed to the initializer.
    constructor(
        string memory name,
        IMutable implementation,
        Mutator proxyAdmin,
        bytes memory data
    )
        payable
        ERC1967Proxy(address(implementation), bytes(abi.encodeCall(IMutable.construct, (data))))
    {
        _admin = address(proxyAdmin);
        _pausedTarget = address(new ProxyPauseTarget());
        _nameHash = keccak256(bytes(name));
    }

    /// @dev Handles any non-administrative calls to the proxy.
    function _fallback() internal virtual override {
        // only admin may interact with the proxy
        if (msg.sender == _admin) {
            if (msg.sig == IProxy.upgradeToAndCall.selector) {
                _dispatchUpgrade();
            } else if (msg.sig == IProxy.pause.selector) {
                _pause();
            } else if (msg.sig == IProxy.unpause.selector) {
                _unpause();
            } else {
                revert ProxyDeniedAdminAccess();
            }
        // all other callers interact only with the implementation
        } else {
            super._fallback();
        }
    }

    /// @dev Updates the implementation of the proxy.
    function _dispatchUpgrade() private {
        // get arguments from the upgrade request
        (IMutable newImplementation, bytes memory data) = abi.decode(msg.data[4:], (IMutable, bytes));

        // do not allow upgrades while the proxy is paused
        if (Proxy$().unpausedTarget != address(0)) revert ProxyPausedError();

        // read the current name and version from storage before calling new initializer
        Version previousVersion = IMutable(_implementation()).version();

        // update the implementation and call initializer
        ERC1967Utils.upgradeToAndCall(address(newImplementation),abi.encodeCall(IMutable.construct, (data)));

        // ensure name hash and version are appropriate
        if (_nameHash != newImplementation.nameHash())
            revert ProxyNameMismatchError();
        if (previousVersion != newImplementation.target())
            revert ProxyVersionMismatchError(previousVersion, newImplementation.target());
    }

    function _pause() private {
        ERC1967Utils.upgradeToAndCall(_pausedTarget, "");
        Proxy$().unpausedTarget = _implementation();
        emit Paused();
    }

    function _unpause() private {
        ERC1967Utils.upgradeToAndCall(Proxy$().unpausedTarget, "");
        Proxy$().unpausedTarget = address(0);
        emit Unpaused();
    }
}

/// @title ProxyPauseTarget
/// @dev Stub contract Proxy sets as the implementation whenever the proxied contract is paused.
///      This eliminates the need for a storage read to check paused state on each interaction.
contract ProxyPauseTarget {
    fallback() external payable virtual {
        revert Proxy.ProxyPausedError();
    }
}