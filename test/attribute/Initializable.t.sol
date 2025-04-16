// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Initializable } from "src/attribute/Initializable.sol";
import { Version } from "src/attribute/types/Version.sol";

contract InitializableTest is Test {
    event CustomInitializer(uint256 value);
    event NoOp();
    event NoOp(uint256 version);
    event Initialized();
    event NoOpChild();

    error AlreadyInitializedError();
    error InitializableAlreadyInitializedError();
    error InitializableNotInitializingError();

    MockInitializable public initializable;

    function test_constructor() public {
        initializable = new MockInitializable();
        assertEq(initializable.nameHash(), keccak256("MockInitializable"));
        assertEq(initializable.version().major, 2);
        assertEq(initializable.version().minor, 6);
        assertEq(initializable.version().patch, 4);
        assertEq(initializable.versionFrom().major, 1);
        assertEq(initializable.versionFrom().minor, 5);
        assertEq(initializable.versionFrom().patch, 3);
    }

    function test_initializeSuccessfully() public {
        initializable = new MockInitializable();
        vm.expectEmit();
        emit NoOp();
        emit Initialized();
        initializable.initialize();
    }

    function test_initializeWithChildren() public {
        initializable = new MockInitializable();
        vm.expectEmit(true, true, true, true);
        emit NoOpChild();
        vm.expectEmit(true, true, true, true);
        emit NoOp();
        vm.expectEmit(true, true, true, true);
        emit Initialized();
        initializable.initializeWithChildren();
    }

    function test_constructorOnlyInitializer_1() public {
        new MockInitializableConstructor1();
    }

    function test_subclassKnowsWhenInitializing() public {
        initializable = new MockInitializable();
        initializable.conditionalInitializer();
        assertEq(initializable.unsignedValue(), 2);
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
        emit Initialized();
        new MockInitializableConstructor8();
    }

    function test_revertDoubleInitialize() public {
        initializable = new MockInitializable();
        initializable.initialize();
        vm.expectRevert(InitializableAlreadyInitializedError.selector);
        initializable.initialize();
    }

    function test_revertDoubleInitializeFunction() public {
        initializable = new MockInitializable();
        initializable.initialize();
        vm.expectRevert(InitializableAlreadyInitializedError.selector);
        initializable.initialize();
    }

    function test_customInitializer() public {
        initializable = new MockInitializable();
        initializable.customInitializer("CustomInitializerTestSubject", 1);
        assertEq(initializable.stringValue(), "CustomInitializerTestSubject");
        assertEq(initializable.unsignedValue(), 1);
    }

    // === onlyInitializing checks ===

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

    string internal _stringValue;
    uint256 internal _unsignedValue;

    constructor() Initializable("MockInitializable", Version(2, 6, 4), Version(1, 5, 3)) {}

    function unsignedValue() external view returns (uint256) {
        return _unsignedValue;
    }

    function stringValue() external view returns (string memory) {
        return _stringValue;
    }

    function initialize() public virtual initializer() {
        _unsignedValue = 1;
        emit NoOp();
    }

    function initializeWithChildren() public initializer() {
        _unsignedValue = 1;
        childInitializer();
        emit NoOp();
    }

    function childInitializer() public onlyInitializer {
        emit NoOpChild();
    }

    function conditionalInitializer() public initializer() {
        _unsignedValue = initializing() ? 2 : 4;
    }

    function customInitializer(string memory stringValue_, uint256 unsignedValue_) public initializer() {
        _stringValue = stringValue_;
        _unsignedValue = unsignedValue_;
        emit NoOp();
    }
}

contract MockInitializableConstructor1 is MockInitializable {
    constructor() {
        childInitializer();
    }
}

contract MockInitializableConstructor3 is MockInitializable {
    constructor() initializer() {
        _unsignedValue = 1;
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
