// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { Pausable } from "../../src/attribute/Pausable.sol";
import { Version } from "../../src/attribute/types/Version.sol";

contract PausableTest is Test {
    event PauserUpdated(address indexed newPauser);
    event Paused();
    event Unpaused();

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

    function test_initializeSetsPauserAndOwner() public {
        assertEq(pausable.pauser(), address(0));
        vm.expectEmit(true, true, false, true);
        emit PauserUpdated(owner);
        vm.prank(owner);
        pausable.initialize("");

        assertEq(pausable.pauser(), owner);
        assertEq(pausable.owner(), owner);
    }

    function test_revertWhenReinitializing() public {
        vm.prank(owner);
        pausable.initialize("");

        vm.expectRevert();
        vm.prank(owner);
        pausable.initializeIncorrect();
    }

    function test_updatePauser() public {
        vm.prank(owner);
        pausable.initialize("");

        vm.expectEmit(true, true, false, true);
        emit PauserUpdated(newPauser);
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        assertEq(pausable.pauser(), newPauser);
    }

    function test_onlyOwnerCanUpdatePauser() public {
        vm.prank(owner);
        pausable.initialize("");

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
        pausable.initialize("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _pause(newPauser);
    }

    function test_ownerCanPause() public {
        vm.prank(owner);
        pausable.initialize("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _pause(owner);
    }

    function test_otherUserCannotPause() public {
        vm.prank(owner);
        pausable.initialize("");

        vm.expectRevert(abi.encodeWithSelector(PausableNotPauserError.selector, user));
        vm.prank(user);
        pausable.pause();
    }

    function test_pauserCanUnpause() public {
        vm.prank(owner);
        pausable.initialize("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _unpause(newPauser);
    }

    function test_ownerCanUnpause() public {
        vm.prank(owner);
        pausable.initialize("");
        vm.prank(owner);
        pausable.updatePauser(newPauser);

        _unpause(owner);
    }

    function test_otherUserCannotUnpause() public {
        vm.prank(owner);
        pausable.initialize("");
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

contract MockPausable is Pausable {
    uint256 public counter;

    constructor() Pausable("MockPausable", Version(0,0,1), Version(0,0,0)) {}

    function initialize(bytes memory)
        external virtual override initializer(Version(0,0,1))
    {
        super.__Pausable__initialize();
    }

    function initializeIncorrect() external {
        super.__Pausable__initialize();
    }

    function increment() external whenNotPaused {
        counter++;
    }

    function incrementNoModifier() external {
        counter++;
    }
}
