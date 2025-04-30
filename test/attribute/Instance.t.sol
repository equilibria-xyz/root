// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Instance } from "../../src/attribute/Instance.sol";
import { Mutable } from "../../src/mutability/Mutable.sol";
import { MockFactory } from "./Factory.t.sol";

contract InstanceTest is Test {
    error InitializableNotInitializingError();
    error InstanceNotFactoryError(address factory);
    error InstanceNotOwnerError(address owner);
    error PausableNotPauserError(address pauser);
    error InstancePausedError();

    MockInstance public instance;
    MockFactory public factory;

    function setUp() public {
        instance = new MockInstance();
        factory = new MockFactory(address(instance));
        factory.construct("");
    }

    function test_initialize() public {
        // should revert when incorrectly initialized
        vm.expectRevert(InitializableNotInitializingError.selector);
        vm.prank(address(factory));
        instance.notConstructor();

        // should initialize when correctly initialized
        vm.prank(address(factory));
        instance.construct("");
        assertEq(address(instance.factory()), address(factory));
    }

    function test_onlyOwnerModifier() public {
        vm.prank(address(factory));
        instance.construct("");

        vm.prank(address(factory.owner()));
        assertEq(instance.protectedFunctionOwner(), true);

        address incorrectOwner = makeAddr("incorrectOwner");
        vm.expectRevert(abi.encodeWithSelector(InstanceNotOwnerError.selector, incorrectOwner));
        vm.prank(incorrectOwner);
        instance.protectedFunctionOwner();
    }

    function test_onlyFactoryModifier() public {
        vm.prank(address(factory));
        instance.construct("");

        vm.prank(address(factory));
        assertEq(instance.protectedFunctionFactory(), true);

        address incorrectFactory = makeAddr("incorrectFactory");
        vm.expectRevert(abi.encodeWithSelector(InstanceNotFactoryError.selector, incorrectFactory));
        vm.prank(incorrectFactory);
        instance.protectedFunctionFactory();
    }

    function test_whenNotPausedModifier() public {
        vm.prank(address(factory));
        instance.construct("");

        vm.prank(address(factory));
        assertEq(instance.protectedFunctionPaused(), true);

        address incorrectPauser = makeAddr("incorrectPauser");
        vm.expectRevert(abi.encodeWithSelector(PausableNotPauserError.selector, incorrectPauser));
        vm.prank(incorrectPauser);
        factory.pause();

        // pause the factory
        vm.prank(address(factory.owner()));
        factory.pause();

        // should revert when paused
        vm.expectRevert(abi.encodeWithSelector(InstancePausedError.selector));
        vm.prank(address(factory));
        instance.protectedFunctionPaused();
    }
}

contract MockInstance is Mutable, Instance {
    function __constructor(bytes memory) internal override returns (uint256 version) {
        __Instance__constructor();

        version = 1;
    }

    function notConstructor() external {
        __Instance__constructor();
    }

    /// @dev This function can only be called by the factory owner
    function protectedFunctionOwner() external view onlyOwner returns (bool) {
        return true;
    }

    /// @dev This function can only be called by the factory
    function protectedFunctionFactory() external view onlyFactory returns (bool) {
        return true;
    }

    /// @dev This function can only be called when the factory is not paused
    function protectedFunctionPaused() external view whenNotPaused returns (bool) {
        return true;
    }
}
