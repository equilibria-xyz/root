pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { Treasury } from "../../src/distribution/Treasury.sol";
import { MockERC20 } from "../attribute/OwnerWithdrawable.t.sol";
import { Ownable } from "../../src/attribute/Ownable.sol";

contract TreasuryTest is Test {
    Treasury private treasury;
    MockERC20 private token;
    address private owner;
    address private user;

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");
        token = new MockERC20("MockToken", "MTK");
        treasury = new Treasury();
        treasury.initialize();

        // Mint tokens to the owner
        token.mint(owner, 1000e18);
    }

    function testDeposit() public {
        // Owner approves and deposits tokens to the treasury
        uint256 amount = 100e18;
        vm.startPrank(owner);
        token.approve(address(treasury), amount);

        treasury.deposit(address(token), amount);
        vm.stopPrank();

        assertEq(token.balanceOf(address(treasury)), amount);
        assertEq(token.balanceOf(owner), 1000e18 - amount);
    }

    function testApprove() public {
        // Owner approves the user to pull tokens from the treasury
        uint256 amount = 100e18;
        vm.prank(owner);
        treasury.approve(address(token), user, amount);

        assertEq(token.allowance(address(treasury), user), amount);
    }

    function testApproveAndPull() public {
        // Owner approves and deposits tokens to the treasury
        uint256 amount = 100e18;
        vm.startPrank(owner);
        token.approve(address(treasury), amount);
        treasury.deposit(address(token), amount);

        assertEq(token.balanceOf(address(treasury)), amount);

        // Owner approves the user to pull tokens from the treasury
        treasury.approve(address(token), user, amount);
        vm.stopPrank();

        assertEq(token.allowance(address(treasury), user), amount);

        // User pulls tokens from the treasury
        vm.prank(user);
        token.transferFrom(address(treasury), user, amount);

        assertEq(token.balanceOf(address(treasury)), 0);
        assertEq(token.balanceOf(user), amount);
    }

    function testOnlyOwnerCanApprove() public {
        // User attempts to approve the user to pull tokens from the treasury
        uint256 amount = 100e18;
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, user));
        treasury.approve(address(token), user, amount);
    }
}
