// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../unstructured/UInitializable.sol";

abstract contract MockUInitializableBase {
    bytes32 private constant INITIALIZED_SLOT = keccak256("equilibria.utils.UInitializable.initialized");

    event NoOp();
    event NoOpChild();

    function __initialized() external view returns (bool result) {
        bytes32 slot = INITIALIZED_SLOT;
        assembly {
            result := sload(slot)
        }
    }
}

contract MockUInitializable is UInitializable, MockUInitializableBase {
    function initialize() public initializer {
        emit NoOp();
    }

    function doubleInitialize() public initializer {
        initialize();
    }

    function initializeWithChildren() public initializer {
        childInitializer();
        emit NoOp();
    }

    function childInitializer() public onlyInitializer {
        emit NoOpChild();
    }
}

contract MockUInitializableConstructor1 is MockUInitializable {
    constructor() {
        childInitializer();
    }
}

contract MockUInitializableConstructor2 is MockUInitializable {
    constructor() {
        initialize();
    }
}

contract MockUInitializableConstructor3 is MockUInitializable {
    constructor() initializer {
        childInitializer();
    }
}

contract MockUInitializableConstructor4 is MockUInitializable {
    constructor() {
        initializeWithChildren();
    }
}

contract MockUInitializableConstructor5 is MockUInitializableConstructor1 {
    constructor() MockUInitializableConstructor1() { }
}

contract MockUInitializableConstructor6 is MockUInitializableConstructor1 {
    constructor() MockUInitializableConstructor1() {
        childInitializer6();
    }

    function childInitializer6() public onlyInitializer { }
}