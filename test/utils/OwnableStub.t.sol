// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";

import { OwnableStub } from "../../src/utils/OwnableStub.sol";
import { MockOwnable } from "../attribute/Ownable.t.sol";
import { MockMutable } from "../mutability/Mutable.t.sol";

contract OwnableStubTest is Test {
    error OwnableNotPendingOwnerError(address pendingOwner);

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
        vm.prank(address(ownableStub));
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

        // Stub tries to accept ownership — should revert
        vm.prank(address(ownableStub));
        vm.expectRevert(abi.encodeWithSelector(OwnableNotPendingOwnerError.selector, address(ownableStub)));
        ownableStub.acceptOwner(address(ownableContract));
    }
}
