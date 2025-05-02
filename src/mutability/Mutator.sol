// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { IMutable } from "./interfaces/IMutable.sol";
import { IImplementation } from "./interfaces/IImplementation.sol";
import { Pausable } from "../../src/attribute/Pausable.sol";
import { Version } from "./types/Version.sol";
import { Derived } from "./Derived.sol";
import { Implementation } from "./Implementation.sol";
import { Mutable } from "./Mutable.sol";

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

    function create(
        string calldata name,
        Implementation implementation,
        bytes calldata data
    ) public onlyOwner returns (Mutable newMutable) {
        _mutables.add(address(newMutable = new Mutable(name, implementation, data)));
    }

    /// @notice Upgrades the implementation of a proxy and optionally calls its initializer
    /// @param proxy Target to upgrade
    /// @param implementation New version of contract to be proxied
    /// @param data Calldata to invoke the instance's initializer
    function upgradeToAndCall(
        IMutable proxy,
        IImplementation implementation,
        bytes memory data
    ) public payable virtual onlyOwner {
        proxy.upgradeToAndCall{value: msg.value}(implementation, data);
    }

    function _pause() internal override {
        for (uint256 i = 0; i < _mutables.length(); i++) IMutable(_mutables.at(i)).pause();
        super._pause();
    }

    function _unpause() internal override {
        for (uint256 i = 0; i < _mutables.length(); i++) IMutable(_mutables.at(i)).unpause();
        super._unpause();
    }
}
