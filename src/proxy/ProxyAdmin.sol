// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { Initializable } from "src/attribute/Initializable.sol";
import { IProxy } from "./interfaces/IProxy.sol";
import { Ownable } from "src/attribute/Ownable.sol";
import { Version } from "src/attribute/types/Version.sol";

contract ProxyAdmin is Ownable {
    constructor() Ownable("ProxyAdmin", Version(0,0,0), Version(0,0,0)) {}

    /// @notice Sets initial owner to the sender
    function initialize() external initializer() {
        __Ownable__initialize();
    }

    /// @notice Upgrades the implementation of a proxy and optionally calls its initializer
    /// @param proxy Target to upgrade
    /// @param implementation New version of contract to be proxied
    /// @param data Calldata to invoke the instance's initializer
    function upgradeToAndCall(
        IProxy proxy,
        Initializable implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }

    /// @notice Prevents interaction with the proxied contract
    function pause(IProxy proxy) public onlyOwner {
        proxy.pause();
    }

    /// @notice Allows interaction with the proxied contract
    function unpause(IProxy proxy) public onlyOwner {
        proxy.unpause();
    }

    /// @notice Points proxy to previous implementation, if available
    /// @custom:error ProxyCannotRollBackError No rollback implementation available
    function rollback(IProxy proxy) public onlyOwner {
        proxy.rollback();
    }
}
