// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Initializable } from "src/attribute/Initializable.sol";

/*contract InitializableTest is Test {
    event NoOp();
    event NoOp(uint256 version);
    event Initialized(uint256 version);
    event NoOpChild();

    error InitializableAlreadyInitializedError(uint256 version);
    error InitializableNotInitializingError();

    MockInitializable public initializable;

    function test_initializeSuccessfully() public {
        initializable = new MockInitializable();
        vm.expectEmit(true, true, true, true);
        emit NoOp();
        vm.expectEmit(true, true, true, true);
        emit Initialized(1);
        initializable.initialize();
    }

    function test_initializeWithChildren() public {
        initializable = new MockInitializable();
        vm.expectEmit(true, true, true, true);
        emit NoOpChild();
        vm.expectEmit(true, true, true, true);
        emit NoOp();
        vm.expectEmit(true, true, true, true);
        emit Initialized(1);
        initializable.initializeWithChildren();
    }

    function test_constructorOnlyInitializer_1() public {
        new MockInitializableConstructor1();
    }

    function test_constructorWithInitializer_3() public {
        new MockInitializableConstructor3();
    }

    function test_constructorInheritedOnlyInitializer_5() public {
        new MockInitializableConstructor5();
    }

    function test_constructorInheritedAndSelfOnlyInitializer_6() public {
        new MockInitializableConstructor6();
    }

    function test_constructorInheritedInitializer_8() public {
        vm.expectEmit(true, true, true, true);
        emit Initialized(1);
        new MockInitializableConstructor8();
    }

    // TODO: delete now-irrelevant tests after ensuring Proxy tests handle the use cases
    function test_revertDoubleInitialize() public {
        initializable = new MockInitializable();
        initializable.initialize();
        vm.expectRevert(abi.encodeWithSelector(InitializableAlreadyInitializedError.selector, 1));
        initializable.initialize();
    }

    function test_revertDoubleInitializeFunction() public {
        initializable = new MockInitializable();
        vm.expectRevert(abi.encodeWithSelector(InitializableAlreadyInitializedError.selector, 1));
        initializable.doubleInitialize();
    }

    function test_customInitializer_validVersion() public {
        initializable = new MockInitializable();
        initializable.customInitializer("CustomInitializerTestSubject", 1);
    }

    function test_multiInitialize_newVersion() public {
        MockInitializableMulti multi = new MockInitializableMulti();
        multi.initialize1();
        vm.expectEmit(true, true, true, true);
        emit NoOp(2);
        vm.expectEmit(true, true, true, true);
        emit Initialized(2);
        multi.initialize2();
    }

    function test_multiInitialize_version17() public {
        MockInitializableMulti multi = new MockInitializableMulti();
        multi.initialize1();
        vm.expectEmit(true, true, true, true);
        emit NoOp(17);
        vm.expectEmit(true, true, true, true);
        emit Initialized(17);
        multi.initialize17();
    }

    function test_multiInitialize_maxVersion() public {
        MockInitializableMulti multi = new MockInitializableMulti();
        multi.initialize1();
        uint256 max = type(uint256).max;
        vm.expectEmit(true, true, true, true);
        emit NoOp(max);
        vm.expectEmit(true, true, true, true);
        emit Initialized(max);
        multi.initializeMax();
    }

    /*function test_revertSameVersion() public {
        MockInitializableMulti multi = new MockInitializableMulti();
        multi.initialize17();
        vm.expectRevert(abi.encodeWithSelector(InitializableAlreadyInitializedError.selector, 17));
        multi.initialize17();
    }

    function test_revertLesserVersion() public {
        MockInitializableMulti multi = new MockInitializableMulti();
        multi.initialize17();
        vm.expectRevert(abi.encodeWithSelector(InitializableAlreadyInitializedError.selector, 2));
        multi.initialize2();
    }

    // === onlyInitializing checks ===

    function test_revertOnlyInitializingTwice() public {
        initializable = new MockInitializable();
        initializable.initialize();
        vm.expectRevert(abi.encodeWithSelector(InitializableAlreadyInitializedError.selector, 1));
        initializable.initialize();
    }

    function test_revertOnlyInitializingWithChildren_twice() public {
        initializable = new MockInitializable();
        initializable.initializeWithChildren();
        vm.expectRevert(abi.encodeWithSelector(InitializableAlreadyInitializedError.selector, 1));
        initializable.initializeWithChildren();
    }

    function test_revertChildInitializerDirectCall() public {
        initializable = new MockInitializable();
        vm.expectRevert(abi.encodeWithSelector(InitializableNotInitializingError.selector));
        initializable.childInitializer();
    }

    function test_revertChildInitializerAfterInit() public {
        initializable = new MockInitializable();
        initializable.initialize();
        vm.expectRevert(abi.encodeWithSelector(InitializableNotInitializingError.selector));
        initializable.childInitializer();
    }
}

contract MockInitializable is Initializable {
    event NoOp();
    event NoOpChild();

    string internal _name;
    uint256 internal _version;

    function __version() external view returns (uint256) {
        return _version;
    }

    function initialize() public initializer("MockInitializable", 1) {
        _version = 1;
        emit NoOp();
    }

    function doubleInitialize() public initializer("MockInitializable", 1) {
        _version = 1;
        initialize();
    }

    function initializeWithChildren() public initializer("MockInitializable", 1) {
        _version = 1;
        childInitializer();
        emit NoOp();
    }

    function childInitializer() public onlyInitializer {
        emit NoOpChild();
    }

    function customInitializer(string memory name, uint256 version) public initializer(name, version) {
        _name = name;
        _version = version;
        emit NoOp();
    }
}

contract MockInitializableConstructor1 is MockInitializable {
    constructor() {
        childInitializer();
    }
}

contract MockInitializableConstructor3 is MockInitializable {
    constructor() initializer("MockInitializable", 1) {
        _version = 1;
        childInitializer();
    }
}

contract MockInitializableConstructor5 is MockInitializableConstructor1 {
    constructor() MockInitializableConstructor1() {}
}

contract MockInitializableConstructor6 is MockInitializableConstructor1 {
    constructor() MockInitializableConstructor1() {
        childInitializer6();
    }

    function childInitializer6() public onlyInitializer {}
}

contract MockInitializableConstructor8 is MockInitializableConstructor3 {
    constructor() MockInitializableConstructor3() {}
}

contract MockInitializableMulti is Initializable {
    uint256 private _version;

    event NoOp(uint256 version);

    function __version() external view returns (uint256) {
        return _version;
    }

    function initialize1() public initializer("MockInitializableMulti", 1) {
        _version = 1;
        emit NoOp(1);
    }

    function initialize2() public initializer("MockInitializableMulti", 2) {
        _version = 2;
        emit NoOp(2);
    }

    function initialize17() public initializer("MockInitializableMulti", 17) {
        _version = 17;
        emit NoOp(17);
    }

    function initializeMax() public initializer("MockInitializableMulti", type(uint256).max) {
        _version = type(uint256).max;
        emit NoOp(type(uint256).max);
    }
}
*/