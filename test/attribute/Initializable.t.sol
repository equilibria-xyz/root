// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { RootTest } from "../../test/RootTest.sol";
import { Initializable } from "../../src/attribute/Initializable.sol";
import { Version, VersionLib } from "../../src/attribute/types/Version.sol";

contract InitializableTest is RootTest {
    error InitializableAlreadyInitializedError();
    error InitializableNotInitializingError();

    MockInitializable public initializable;
    Version public version = VersionLib.from(2, 6, 4);

    function test_constructor() public {
        initializable = new MockInitializable();
        assertEq(initializable.nameHash(), keccak256("MockInitializable"));
        assertEq(initializable.version(), version);
        assertEq(initializable.versionFrom(), VersionLib.from(1, 5, 3));
        assertEq(initializable.initializingStateInCtor(), false, "initializing() should be false in constructor");
    }

    function test_initializeSuccessfully() public {
        initializable = new MockInitializable();
        initializable.initialize(abi.encode("success"));
        assertEq(initializable.unsignedValue(), 1);
        assertEq(initializable.stringValue(), "success");
        assertEq(initializable.initializingStateInInit(), true, "initializing() should be true while initializing");
    }

    function test_revertAlreadyInitialized() public {
        initializable = new MockInitializable();
        initializable.initialize(abi.encode("first call"));

        // ensure a second call reverts
        vm.expectRevert(InitializableAlreadyInitializedError.selector);
        initializable.initialize(abi.encode("second call"));
        assertEq(initializable.stringValue(), "first call");
    }

    function test_skipsInitializeIfVersionMismatch() public {
        MockInitializableNoInit initializable2 = new MockInitializableNoInit();
        initializable2.initialize("");
        assertEq(initializable2.stringValue(), "set from ctor");
    }

    function test_revertIfNotInitializing_preInit() public {
        initializable = new MockInitializable();
        vm.expectRevert(InitializableNotInitializingError.selector);
        initializable.notCalledFromInitializer();
        assertEq(initializable.unsignedValue(), 0);
    }

    function test_revertIfNotInitializing_postInit() public {
        initializable = new MockInitializable();
        initializable.initialize(abi.encode("initialized"));

        vm.expectRevert(InitializableNotInitializingError.selector);
        initializable.notCalledFromInitializer();
        assertEq(initializable.unsignedValue(), 1);
    }
}

contract MockInitializable is Initializable {
    bool public initializingStateInCtor;
    bool public initializingStateInInit;
    string internal _stringValue;
    uint256 internal _unsignedValue;

    constructor() Initializable("MockInitializable", VersionLib.from(2, 6, 4), VersionLib.from(1, 5, 3)) {
        initializingStateInCtor = initializing();
    }

    function unsignedValue() external view returns (uint256) {
        return _unsignedValue;
    }

    function stringValue() external view returns (string memory) {
        return _stringValue;
    }

    function initialize(bytes memory initData)
        public virtual initializer(VersionLib.from(2, 6, 4))
    {
        _unsignedValue = 1;
        setStringValue(abi.decode(initData, (string)));
        initializingStateInInit = initializing();
    }

    // This function enforces that it may only be called during initialization
    function setStringValue(string memory value) private onlyInitializer() {
        _stringValue = value;
    }

    function notCalledFromInitializer() public {
        _unsignedValue = 2;
        setStringValue("rat");
    }
}

contract MockInitializableNoInit is Initializable {
    string public stringValue;

    constructor() Initializable("MockInitializableVersionMismatch", VersionLib.from(3, 2, 11), VersionLib.from(3, 2, 7)) {
        stringValue = "set from ctor";
    }

    // was used to upgrade from 3.2.7 to 3.2.8; irrelevant for 3.2.11
    function initialize(bytes memory initData)
        public virtual initializer(VersionLib.from(3, 2, 8))
    {
        stringValue = "set from init";
    }
}
