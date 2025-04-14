// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { IInstance, Factory } from "src/attribute/Factory.sol";
import { MockInstance } from "./Instance.t.sol";

contract FactoryTest is Test {
    error InitializableNotInitializingError();
    error FactoryNotInstanceError();

    event InstanceRegistered(address indexed instance);

    MockFactory public factory;

    function setUp() public {
        MockInstance instance = new MockInstance();
        factory = new MockFactory(address(instance));
    }

    function test_initialize() public {
        // Test initialization behavior
        vm.expectRevert(abi.encodeWithSelector(InitializableNotInitializingError.selector));
        factory.initializeIncorrect();

        factory.initialize();
        assertEq(factory.owner(), address(this));
    }

    function test_create() public {
        factory.initialize();

        IInstance instance;

        // Use snapshot to predict the instance address for event testing
        uint256 snapshot = vm.snapshotState();
        instance = factory.create();
        vm.revertToState(snapshot);

        vm.expectEmit(true, true, true, true);
        emit InstanceRegistered(address(instance));
        factory.create();

        // Verify instance registration and factory reference
        assertTrue(factory.instances(instance));
        assertEq(address(instance.factory()), address(factory));
    }

    function test_create2() public {
        factory.initialize();

        IInstance instance;

        // Use snapshot to predict the instance address for event testing
        uint256 snapshot = vm.snapshotState();
        instance = factory.create2(bytes32(0));
        vm.revertToState(snapshot);

        vm.expectEmit(true, true, true, true);
        emit InstanceRegistered(address(instance));
        factory.create2(bytes32(0));
    }

    function test_computeCreate2Address() public {
        factory.initialize();

        // Verify create2 address computation matches actual deployment
        bytes32 salt = bytes32(0);
        address expected = address(factory.computeCreate2Address(salt));

        vm.expectEmit(true, true, true, true);
        emit InstanceRegistered(expected);
        factory.create2(salt);
    }

    function test_onlyCallableByInstance() public {
        factory.initialize();

        // Test instance-only function access control
        vm.expectRevert(abi.encodeWithSelector(FactoryNotInstanceError.selector));
        factory.onlyCallableByInstance();

        MockInstance instance = factory.create();
        vm.prank(address(instance));
        factory.onlyCallableByInstance();
    }
}

contract MockFactory is Factory {
    constructor(address implementation_) Factory(implementation_) {}

    function initialize() external initializer("MockFactory", 1) {
        __Factory__initialize();
    }

    function initializeIncorrect() external {
        __Factory__initialize();
    }

    function create() external onlyOwner returns (MockInstance) {
        return MockInstance(address(_create(abi.encodeCall(MockInstance.initialize, ()))));
    }

    function create2(bytes32 salt) external onlyOwner returns (MockInstance) {
        return MockInstance(address(_create2(abi.encodeCall(MockInstance.initialize, ()), salt)));
    }

    function computeCreate2Address(bytes32 salt) external view returns (address) {
        return _computeCreate2Address(abi.encodeCall(MockInstance.initialize, ()), salt);
    }

    function onlyCallableByInstance() external view onlyInstance {}
}
