// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { Escrow } from "src/attribute/Escrow.sol";
import { IEscrow } from "src/attribute/interfaces/IEscrow.sol";
import { MockERC20 } from "test/attribute/OwnerWithdrawable.t.sol";

contract EscrowTest is Test {
    Escrow public escrow;
    MockERC20 public token1;
    MockERC20 public token2;

    address public owner = makeAddr("owner");
    address public depositor = makeAddr("depositor");
    address public beneficiary = makeAddr("beneficiary");

    uint256 public constant AMOUNT = 1000 * 10**18;
    uint256 public constant MINIMUM_DEADLINE = 1 days;

    function setUp() public {
        vm.startPrank(owner);

        // Deploy mock tokens
        token1 = new MockERC20("Token 1", "TK1");
        token2 = new MockERC20("Token 2", "TK2");

        // Deploy escrow contract
        escrow = new Escrow();

        // Initialize with whitelisted tokens
        address[] memory whitelistedTokens = new address[](1);
        whitelistedTokens[0] = address(token1);
        escrow.initialize(whitelistedTokens);

        vm.stopPrank();

        // Mint tokens to depositor
        token1.mint(depositor, AMOUNT * 10);
        token2.mint(depositor, AMOUNT * 10);
    }

    function test_initialize() public view {
        assertTrue(escrow.isTokenWhitelisted(address(token1)), "Token1 should be whitelisted");
        assertFalse(escrow.isTokenWhitelisted(address(token2)), "Token2 should not be whitelisted");
        assertEq(escrow.owner(), owner, "Owner should be set correctly");
    }

    function test_updateTokenWhitelist() public {
        vm.startPrank(owner);
        escrow.updateTokenWhitelist(address(token2), true);

        assertTrue(escrow.isTokenWhitelisted(address(token2)), "Token2 should be whitelisted");

        escrow.updateTokenWhitelist(address(token1), false);

        assertFalse(escrow.isTokenWhitelisted(address(token1)), "Token1 should not be whitelisted");
        vm.stopPrank();
    }

    function test_updateTokenWhitelistNotOwner() public {
        vm.prank(depositor);
        vm.expectRevert(abi.encodeWithSignature("OwnableNotOwnerError(address)", depositor));
        escrow.updateTokenWhitelist(address(token2), true);
    }

    function test_deposit() public {
        vm.prank(owner);
        escrow.updateTokenWhitelist(address(token2), true);

        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        vm.stopPrank();

        assertEq(token1.balanceOf(address(escrow)), AMOUNT, "Escrow should have received tokens");
        assertEq(escrow.getTotalAmount(beneficiary, address(token1)), AMOUNT, "Total amount should be correct");

        IEscrow.Deposit[] memory deposits = escrow.getDeposits(beneficiary);
        assertEq(deposits.length, 1, "Should have one deposit");
        assertEq(deposits[0].depositor, depositor, "Depositor should be correct");
        assertEq(deposits[0].token, address(token1), "Token should be correct");
        assertEq(deposits[0].amount, AMOUNT, "Amount should be correct");
        assertEq(uint256(deposits[0].deadline), deadline, "Deadline should be correct");
    }

    function test_depositZeroAmount() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), 0);
        vm.expectRevert(IEscrow.EscrowZeroAmountError.selector);
        escrow.deposit(beneficiary, address(token1), 0, deadline);
        vm.stopPrank();
    }

    function test_depositTokenNotWhitelisted() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token2.approve(address(escrow), AMOUNT);
        vm.expectRevert(IEscrow.EscrowTokenNotWhitelistedError.selector);
        escrow.deposit(beneficiary, address(token2), AMOUNT, deadline);
        vm.stopPrank();
    }

    function test_depositInvalidDeadline() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE - 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT);
        vm.expectRevert(IEscrow.EscrowInvalidDeadlineError.selector);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        vm.stopPrank();
    }

    function test_withdraw() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        vm.stopPrank();

        vm.prank(beneficiary);
        escrow.withdraw(address(token1));

        assertEq(token1.balanceOf(beneficiary), AMOUNT, "Beneficiary should have received tokens");
        assertEq(token1.balanceOf(address(escrow)), 0, "Escrow should have no tokens left");
        assertEq(escrow.getTotalAmount(beneficiary, address(token1)), 0, "Total amount should be zero");
    }

    function test_withdrawNoFunds() public {
        vm.prank(beneficiary);
        vm.expectRevert(IEscrow.EscrowNoFundsDepositedError.selector);
        escrow.withdraw(address(token1));
    }

    function test_reclaimExpiredFunds() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);


        // Advance time past deadline
        vm.warp(deadline + 1);

        escrow.reclaimExpiredFunds(beneficiary, address(token1));
        vm.stopPrank();

        assertEq(token1.balanceOf(depositor), AMOUNT * 10, "Depositor should have received tokens back");
        assertEq(token1.balanceOf(address(escrow)), 0, "Escrow should have no tokens left");
        assertEq(escrow.getTotalAmount(beneficiary, address(token1)), 0, "Total amount should be zero");
    }

    function test_reclaimExpiredFundsBeforeDeadline() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);

        // Try to reclaim before deadline
        vm.expectRevert(IEscrow.EscrowNoFundsDepositedError.selector);
        escrow.reclaimExpiredFunds(beneficiary, address(token1));
        vm.stopPrank();
    }

    function test_reclaimExpiredFundsWrongDepositor() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        vm.stopPrank();

        // Advance time past deadline
        vm.warp(deadline + 1);

        // Try to reclaim as wrong depositor
        vm.prank(beneficiary);
        vm.expectRevert(IEscrow.EscrowNoFundsDepositedError.selector);
        escrow.reclaimExpiredFunds(beneficiary, address(token1));
    }

    function test_getDepositors() public {
        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT * 2);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        vm.stopPrank();

        address[] memory depositors = escrow.getDepositors(beneficiary);
        assertEq(depositors.length, 2, "Should have two depositors");
        assertEq(depositors[0], depositor, "First depositor should be correct");
        assertEq(depositors[1], depositor, "Second depositor should be correct");
    }

    function test_multipleDepositsAndWithdrawals() public {
        vm.prank(owner);
        escrow.updateTokenWhitelist(address(token2), true);

        uint256 deadline = block.timestamp + MINIMUM_DEADLINE + 1 hours;

        // Make multiple deposits
        vm.startPrank(depositor);
        token1.approve(address(escrow), AMOUNT * 2);
        token2.approve(address(escrow), AMOUNT);

        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        escrow.deposit(beneficiary, address(token1), AMOUNT, deadline);
        escrow.deposit(beneficiary, address(token2), AMOUNT, deadline);
        vm.stopPrank();

        // Verify balances
        assertEq(escrow.getTotalAmount(beneficiary, address(token1)), AMOUNT * 2, "Total token1 amount should be correct");
        assertEq(escrow.getTotalAmount(beneficiary, address(token2)), AMOUNT, "Total token2 amount should be correct");

        // Withdraw token1
        vm.prank(beneficiary);
        escrow.withdraw(address(token1));

        // Verify balances after withdrawal
        assertEq(token1.balanceOf(beneficiary), AMOUNT * 2, "Beneficiary should have received token1");
        assertEq(escrow.getTotalAmount(beneficiary, address(token1)), 0, "Total token1 amount should be zero");
        assertEq(escrow.getTotalAmount(beneficiary, address(token2)), AMOUNT, "Total token2 amount should be unchanged");
    }
}
