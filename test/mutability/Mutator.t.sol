// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";

import { MutableTestV1Deploy, NewContract, SampleContractV2 } from "./MutabilityTest.sol";
import { IOwnable } from "../../src/attribute/Ownable.sol";
import { IMutableTransparent } from "../../src/mutability/interfaces/IMutable.sol";
import { IPausable } from "../../src/attribute/interfaces/IPausable.sol";
import { Implementation } from "../../src/mutability/Implementation.sol";

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

    function test_createMultipleMutables() public {
        // create a new mutable
        vm.startPrank(owner);
        NewContract otherContract = new NewContract("OtherContract");
        IMutableTransparent newMutable = mutator.create(otherContract, "");

        // ensure mutables list contains both mutables
        address[] memory mutables = mutator.mutables();
        assertEq(mutables.length, 2, "Mutables list should contain two mutables");
        assertEq(mutables[0], address(mutableContract), "First mutable should be a SampleContractV1 from setup");
        assertEq(mutables[1], address(newMutable), "Second mutable should be OtherContract from above");
        vm.stopPrank();
    }

    function test_createWhilePaused() public {
        vm.startPrank(owner);
        vm.expectEmit();
        emit IMutableTransparent.Paused();
        mutator.pause();

        // create a new mutable while paused
        NewContract otherContract = new NewContract("OtherContract");
        mutator.create(otherContract, "");
        vm.stopPrank();

        // ensure first contract is paused
        address[] memory mutables = mutator.mutables();
        Implementation contract1 = Implementation(mutables[0]);
        vm.expectRevert(IMutableTransparent.PausedError.selector);
        contract1.name();

        // ensure second contract is paused
        Implementation contract2 = Implementation(mutables[1]);
        vm.expectRevert(IMutableTransparent.PausedError.selector);
        contract2.name();
    }

    function test_pauseUnpauseScalesToHundredMutables() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 99; i++) {
            mutator.create(new NewContract(string.concat("N", vm.toString(i))), "");
        }
        vm.stopPrank();

        address[] memory mutables = mutator.mutables();
        assertEq(mutables.length, 100, "Expected 100 mutables");

        vm.prank(owner);
        uint256 gasBeforePause = gasleft();
        mutator.pause();
        uint256 pauseGas = gasBeforePause - gasleft();

        vm.expectRevert(IMutableTransparent.PausedError.selector);
        Implementation(mutables[0]).name();

        vm.prank(owner);
        uint256 gasBeforeUnpause = gasleft();
        mutator.unpause();
        uint256 unpauseGas = gasBeforeUnpause - gasleft();

        assertLt(pauseGas, 4_000_000, "Pause gas exceeded target");
        assertLt(unpauseGas, 4_000_000, "Unpause gas exceeded target");
    }

    function test_revertsNonOwnerCannotSetPauser() public {
        address pauser = makeAddr("pauser");
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, address(this)));
        mutator.updatePauser(pauser);
    }

    function test_revertsOnUnauthorizedPause() public {
        vm.expectRevert(abi.encodeWithSelector(IPausable.PausableNotPauserError.selector, address(this)));
        mutator.pause();
    }

    function test_revertsOnUnauthorizedUnPause() public {
        vm.expectRevert(abi.encodeWithSelector(IPausable.PausableNotPauserError.selector, address(this)));
        mutator.unpause();
    }
}
