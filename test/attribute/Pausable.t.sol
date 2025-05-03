// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Mutable } from "../../src/mutability/Mutable.sol";
import { Pausable } from "../../src/attribute/Pausable.sol";

contract PausableTest is Test {
    event PauserUpdated(address indexed newPauser);
    event Paused();
    event Unpaused();

    error AttributeNotConstructing();
    error OwnableNotOwnerError(address pauser);
    error PausableNotPauserError(address pauser);
    error PausablePausedError();

    address public owner;
    address public newPauser;
    address public user;
    MockPausable public pausable;

    function setUp() public {
        owner = makeAddr("owner");
        newPauser = makeAddr("newPauser");
        user = makeAddr("user");

        vm.prank(owner);
        pausable = new MockPausable();
    }

    function test_constructor() public {
        // Test construction behavior
        vm.expectRevert(abi.encodeWithSelector(AttributeNotConstructing.selector));
        pausable.notConstructor();

        vm.expectEmit(true, true, false, true);
        emit PauserUpdated(owner);
        vm.prank(owner);
        pausable.construct("");

        assertEq(pausable.pauser(), owner);
        assertEq(pausable.owner(), owner);
    }

    function test_revertWhenReinitializing() public {
        vm.prank(owner);
        pausable.construct("");

        vm.expectRevert();
        vm.prank(owner);
        pausable.notConstructor();
    }

    function test_updatePauser() public {
        vm.prank(owner);
        pausable.construct("");

        vm.expectEmit(true, true, false, true);
        emit PauserUpdated(newPauser);
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        assertEq(pausable.pauser(), newPauser);
    }

    function test_onlyOwnerCanUpdatePauser() public {
        vm.prank(owner);
        pausable.construct("");

        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, user));
        vm.prank(user);
        pausable.updatePauser(user);

        vm.prank(owner);
        pausable.updatePauser(newPauser);

        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, newPauser));
        vm.prank(newPauser);
        pausable.updatePauser(user);
    }

    function test_pauserCanPause() public {
        vm.prank(owner);
        pausable.construct("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _pause(newPauser);
    }

    function test_ownerCanPause() public {
        vm.prank(owner);
        pausable.construct("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _pause(owner);
    }

    function test_otherUserCannotPause() public {
        vm.prank(owner);
        pausable.construct("");

        vm.expectRevert(abi.encodeWithSelector(PausableNotPauserError.selector, user));
        vm.prank(user);
        pausable.pause();
    }

    function test_pauserCanUnpause() public {
        vm.prank(owner);
        pausable.construct("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _unpause(newPauser);
    }

    function test_ownerCanUnpause() public {
        vm.prank(owner);
        pausable.construct("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _unpause(owner);
    }

    function test_otherUserCannotUnpause() public {
        vm.prank(owner);
        pausable.construct("");
        vm.prank(owner);
        pausable.pause();

        vm.expectRevert(abi.encodeWithSelector(PausableNotPauserError.selector, user));
        vm.prank(user);
        pausable.unpause();
    }

    function _pause(address who) internal {
        uint256 val1 = pausable.counter();
        vm.prank(address(0));
        pausable.increment(); // Unprotected call
        uint256 val2 = pausable.counter();
        assertEq(val2, val1 + 1);

        vm.prank(who);
        vm.expectEmit(true, false, false, true);
        emit Paused();
        pausable.pause();

        assertTrue(pausable.paused());

        vm.expectRevert(abi.encodeWithSelector(PausablePausedError.selector));
        pausable.increment();

        pausable.incrementNoModifier();
        assertEq(pausable.counter(), val2 + 1);
    }

    function _unpause(address who) internal {
        vm.prank(who);
        pausable.pause();
        assertTrue(pausable.paused());

        vm.prank(who);
        vm.expectEmit(true, false, false, true);
        emit Unpaused();
        pausable.unpause();

        assertFalse(pausable.paused());

        uint256 before = pausable.counter();
        pausable.increment();
        assertEq(pausable.counter(), before + 1);
    }
}

contract MockPausable is Mutable, Pausable {
    uint256 public counter;

    function __constructor(bytes memory) internal override returns (uint256 version) {
        __Ownable__constructor();
        __Pausable__constructor();

        version = 1;
    }

    function notConstructor() external {
        __Pausable__constructor();
    }

    function increment() external whenNotPaused {
        counter++;
    }

    function incrementNoModifier() external {
        counter++;
    }
}
