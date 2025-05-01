// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { IInstance, Factory } from "../../src/attribute/Factory.sol";
import { Mutable } from "../../src/mutability/Mutable.sol";
import { MockInstance } from "./Instance.t.sol";
import { Version, VersionLib } from "src/attribute/types/Version.sol";

contract FactoryTest is Test {
    error AttributeNotConstructing();
    error FactoryNotInstanceError();

    event InstanceRegistered(address indexed instance);

    MockFactory public factory;

    function setUp() public {
        MockInstance instance = new MockInstance();
        factory = new MockFactory(address(instance));
    }

    function test_constructor() public {
        // Test construction behavior
        vm.expectRevert(abi.encodeWithSelector(AttributeNotConstructing.selector));
        factory.notConstructor();

        factory.construct("");
        assertEq(factory.owner(), address(this));
    }

    function test_create() public {
        factory.construct("");

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
        factory.construct("");

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
        factory.construct("");

        // Verify create2 address computation matches actual deployment
        bytes32 salt = bytes32(0);
        address expected = address(factory.computeCreate2Address(salt));

        vm.expectEmit(true, true, true, true);
        emit InstanceRegistered(expected);
        factory.create2(salt);
    }

    function test_onlyCallableByInstance() public {
        factory.construct("");

        // Test instance-only function access control
        vm.expectRevert(abi.encodeWithSelector(FactoryNotInstanceError.selector));
        factory.onlyCallableByInstance();

        MockInstance instance = factory.create();
        vm.prank(address(instance));
        factory.onlyCallableByInstance();
    }
}

contract MockFactory is Mutable, Factory {
    constructor(address implementation_) Factory(
        "MockFactory",
        implementation_,
        VersionLib.from(0,0,1),
        VersionLib.from(0,0,0)
    ) {}

    function __constructor(bytes memory) internal override returns (uint256 version) {
        __Ownable__constructor();
        __Pausable__constructor();

        version = VersionLib.from(0,0,1);
    }

    function notConstructor() external {
        __Ownable__constructor();
        __Pausable__constructor();
    }

    function create() external onlyOwner returns (MockInstance) {
        return MockInstance(address(_create(
            abi.encodeCall(Mutable.construct, (""))
        )));
    }

    function create2(bytes32 salt) external onlyOwner returns (MockInstance) {
        return MockInstance(address(_create2(
            abi.encodeCall(Mutable.construct, ("")), salt)));
    }

    function computeCreate2Address(bytes32 salt) external view returns (address) {
        return _computeCreate2Address(
            abi.encodeCall(Mutable.construct, ("")), salt);
    }

    function onlyCallableByInstance() external view onlyInstance {}
}
