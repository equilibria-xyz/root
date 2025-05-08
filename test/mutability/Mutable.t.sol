// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {
    MutableTest,
    MutableTestV1Deploy,
    NonSampleContract,
    SampleContractV1,
    SampleContractV2,
    SampleContractWithOldInit
} from "./MutabilityTest.sol";
import { IOwnable, Ownable } from "../../src/attribute/Ownable.sol";
import { Version, VersionLib } from "../../src/mutability/types/Version.sol";
import { IMutableTransparent } from "../../src/mutability/interfaces/IMutable.sol";
import { Mutable } from "../../src/mutability/Mutable.sol";
import { Mutator } from "../../src/mutability/Mutator.sol";

contract MutableTestV1 is MutableTestV1Deploy {
    function test_creation() public view {
        assertEq(instance1.version(), VersionLib.from(1, 0, 1), "Version should be 1.0.1 after deployment");
        assertEq(instance1.immutableValue(), 101, "Immutable value should be 101");
        assertEq(instance1.getValue(), 112, "Initializer should have set value");
    }

    function test_identify() public view {
        assertEq(instance1.name(), "SampleContractV1", "Implementation name should be SampleContract");
        assertEq(instance1.version(), VersionLib.from(1, 0, 1), "Implementation version should be 1.0.1");
        assertEq(instance1.target(), VersionLib.from(0, 0, 0), "Implementation target should be 0.0.0");
    }

    function test_interaction() public {
        vm.prank(implementationOwner);
        instance1.setValue(153);
        assertEq(instance1.getValue(), 153, "Value should be 153");
    }

    function test_upgrade() public {
        SampleContractV2 instance2 = upgrade();
        assertEq(instance2.version(), VersionLib.from(2, 0, 1), "Version should be 2.0.1 after upgrade");
        assertEq(instance2.owner(), implementationOwner, "Owner should still be implementationOwner");
        assertEq(instance2.immutableValue(), 201, "Immutable value should be 201");
        (uint256 value1, int256 value2) = instance2.getValues();
        assertEq(value1, 113, "Value1 should have incremented by initializer");
        assertEq(value2, 222, "Value2 should have set the initializer using initParams");
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

    function test_nonMutatorCannotUpgrade() public {
        SampleContractV2 impl2 = new SampleContractV2(204);
        vm.expectRevert();
        mutator.upgrade(impl2.name(), impl2, "");
    }

    function test_revertsIfNameMismatch() public {
        NonSampleContract wrongContract = new NonSampleContract();
        vm.expectRevert(IMutableTransparent.MutableNameMismatch.selector);
        vm.prank(owner);
        mutator.upgrade(wrongContract.name(), wrongContract, "");
    }

    function test_canPause() public {
        /*vm.prank(implementationOwner);
        instance1.setValue(154);
        assertEq(instance1.value(), 154, "Value should be 154");*/

        vm.prank(owner);
        vm.expectEmit();
        emit IMutableTransparent.Paused();
        mutator.pause();

        // user can still read from contract
        /*assertEq(instance1.value(), 154, "Value should still be 154");
        assertEq(instance1.getValue(), 154, "Getter function should still return 154");*/

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
        vm.stopPrank();

        vm.prank(implementationOwner);
        instance1.setValue(555);
        assertEq(instance1.getValue(), 555, "User interacted after unpaused");
    }

    function test_upgradeWhilePaused() public {
        // change state and then pause the mutable
        vm.prank(implementationOwner);
        instance1.setValue(155);
        vm.prank(owner);
        mutator.pause();

        // upgrade while paused and then unpause
        SampleContractV2 instance2 = upgrade();
        vm.prank(owner);
        mutator.unpause();

        // check state
        assertEq(instance2.version(), VersionLib.from(2, 0, 1), "Version change after upgrade while paused");
        assertEq(instance2.immutableValue(), 201, "Immutable value after upgrade while paused");
        assertEq(instance2.value1(), 156, "Value1 after upgrade while paused");
        assertEq(instance2.value2(), 222, "Value2 after upgrade while paused");

        // confirm interactions still work
        vm.prank(implementationOwner);
        instance2.setValues(255, -17);
        (uint256 val1, int256 val2) = instance2.getValues();
        assertEq(val1, 255, "Value1 should be mutable after upgrade while paused");
        assertEq(val2, -17, "Value2 should be mutable after upgrade while paused");
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
        assertEq(instance2.name(), "SampleContractV2", "Implementation name should be SampleContract2");
        assertEq(instance2.version(), VersionLib.from(2, 0, 1), "Implementation version should be 2");
        assertEq(instance2.target(), VersionLib.from(1, 0, 1), "Implementation target should be 1.0.1");
    }

    function test_interactionPostUpgrade() public {
        vm.prank(implementationOwner);
        instance2.setValues(253, -254);
        (uint256 val1, int256 val2) = instance2.getValues();
        assertEq(instance2.immutableValue(), 201, "Immutable value should still be 201");
        assertEq(val1, 253, "Value1 should be 253");
        assertEq(val2, -254, "Value2 should be -254");
    }

    function test_revertsOnDowngradeAttempt() public {
        SampleContractV1 impl1 = new SampleContractV1(104);
        vm.expectRevert(abi.encodeWithSelector(
            IMutableTransparent.MutableVersionMismatch.selector,
            VersionLib.from(2, 0, 1),
            VersionLib.from(1, 0, 1)
        ));
        vm.prank(owner);
        mutator.upgrade(impl1.name(), impl1, "");
    }

    function test_implementationCanRevert() public {
        vm.expectRevert(SampleContractV2.CustomError.selector);
        instance2.revertWhenCalled();
    }

    function test_upgradeWithDifferentInitVersion() public {
        // upgrade passing the initializer a different version than the contract
        SampleContractWithOldInit impl202 = new SampleContractWithOldInit(202);
        vm.prank(owner);
        mutator.upgrade(
            impl202.name(),
            impl202,
            ""
        );
        SampleContractWithOldInit instance202 = SampleContractWithOldInit(address(mutableContract));

        // confirm upgrade worked and immutable value was updated
        assertEq(instance202.version(), VersionLib.from(2, 0, 2), "Version should be 2.0.2 after upgrade");
        assertEq(instance202.immutableValue(), 202, "Immutable value should be 202");

        // confirm initializer did not run
        assertEq(instance202.value1(), 113, "Initializer should not have mutated value1");
        assertEq(instance202.value2(), 222, "Initializer should not have mutated value2");
    }
}
