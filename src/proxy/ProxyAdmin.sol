// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { IProxy } from "./interfaces/IProxy.sol";
import { IProxyIdentificationCallbackReceiver } from "./interfaces/IProxyIdentificationCallbackReceiver.sol";
import { Ownable } from "src/attribute/Ownable.sol";

contract ProxyAdmin is Ownable, IProxyIdentificationCallbackReceiver {
    struct ProxyIdentification {
        IProxy proxy;
        string name;
        uint256 version;
    }

    ProxyIdentification private _lastIdentifiedProxy;

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

    function identify(IProxy proxy) external returns (
        string memory name,
        uint256 version
    ) {
        _lastIdentifiedProxy = ProxyIdentification(proxy, "", 0);
        proxy.identify();
        name = _lastIdentifiedProxy.name;
        version = _lastIdentifiedProxy.version;
    }

    function onIdentify(string memory name, uint256 version) external override {
        if (msg.sender != address(_lastIdentifiedProxy.proxy)) {
            revert IProxyIdentificationCallbackReceiver.ProxyNotIdentifier();
        }
        _lastIdentifiedProxy.name = name;
        _lastIdentifiedProxy.version = version;
    }
}
