// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ShortStrings, ShortString } from "@openzeppelin/contracts/utils/ShortStrings.sol";
import { IMutable, IMutableTransparent } from "./interfaces/IMutable.sol";
import { IImplementation } from "./interfaces/IImplementation.sol";
import { IMutator } from "./interfaces/IMutator.sol";
import { Pausable } from "../../src/attribute/Pausable.sol";
import { Derived } from "./Derived.sol";
import { Mutable } from "./Mutable.sol";

contract Mutator is IMutator, Derived, Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _mutables;
    mapping(ShortString => IMutable) private _nameToMutable;

    constructor() {
        __Pausable__constructor();
        __Ownable__constructor();
    }

    /// @dev The list of all mutables.
    function mutables() public view returns (address[] memory) {
        return _mutables.values();
    }

    /// @notice Creates a new mutable with the given name
    /// @dev Initializes the mutable with the given implementation and data
    /// @param implementation The implementation of the mutable
    /// @param data The calldata to invoke the instance's initializer
    /// @return newMutable The new mutable
    function create(
        IImplementation implementation,
        bytes calldata data
    ) public onlyOwner returns (IMutableTransparent newMutable) {
        _mutables.add(address(newMutable = new Mutable(implementation, data)));
        _nameToMutable[ShortStrings.toShortString(implementation.name())] = IMutable(address(newMutable));
    }

    /// @notice Upgrades the implementation of a proxy and optionally calls its initializer
    /// @param implementation New version of contract to be proxied
    /// @param data Calldata to invoke the instance's initializer
    function upgrade(IImplementation implementation, bytes memory data) public payable onlyOwner {
        ShortString name = ShortStrings.toShortString(implementation.name());
        if (_nameToMutable[name] == IMutable(address(0))) revert MutatorInvalidMutable();
        _nameToMutable[name].upgrade{value: msg.value}(implementation, data);
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
