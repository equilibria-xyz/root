// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/Initializable.sol";

contract MockInitializable is Initializable {
    Uint256Storage private constant _version = Uint256Storage.wrap(keccak256("equilibria.root.Initializable.version"));

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

contract MockInitializableConstructor1 is MockInitializable {
    constructor() {
        childInitializer();
    }
}

contract MockInitializableConstructor3 is MockInitializable {
    constructor() initializer(1) {
        childInitializer();
    }
}

contract MockInitializableConstructor5 is MockInitializableConstructor1 {
    constructor() MockInitializableConstructor1() { }
}

contract MockInitializableConstructor6 is MockInitializableConstructor1 {
    constructor() MockInitializableConstructor1() {
        childInitializer6();
    }

    function childInitializer6() public onlyInitializer { }
}

contract MockInitializableConstructor8 is MockInitializableConstructor3 {
    constructor() MockInitializableConstructor3() { }
}

contract MockInitializableMulti is Initializable {
    Uint256Storage private constant _version = Uint256Storage.wrap(keccak256("equilibria.root.Initializable.version"));

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