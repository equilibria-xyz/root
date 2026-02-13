// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {
    MutableTestV1Deploy,
    NonSampleContract,
    SampleContractV1,
    SampleContractV2,
    SampleContractWithOldInit,
    SampleContractWithVersionSameAsPredecessor
} from "./MutabilityTest.sol";
import { IOwnable } from "../../src/attribute/Ownable.sol";
import { IMutableTransparent } from "../../src/mutability/interfaces/IMutable.sol";
import { IMutator } from "../../src/mutability/interfaces/IMutator.sol";
import { IImplementation } from "../../src/mutability/interfaces/IImplementation.sol";

contract MutableTestV1 is MutableTestV1Deploy {
    function test_creation() public view {
        assertEq(instance1.version(), "1.0.1", "Version should be 1.0.1 after deployment");
        assertEq(instance1.immutableValue(), 101, "Immutable value should be 101");
        assertEq(instance1.getValue(), 112, "Initializer should have set value");
    }

    function test_identify() public view {
        assertEq(instance1.name(), "SampleContract", "Implementation name should be SampleContract");
        assertEq(instance1.version(), "1.0.1", "Implementation version should be 1.0.1");
        assertEq(instance1.predecessor(), "0.0.0", "Implementation predecessor should be 0.0.0");
    }

    function test_interaction() public {
        vm.prank(implementationOwner);
        instance1.setValue(153);
        assertEq(instance1.getValue(), 153, "Value should be 153");
    }

    function test_upgrade() public {
        SampleContractV2 instance2 = upgrade();
        assertEq(instance2.version(), "2.0.1", "Version should be 2.0.1 after upgrade");
        assertEq(instance2.owner(), implementationOwner, "Owner should still be implementationOwner");
        assertEq(instance2.immutableValue(), 201, "Immutable value should be 201");
        (uint256 value1, int256 value2) = instance2.getValues();
        assertEq(value1, 113, "Value1 should have incremented by initializer");
        assertEq(value2, 222, "Value2 should have set the initializer using initParams");
    }

    function test_predecessorMismatch() public {
        // cannot upgrade from SampleContractV1 to SampleContractV1 because the predecessor does not match
        SampleContractV1 instance2 = new SampleContractV1(102);
        vm.prank(owner);
        vm.expectRevert(IMutableTransparent.MutablePredecessorMismatch.selector);
        mutator.upgrade(instance2, abi.encode(888));
    }

    function test_versionMismatch() public {
        SampleContractWithVersionSameAsPredecessor instance2 = new SampleContractWithVersionSameAsPredecessor();
        vm.prank(owner);
        vm.expectRevert(IMutableTransparent.MutableVersionMismatch.selector);
        mutator.upgrade(instance2, "");
    }

    function test_notValidMutable() public {
        NonSampleContract nonSampleContract = new NonSampleContract();
        vm.prank(owner);
        vm.expectRevert(IMutator.MutatorInvalidMutable.selector);
        mutator.upgrade(nonSampleContract, "");
    }

    function test_nonOwnerCannotInteract() public {
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(this)));
        instance1.setValue(106);
    }

    function test_mutatorCannotInteract() public {
        vm.prank(address(mutator));
        vm.expectRevert(IMutableTransparent.MutableDeniedMutatorAccess.selector);
        instance1.setValue(106);
    }

    function test_mutatorOwnerCannotInteract() public {
        assertEq(mutator.owner(), owner, "Mutator owner should be owner");
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(owner)));
        instance1.setValue(106);
    }

    function test_noDirectConstructorAccess() public {
        vm.expectRevert(IMutableTransparent.MutableDeniedConstructorAccess.selector);
        instance1.construct("");
    }

    function test_canPause() public {
        vm.prank(owner);
        vm.expectEmit();
        emit IMutableTransparent.Paused();
        mutator.pause();

        // user cannot interact
        vm.prank(implementationOwner);
        vm.expectRevert(IMutableTransparent.PausedError.selector);
        instance1.setValue(444);
    }

    function test_canUnpause() public {
        vm.startPrank(owner);
        mutator.pause();
        vm.expectEmit();
        emit IMutableTransparent.Unpaused();
        mutator.unpause();

        vm.expectRevert(IMutableTransparent.UnpausedError.selector);
        mutator.unpause();
        vm.stopPrank();

        vm.prank(implementationOwner);
        instance1.setValue(555);
        assertEq(instance1.getValue(), 555, "User interacted after unpaused");
    }

    function test_cantUpgradeWhilePaused() public {
        // change state and then pause the mutable
        vm.prank(implementationOwner);
        instance1.setValue(155);
        vm.prank(owner);
        mutator.pause();

        // upgrade while paused and then unpause
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(owner);
        vm.expectRevert(IMutableTransparent.PausedError.selector);
        mutator.upgrade(impl2, abi.encode(uint256(222)));
    }

    function test_canUpgradeViaAtomicUnpauseUpgradePauseBundle() public {
        // enter paused state first
        vm.prank(owner);
        mutator.pause();

        // direct upgrade call while paused still fails
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(owner);
        vm.expectRevert(IMutableTransparent.PausedError.selector);
        mutator.upgrade(impl2, abi.encode(uint256(333)));

        // simulate an atomic owner bundle during pause window
        vm.startPrank(owner);
        mutator.unpause();
        mutator.upgrade(impl2, abi.encode(uint256(333)));
        mutator.pause();
        vm.stopPrank();

        // bundle ends with system paused
        vm.prank(implementationOwner);
        vm.expectRevert(IMutableTransparent.PausedError.selector);
        instance1.setValue(777);

        // once unpaused, upgraded implementation is active with expected initialized state
        vm.prank(owner);
        mutator.unpause();

        SampleContractV2 upgraded = SampleContractV2(address(mutableContract));
        assertEq(upgraded.version(), "2.0.1", "Version should be upgraded after bundle");
        (uint256 value1, int256 value2) = upgraded.getValues();
        assertEq(value1, 113, "value1 should be incremented by V2 initializer");
        assertEq(value2, 333, "value2 should be set by V2 initializer");
    }
}

contract MutableTestV2 is MutableTestV1Deploy {
    SampleContractV2 instance2;

    function setUp() public override {
        super.setUp();
        // upgrade the mutable
        instance2 = upgrade();
    }

    function test_identify() public view {
        assertEq(instance2.name(), "SampleContract", "Implementation name should be SampleContract2");
        assertEq(instance2.version(), "2.0.1", "Implementation version should be 2");
        assertEq(instance2.predecessor(), "1.0.1", "Implementation predecessor should be 1.0.1");
    }

    function test_interactionPostUpgrade() public {
        vm.prank(implementationOwner);
        instance2.setValues(253, -254);
        (uint256 val1, int256 val2) = instance2.getValues();
        assertEq(instance2.immutableValue(), 201, "Immutable value should still be 201");
        assertEq(val1, 253, "Value1 should be 253");
        assertEq(val2, -254, "Value2 should be -254");
    }

    function test_implementationCanRevert() public {
        vm.expectRevert(SampleContractV2.CustomError.selector);
        instance2.revertWhenCalled();
    }

    function test_cantUpgradeWithDifferentInitVersion() public {
        // upgrade passing the initializer a different version than the contract
        SampleContractWithOldInit impl202 = new SampleContractWithOldInit(202);
        vm.prank(owner);
        vm.expectRevert(IImplementation.ImplementationConstructorVersionMismatch.selector);
        mutator.upgrade(
            impl202,
            ""
        );
    }
}

contract MockMutable {
    address public immutable owner;

    constructor(address owner_) {
        owner = owner_;
    }
}
