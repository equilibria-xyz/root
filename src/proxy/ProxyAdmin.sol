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

    function upgradeToAndCall(
        IProxy proxy,
        Initializable implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }
}
