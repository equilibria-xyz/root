// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";

import { IOwnable } from "../../src/attribute/interfaces/IOwnable.sol";
import { OwnableStub } from "../../src/utils/OwnableStub.sol";
import { MockOwnable } from "../attribute/Ownable.t.sol";
import { MockMutable } from "../mutability/Mutable.t.sol";

contract OwnableStubTest is Test {
    OwnableStub public ownableStub;
    MockOwnable public ownableContract;
    MockMutable public mockMutable;

    address public owner;
    address public user;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");

        vm.startPrank(owner);
        ownableStub = new OwnableStub();
        ownableContract = new MockOwnable();
        mockMutable = new MockMutable(owner);
        vm.stopPrank();

        vm.prank(address(mockMutable));
        ownableContract.construct("");
    }

    function test_acceptOwnerWorksWhenStubIsPendingOwner() public {
        // Set stub as pending owner
        vm.prank(owner);
        ownableContract.updatePendingOwner(address(ownableStub));

        assertEq(ownableContract.pendingOwner(), address(ownableStub));

        // Accept ownership through the stub
        vm.prank(owner);
        ownableStub.acceptOwner(address(ownableContract));

        // Verify ownership transfer
        assertEq(ownableContract.owner(), address(ownableStub));
        assertEq(ownableContract.pendingOwner(), address(0));
    }

    function test_acceptOwnerRevertsWhenStubIsNotPendingOwner() public {
        // Set addr1 as pending owner
        vm.prank(owner);
        ownableContract.updatePendingOwner(user);

        assertEq(ownableContract.pendingOwner(), user);

        // Stub owner tries to accept ownership when stub is not pending owner — should revert
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotPendingOwnerError.selector, address(ownableStub)));
        ownableStub.acceptOwner(address(ownableContract));
    }

    function test_acceptOwnerRevertsForNonStubOwner() public {
        vm.prank(owner);
        ownableContract.updatePendingOwner(address(ownableStub));

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, user));
        ownableStub.acceptOwner(address(ownableContract));
    }
}
