// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";

import { MutableTestV1Deploy, SampleContractV2 } from "./MutabilityTest.sol";
import { IOwnable } from "../../src/attribute/Ownable.sol";
import { IMutableTransparent } from "../../src/mutability/interfaces/IMutable.sol";
import { IMutator, Mutator } from "../../src/mutability/Mutator.sol";

contract MutatorTest is MutableTestV1Deploy {
    address newOwner;

    function setUp() public override {
        super.setUp();
    }

    function updatePendingOwner() internal {
        // start with a pending update
        newOwner = makeAddr("newOwner");
        vm.prank(owner);
        vm.expectEmit();
        emit IOwnable.PendingOwnerUpdated(newOwner);
        mutator.updatePendingOwner(newOwner);
    }

    function test_mutablesList() public view {
        // ensure mutables list contains SampleContractV1 deployment
        address[] memory mutables = mutator.mutables();
        assertEq(mutables.length, 1, "Mutables list should contain one mutable");
        assertEq(mutables[0], address(mutableContract), "Mutables list should contain the mutable");
    }

    function test_oldOwnerCanUpgradeBeforeNewOwnerAccepts() public {
        updatePendingOwner();
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(owner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        mutator.upgrade(impl2, abi.encode(770));
    }

    function test_newOwnerMustAcceptChange() public {
        updatePendingOwner();
        assertEq(mutator.owner(), owner, "Mutator owner unchanged until accepted");

        vm.prank(newOwner);
        vm.expectEmit();
        emit IOwnable.OwnerUpdated(newOwner);
        mutator.acceptOwner();
        assertEq(mutator.owner(), newOwner, "Mutator owner changed");
    }

    function test_newOwnerCanUpgrade() public {
        updatePendingOwner();
        vm.prank(newOwner);
        mutator.acceptOwner();
        assertEq(mutator.owner(), newOwner, "Mutator owner should be newOwner");

        // old owner cannot upgrade
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, owner));
        mutator.upgrade(impl2, abi.encode(771));

        // new owner can upgrade
        vm.prank(newOwner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        mutator.upgrade(impl2, abi.encode(772));
    }

    function test_ownerCanPauseAndUnpause() public {
        vm.startPrank(owner);
        vm.expectEmit();
        emit IMutableTransparent.Paused();
        mutator.pause();

        vm.expectEmit();
        emit IMutableTransparent.Unpaused();
        mutator.unpause();
        vm.stopPrank();
    }

    function test_pauserAccessor() public {
        address pauser = makeAddr("pauser");
        vm.prank(owner);
        mutator.updatePauser(pauser);
        assertEq(mutator.pauser(), pauser, "Pauser should be set correctly");
    }

    function test_pauserCanPauseAndUnpause() public {
        address pauser = makeAddr("pauser");
        vm.prank(owner);
        mutator.updatePauser(pauser);

        vm.startPrank(pauser);
        vm.expectEmit();
        emit IMutableTransparent.Paused();
        mutator.pause();

        vm.expectEmit();
        emit IMutableTransparent.Unpaused();
        mutator.unpause();
        vm.stopPrank();
    }

    function test_revertsNonOwnerCannotSetPauser() public {
        address pauser = makeAddr("pauser");
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(this)));
        mutator.updatePauser(pauser);
    }

    function test_revertsOnUnauthorizedPause() public {
        vm.expectRevert(abi.encodeWithSelector(IMutator.MutatorNotPauserError.selector, address(this)));
        mutator.pause();
    }

    function test_revertsOnUnauthorizedUnPause() public {
        vm.expectRevert(abi.encodeWithSelector(IMutator.MutatorNotPauserError.selector, address(this)));
        mutator.unpause();
    }
}
