// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { ERC1967Proxy, ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { Ownable } from "src/attribute/Ownable.sol";

interface IProxy is IERC1967 {
    // TODO: move this to proxyAdmin
    /// @dev Emits name and version as event (since it cannot be returned)
    function identify() external;

    /// @dev Replaces the implementation, validating name and version
    function upgradeToAndCall(
        address newImplementation,
        bytes calldata data,
        string calldata name,
        uint256 version
    ) external payable;
}

/**
 * NOTE: The real interface of this proxy is that defined in `IProxy`. This contract does not
 * inherit from that interface for reasons explained in baseclass TransparentUpgradeableProxy.
 */
contract Proxy is ERC1967Proxy {
    bytes32 internal constant NAME_SLOT = keccak256("equilibria.root.proxy.name");
    bytes32 internal constant VERSION_SLOT = keccak256("equilibria.root.proxy.version");

    address private immutable _admin;

    // TODO: should this be in IProxy instead?
    event Identify(string name, uint256 version);

    error ProxyDeniedAdminAccess();

    /// @dev The name provided in the upgrade request does not match the name of this proxy
    error ProxyNameMismatch(string proxyName, string requestName);

    /// @dev The upgraded version is not greater than the current version
    error ProxyVersionMismatch(uint256 proxyCurrentVersion, uint256 requestVersion);

    constructor(address _logic, ProxyAdmin proxyAdmin, bytes memory _data, string memory name) payable
        ERC1967Proxy(_logic, _data)
    {
        _admin = address(proxyAdmin);
        ERC1967Utils.changeAdmin(address(proxyAdmin));

        StorageSlot.getStringSlot(NAME_SLOT).value = name;
    }

    function _proxyAdmin() internal view virtual returns (address) {
        return _admin;
    }

    function _fallback() internal virtual override {
        // anyone can identify the proxy
        if (msg.sig == IProxy.identify.selector) {
            emit Identify(
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

// TODO: move this to a separate file
contract ProxyAdmin is Ownable {
    /// @notice Sets initial owner to the sender
    function initialize() external initializer(1) {
        __Ownable__initialize();
    }

    function upgradeToAndCall(
        IProxy proxy,
        address implementation,
        bytes memory data,
        string calldata name,
        uint256 version
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data, name, version);
    }
}
