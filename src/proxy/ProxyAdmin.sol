// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { Ownable } from "src/attribute/Ownable.sol";
import { IProxy } from "./Proxy.sol";

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
