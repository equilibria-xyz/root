// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { ERC1967Proxy, ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IProxy } from "./interfaces/IProxy.sol";
import { IProxyIdentificationCallbackReceiver } from "./interfaces/IProxyIdentificationCallbackReceiver.sol";
import { ProxyAdmin } from "./ProxyAdmin.sol";

/// @dev The real interface of this proxy is that defined in `IProxy`. This contract does not
/// inherit from that interface to maintain transparency.  Upgradability is implemented using an
/// internal dispatch mechanism.
contract Proxy is ERC1967Proxy {
    // TODO: Should we hardcode to reduce deployment cost?  This seems more readable.
    bytes32 internal constant NAME_SLOT = keccak256("equilibria.root.proxy.name");
    bytes32 internal constant VERSION_SLOT = keccak256("equilibria.root.proxy.version");

    address private immutable _admin;

    /// @dev An upgrade attempt was made by someone other than the proxy administrator.
    error ProxyDeniedAdminAccess();

    /// @dev The name provided in the upgrade request does not match the name of this proxy.
    error ProxyNameMismatch(string proxyName, string requestName);

    /// @dev The upgraded version is not greater than the current version.
    error ProxyVersionMismatch(uint256 proxyCurrentVersion, uint256 requestVersion);

    /// @dev Initializes an upgradeable proxy managed by an instance of a {ProxyAdmin}.
    /// @param _logic The address of the implementation to be used by the proxy.
    /// @param proxyAdmin Administrator who can upgrade the proxy.
    /// @param _data Optional data to send as msg.data to the implementation.
    constructor(address _logic, ProxyAdmin proxyAdmin, bytes memory _data, string memory name) payable
        ERC1967Proxy(_logic, _data)
    {
        _admin = address(proxyAdmin);
        ERC1967Utils.changeAdmin(address(proxyAdmin));

        StorageSlot.getStringSlot(NAME_SLOT).value = name;
        StorageSlot.getUint256Slot(VERSION_SLOT).value = 1;
    }

    /// @dev Returns the administrator of the proxy.
    function _proxyAdmin() internal view virtual returns (address) {
        return _admin;
    }

    /// @dev Handles any non-administrative calls to the proxy.
    function _fallback() internal virtual override {
        // anyone implementing the interface can identify the proxy
        if (msg.sig == IProxy.identify.selector) {
            IProxyIdentificationCallbackReceiver(msg.sender).onIdentify(
                StorageSlot.getStringSlot(NAME_SLOT).value,
                StorageSlot.getUint256Slot(VERSION_SLOT).value
            );
        // only the proxy admin may upgrade
        } else if (msg.sig == IProxy.upgradeToAndCall.selector) {
            if (msg.sender == _proxyAdmin())
                _dispatchUpgrade();
            else
                revert ProxyDeniedAdminAccess();
        // all other calls passed to the implementation
        } else {
            super._fallback();
        }
    }

    /// @dev Updates the implementation of the proxy.
    function _dispatchUpgrade() private {
        // get arguments from the upgrade request
        (
            address newImplementation,
            bytes memory data,
            string memory name,
            uint256 version
        ) = abi.decode(msg.data[4:], (address, bytes, string, uint256));

        // ensure name and version are appropriate
        string memory proxyName = StorageSlot.getStringSlot(NAME_SLOT).value;
        if (keccak256(bytes(name)) != keccak256(bytes(proxyName)))
            revert ProxyNameMismatch(proxyName, name);
        uint256 currentVersion = StorageSlot.getUint256Slot(VERSION_SLOT).value;
        if (version <= currentVersion)
            revert ProxyVersionMismatch(currentVersion, version);

        ERC1967Utils.upgradeToAndCall(newImplementation, data);

        // update the version
        StorageSlot.getUint256Slot(VERSION_SLOT).value = version;
    }
}
