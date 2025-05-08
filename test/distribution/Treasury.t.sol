pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { Treasury } from "../../src/distribution/Treasury.sol";
import { MockERC20 } from "../attribute/OwnerWithdrawable.t.sol";
import { IOwnable } from "../../src/attribute/interfaces/IOwnable.sol";
import { Token } from "../../src/token/types/Token.sol";

contract TreasuryTest is Test {
    Treasury private treasury;
    Token private token;
    address private owner;
    address private user;

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");
        token = Token.wrap(address(new MockERC20("MockToken", "MTK")));
        treasury = new Treasury();
        treasury.initialize();

        // Mint tokens to the owner
        MockERC20(Token.unwrap(token)).mint(owner, 1000e18);
    }

    function test_pull() public {
        // Owner approves and deposits tokens to the treasury
        uint256 amount = 100e18;
        vm.startPrank(owner);
        token.approve(address(treasury), amount);

        treasury.pull(token, owner, amount);
        vm.stopPrank();

        assertEq(token.balanceOf(address(treasury)), amount);
        assertEq(token.balanceOf(owner), 1000e18 - amount);
    }

    function test_approveAndPullFromTreasury() public {
        // Owner approves and deposits tokens to the treasury
        uint256 amount = 100e18;
        vm.startPrank(owner);
        token.approve(address(treasury), amount);
        treasury.pull(token, owner, amount);

        assertEq(token.balanceOf(address(treasury)), amount);

        // Owner approves the user to pull tokens from the treasury
        treasury.credit(token, user, amount);
        vm.stopPrank();

        assertEq(MockERC20(Token.unwrap(token)).allowance(address(treasury), user), amount);

        // User pulls tokens from the treasury
        vm.prank(user);
        token.pullTo(address(treasury), user, amount);

        assertEq(token.balanceOf(address(treasury)), 0);
        assertEq(token.balanceOf(user), amount);
    }

    function test_onlyOwnerCanUpdateAllowance() public {
        // User attempts to approve the user to pull tokens from the treasury
        uint256 amount = 100e18;
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, user));
        treasury.credit(token, user, amount);

        // User attempts to decrease the allowance
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, user));
        treasury.debit(token, user, amount);

        // User attempts to reset the allowance
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(IOwnable.OwnableNotOwnerError.selector, user));
        treasury.reset(token, user);
    }

    function test_increaseAllowance() public {
        // Owner approves the user to pull tokens from the treasury
        vm.prank(owner);
        treasury.credit(token, user, 100e18);

        // Owner increases the allowance by 10e18
        vm.prank(owner);
        treasury.credit(token, user, 10e18);

        assertEq(MockERC20(Token.unwrap(token)).allowance(address(treasury), user), 110e18);
    }

    function test_decreaseAllowance() public {
        // Owner approves the user to pull tokens from the treasury
        vm.prank(owner);
        treasury.credit(token, user, 100e18);

        // Owner decreases the allowance by 10e18
        vm.prank(owner);
        treasury.debit(token, user, 10e18);

        assertEq(MockERC20(Token.unwrap(token)).allowance(address(treasury), user), 90e18);

        // Owner decreases the allowance by more than the current allowance
        vm.prank(owner);
        treasury.debit(token, user, 100e18);

        // Ensure the allowance is set to 0
        assertEq(MockERC20(Token.unwrap(token)).allowance(address(treasury), user), 0);
    }

    function test_resetAllowance() public {
        // Owner approves the user to pull tokens from the treasury
        vm.prank(owner);
        treasury.credit(token, user, 100e18);

        // Owner resets the allowance
        vm.prank(owner);
        treasury.reset(token, user);

        assertEq(MockERC20(Token.unwrap(token)).allowance(address(treasury), user), 0);
    }
}