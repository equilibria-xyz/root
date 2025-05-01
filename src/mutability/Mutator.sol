// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { IProxy } from "./interfaces/IProxy.sol";
import { Pausable } from "../../src/attribute/Pausable.sol";
import { Version } from "./types/Version.sol";
import { Derived } from "./Derived.sol";
import { Mutable } from "./Mutable.sol";
import { Proxy } from "./Proxy.sol";

contract Mutator is Derived, Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _mutables;

    constructor() {
        __Pausable__constructor();
        __Ownable__constructor();
    }

    function mutables() public view returns (address[] memory) {
        return _mutables.values();
    }

    function register(string calldata name, Mutable implementation, bytes calldata data) public onlyOwner {
        IProxy proxy = new Proxy(name, implementation, address(this), data);
        _mutables.add(address(proxy));
    }

    /// @notice Upgrades the implementation of a proxy and optionally calls its initializer
    /// @param proxy Target to upgrade
    /// @param implementation New version of contract to be proxied
    /// @param data Calldata to invoke the instance's initializer
    function upgradeToAndCall(
        IProxy proxy,
        Mutable implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }

    function pause() public {
        for (uint256 i = 0; i < _mutables.length(); i++) IProxy(_mutables.at(i)).pause();
        super.pause();
    }

    function unpause() public {
        for (uint256 i = 0; i < _mutables.length(); i++) IProxy(_mutables.at(i)).unpause();
        super.unpause();
    }
}
