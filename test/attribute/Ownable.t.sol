// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Ownable } from "../../src/attribute/Ownable.sol";
import { Version, VersionLib } from "../../src/attribute/types/Version.sol";

contract OwnableTest is Test {
    error InitializableAlreadyInitializedError();
    error OwnableNotOwnerError(address owner);
    error OwnableNotPendingOwnerError(address pendingOwner);

    event OwnerUpdated(address indexed newOwner);
    event PendingOwnerUpdated(address indexed newPendingOwner);

    MockOwnable public ownable;
    address public owner;
    address public user;
    address public unrelated;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");
        unrelated = makeAddr("unrelated");

        // Deploy the contract with the owner as msg.sender.
        vm.prank(owner);
        ownable = new MockOwnable();
    }

    function test_initializeInitializesOwner() public {
        // Initially, owner should be address(0)
        assertEq(ownable.owner(), address(0));

        // Expect the OwnerUpdated event with the owner address.
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit OwnerUpdated(owner);
        ownable.initialize("");

        // Verify owner is now set.
        assertEq(ownable.owner(), owner);
    }

    function test_initializeRevertsOnReinitialize() public {
        // Initially, owner is zero.
        assertEq(ownable.owner(), address(0));

        // Set the owner using __initializeV with a dummy version (simulate previous initialization).
        vm.prank(owner);
        ownable.initialize("");

        // Reinitializing with a new version should revert.
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(InitializableAlreadyInitializedError.selector));
        ownable.initialize("");
    }

    function test_setPendingOwnerUpdatesPendingOwner() public {
        // Initialize first.
        vm.prank(owner);
        ownable.initialize("");

        // Expect the PendingOwnerUpdated event.
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit PendingOwnerUpdated(user);
        ownable.updatePendingOwner(user);

        // Verify owner remains unchanged and pending owner is updated.
        assertEq(ownable.owner(), owner);
        assertEq(ownable.pendingOwner(), user);
    }

    function test_setPendingOwnerRevertsIfNotOwner() public {
        vm.prank(owner);
        ownable.initialize("");

        // Using a non-owner account should revert.
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, user));
        ownable.updatePendingOwner(user);
    }

    function test_setPendingOwnerResetToZero() public {
        vm.prank(owner);
        ownable.initialize("");

        // Reset pending owner by setting it to address(0)
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit PendingOwnerUpdated(address(0));
        ownable.updatePendingOwner(address(0));

        // Verify that pendingOwner is reset.
        assertEq(ownable.owner(), owner);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function test_acceptOwnerTransfersOwnership() public {
        vm.prank(owner);
        ownable.initialize("");
        vm.prank(owner);
        ownable.updatePendingOwner(user);

        // Expect the OwnerUpdated event when ownership is accepted.
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit OwnerUpdated(user);
        ownable.acceptOwner();

        // Verify ownership transfer and pendingOwner reset.
        assertEq(ownable.owner(), user);
        assertEq(ownable.pendingOwner(), address(0));
    }

    function test_acceptOwnerCallsBeforeAcceptOwnerHook() public {
        vm.prank(owner);
        ownable.initialize("");
        vm.prank(owner);
        ownable.updatePendingOwner(user);

        // Initially, beforeCalled should be false.
        bool beforeCalled = ownable.beforeCalled();
        assertFalse(beforeCalled);

        vm.expectEmit(true, true, true, true);
        emit OwnerUpdated(user);
        vm.expectEmit(true, true, true, true);
        emit PendingOwnerUpdated(address(0));
        vm.prank(user);
        ownable.acceptOwner();

        // Verify the hook was called.
        assertTrue(ownable.beforeCalled());
    }

    function test_acceptOwnerRevertsIfNotPendingOwner() public {
        vm.prank(owner);
        ownable.initialize("");
        vm.prank(owner);
        ownable.updatePendingOwner(user);

        // When the caller is not the pending owner (using owner account), it should revert.
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotPendingOwnerError.selector, owner));
        ownable.acceptOwner();

        // Similarly, using an unrelated account should revert.
        vm.prank(unrelated);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotPendingOwnerError.selector, unrelated));
        ownable.acceptOwner();
    }
}

contract MockOwnable is Ownable {
    bool public beforeCalled;

    constructor() Ownable("MockOwnable", VersionLib.from(0,0,1), VersionLib.from(0,0,0)) {}

    function initialize(bytes memory)
        external virtual override initializer(VersionLib.from(0,0,1))
    {
        super.__Ownable__initialize();
    }

    function initializeIncorrect() external {
        super.__Ownable__initialize();
    }

    function _beforeAcceptOwner() internal virtual override {
        beforeCalled = true;
        super._beforeAcceptOwner();
    }
}
