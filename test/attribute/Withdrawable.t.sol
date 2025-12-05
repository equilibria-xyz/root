// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { Withdrawable, Ownable } from "../../src/attribute/Withdrawable.sol";
import { Token18 } from "../../src/token/types/Token18.sol";
import { MockOwnable } from "./Ownable.t.sol";
import { MockMutable } from "../mutability/Mutable.t.sol";

contract OwnerWithdrawableTest is Test {
    error OwnableNotOwnerError(address owner);

    MockWithdrawable public withdrawable;
    MockERC20 public erc20;
    MockMutable public mockMutable;

    address public owner;
    address public addr1;

    function setUp() public {
        owner = makeAddr("owner");
        addr1 = makeAddr("addr1");

        // Deploy the withdrawable contract and initialize it
        vm.startPrank(owner);
        withdrawable = new MockWithdrawable();
        mockMutable = new MockMutable(owner);

        // Deploy and mint ERC20 tokens
        erc20 = new MockERC20("TestToken", "TT");
        erc20.mint(owner, 1000);
        vm.stopPrank();

        vm.prank(address(mockMutable));
        withdrawable.construct("");
    }

    function test_ownerCanWithdrawERC20() public {
        // Transfer tokens to the contract
        vm.prank(owner);
        erc20.transfer(address(withdrawable), 100);

        assertEq(erc20.balanceOf(address(withdrawable)), 100);

        // Withdraw tokens
        vm.prank(owner);
        withdrawable.withdraw(Token18.wrap(address(erc20)));

        // Validate final balances
        assertEq(erc20.balanceOf(address(withdrawable)), 0);
        assertEq(erc20.balanceOf(owner), 1000);
    }

    function test_nonOwnerCannotWithdrawERC20() public {
        // Transfer tokens to the contract
        vm.prank(owner);
        erc20.transfer(address(withdrawable), 100);

        assertEq(erc20.balanceOf(address(withdrawable)), 100);

        // Attempt withdrawal from non-owner
        vm.prank(addr1);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, addr1));
        withdrawable.withdraw(Token18.wrap(address(erc20)));

        // Ensure tokens are still in the contract
        assertEq(erc20.balanceOf(address(withdrawable)), 100);
    }
}

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MockWithdrawable is MockOwnable, Withdrawable {
    function withdraw(Token18 token) public override(Withdrawable) {
        super.withdraw(token);
    }

    function _beforeAcceptOwner() internal override(MockOwnable, Ownable) {
        super._beforeAcceptOwner();
    }
}
