// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../control/unstructured/UInitializable.sol";

contract MockUInitializable is UInitializable {
    BoolStorage private constant _initialized = BoolStorage.wrap(keccak256("equilibria.root.UInitializable.initialized"));

    event NoOp();
    event NoOpChild();

    function __initialized() external view returns (bool) {
        return _initialized.read();
    }

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

contract MockUInitializableConstructor7 is MockUInitializableConstructor2 {
    constructor() MockUInitializableConstructor2() { }
}

contract MockUInitializableConstructor8 is MockUInitializableConstructor3 {
    constructor() MockUInitializableConstructor3() { }
}

contract MockUInitializableConstructor9 is MockUInitializableConstructor4 {
    constructor() MockUInitializableConstructor4() { }
}