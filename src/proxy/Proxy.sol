// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { ERC1967Proxy, ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { Initializable, Version } from "src/attribute/Initializable.sol";
import { IProxy } from "./interfaces/IProxy.sol";
import { ProxyAdmin } from "./ProxyAdmin.sol";

/// @title Proxy
/// @notice A transparent upgradeable proxy with facilities to prevent deployment errors.
/// @dev The real interface of this proxy is that defined in `IProxy`. This contract does not
/// inherit from that interface to maintain transparency.  Upgradability is implemented using an
/// internal dispatch mechanism.  Proxied contracts must implement `Initializable` (not just the
/// interface) and must return a constant `name` string used for identification.
/// Implementations must be initialized using calldata during deployment and upgrade.
contract Proxy is ERC1967Proxy {
    address private immutable _admin;

    /// @dev An upgrade attempt was made by someone other than the proxy administrator.
    error ProxyDeniedAdminAccess();

    /// @dev The name provided in the upgrade request does not match the name of this proxy.
    error ProxyNameMismatch();

    /// @dev The upgraded version is not greater than the current version.
    error ProxyVersionMismatch(uint256 proxyCurrentVersion, uint256 requestVersion);

    /// @dev Initializes an upgradeable proxy managed by an instance of a {ProxyAdmin}.
    /// @param implementation The first version of the contract to be proxied.
    /// @param proxyAdmin Administrator who can upgrade the proxy.
    /// @param initData Calldata to invoke the instance's initializer.
    constructor(Initializable implementation, ProxyAdmin proxyAdmin, bytes memory initData) payable
        ERC1967Proxy(address(implementation), initData)
    {
        _admin = address(proxyAdmin);
        ERC1967Utils.changeAdmin(address(proxyAdmin));
    }

    /// @dev Returns the administrator of the proxy.
    function _proxyAdmin() internal view virtual returns (address) {
        return _admin;
    }

    /// @dev Handles any non-administrative calls to the proxy.
    function _fallback() internal virtual override {
        // only admin may interact with the proxy
        if (msg.sender == _proxyAdmin()) {
            if (msg.sig != IProxy.upgradeToAndCall.selector) {
                revert ProxyDeniedAdminAccess();
            } else {
                _dispatchUpgrade();
            }
        // all other callers interact only with the implementation
        } else {
            super._fallback();
        }
    }

    /// @dev Updates the implementation of the proxy.
    function _dispatchUpgrade() private {
        // get arguments from the upgrade request
        (
            Initializable newImplementation,
            bytes memory initData
        ) = abi.decode(msg.data[4:], (Initializable, bytes));

        // read the current name and version from storage before calling new initializer
        Initializable old = Initializable(_implementation());
        bytes32 oldNameHash = old.nameHash();
        Version memory oldVersion = old.version();

        // update the implementation and call initializer
        ERC1967Utils.upgradeToAndCall(address(newImplementation), initData);

        // ensure name hash and version are appropriate
        if (oldNameHash != newImplementation.nameHash())
            revert ProxyNameMismatch();
        // TODO: lib, operator overload, and tests
        // if (oldVersion != newImplementation.version())
        //     revert ProxyVersionMismatch(oldVersion, newImplementation.version());
    }
}
