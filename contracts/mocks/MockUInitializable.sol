// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../control/unstructured/UInitializable.sol";

contract MockUInitializable is UInitializable {
    Uint256Storage private constant _version = Uint256Storage.wrap(keccak256("equilibria.root.UInitializable.version"));

    event NoOp();
    event NoOpChild();

    function __version() external view returns (uint256) {
        return _version.read();
    }

    function initialize() public initializer(1) {
        emit NoOp();
    }

    function doubleInitialize() public initializer(1) {
        initialize();
    }

    function initializeWithChildren() public initializer(1) {
        childInitializer();
        emit NoOp();
    }

    function childInitializer() public onlyInitializer {
        emit NoOpChild();
    }

    function customInitializer(uint256 version) public initializer(version) {
        emit NoOp();
    }
}

contract MockUInitializableConstructor1 is MockUInitializable {
    constructor() {
        childInitializer();
    }
}

contract MockUInitializableConstructor3 is MockUInitializable {
    constructor() initializer(1) {
        childInitializer();
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

contract MockUInitializableConstructor8 is MockUInitializableConstructor3 {
    constructor() MockUInitializableConstructor3() { }
}

contract MockUInitializableMulti is UInitializable {
    Uint256Storage private constant _version = Uint256Storage.wrap(keccak256("equilibria.root.UInitializable.version"));

    event NoOp(uint256 version);

    function __version() external view returns (uint256) {
        return _version.read();
    }

    function initialize1() public initializer(1) {
        emit NoOp(1);
    }

    function initialize2() public initializer(2) {
        emit NoOp(2);
    }

    function initialize17() public initializer(17) {
        emit NoOp(17);
    }

    function initializeMax() public initializer(type(uint256).max) {
        emit NoOp(type(uint256).max);
    }
}