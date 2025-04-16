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
        initializable = new MockInitializableSingle();
        initializable.initialize();
        vm.expectRevert(AlreadyInitializedError.selector);
        initializable.initialize();
    }

    function test_revertDoubleInitializeFunction() public {
        initializable = new MockInitializableSingle();
        initializable.initialize();
        vm.expectRevert(AlreadyInitializedError.selector);
        initializable.initialize();
    }

    function test_customInitializer() public {
        initializable = new MockInitializable();
        initializable.customInitializer("CustomInitializerTestSubject", 1);
        assertEq(initializable.stringValue(), "CustomInitializerTestSubject");
        assertEq(initializable.unsignedValue(), 1);
    }

    function test_multiInitialize_newVersion() public {
        MockInitializableMulti multi = new MockInitializableMulti();

        vm.expectEmit();
        emit CustomInitializer(1);
        emit Initialized();
        emit NoOp(1);
        multi.initialize1();

        vm.expectEmit();
        emit CustomInitializer(2);
        emit Initialized();
        emit NoOp(2);
        multi.initialize2();
    }

    function test_multiInitialize_version17() public {
        MockInitializableMulti multi = new MockInitializableMulti();
        multi.initialize1();

        vm.expectEmit();
        emit CustomInitializer(17);
        emit Initialized();
        emit NoOp(17);
        multi.initialize17();
    }

    function test_multiInitialize_maxVersion() public {
        MockInitializableMulti multi = new MockInitializableMulti();
        multi.initialize1();
        uint256 max = type(uint256).max;
        vm.expectEmit(true, true, true, true);
        emit NoOp(max);
        vm.expectEmit(true, true, true, true);
        emit Initialized();
        emit NoOp(max);
        multi.initializeMax();
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

contract MockInitializableMulti is Initializable {
    uint256 private _unsignedValue;

    event CustomInitializer(uint256 value);
    event NoOp(uint256 value);

    constructor() Initializable("MockInitializableMulti", Version(0, 0, 1), Version(0, 0, 0)) {}

    function initialize(uint256 value) initializer() public {
        _unsignedValue = value;
        emit CustomInitializer(value);
    }

    function __unsignedValue() external view returns (uint256) {
        return _unsignedValue;
    }

    function initialize1() public {
        initialize(1);
        emit NoOp(1);
    }

    function initialize2() public {
        initialize(2);
        emit NoOp(2);
    }

    function initialize17() public {
        initialize(17);
        emit NoOp(17);
    }

    function initializeMax() public {
        initialize(type(uint256).max);
        emit NoOp(type(uint256).max);
    }
}

contract MockInitializableSingle is MockInitializable {
    bool private _alreadyInitialized;

    error AlreadyInitializedError();

    function initialize() public override initializer() {
        if (_alreadyInitialized) revert AlreadyInitializedError();
        _alreadyInitialized = true;
    }
}
