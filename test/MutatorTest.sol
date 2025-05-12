// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { RootTest } from "./RootTest.sol";
import { Mutator } from "../src/mutability/Mutator.sol";
import { IImplementation, IMutableTransparent, IMutator, IOwnable, IPausable } from "../src/mutability/interfaces/IMutator.sol";

contract MutatorTest is RootTest, Mutator {
    /// @dev Used to monkey-patch the owner of the Mutable to be the test contract itself
    function _HackOwnable$() private pure returns (OwnableStorage storage $) {
        assembly {
            $.slot := 0x863176706c9b4c9b393005d0714f55de5425abea2a0b5dfac67fac0c9e2ffe00
        }
    }

    constructor() Mutator() {
        // Owner of the Mutator is set to itself (the test contract)
        _HackOwnable$().owner = address(this);
    }
}
