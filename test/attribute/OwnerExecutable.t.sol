// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Test } from "forge-std/Test.sol";

import { OwnerExecutable, Ownable } from "../../src/attribute/OwnerExecutable.sol";
import { MockOwnable } from "./Ownable.t.sol";
import { MockToken18 } from "../token/Token18.t.sol";
import { MockMutable } from "../mutability/Mutable.t.sol";

contract OwnerExecutableTest is Test {
    error OwnableNotOwnerError(address owner);

    MockOwnerExecutable public ownableExecutable;
    MockToken18 public mockToken;
    MockMutable public mockMutable;

    address public owner;
    address public user;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");

        vm.startPrank(owner);
        ownableExecutable = new MockOwnerExecutable();
        mockMutable = new MockMutable(owner);
        vm.stopPrank();

        vm.prank(address(mockMutable));
        ownableExecutable.construct("");
    }

    function test_staticCallReturnsOwner() public {
        // Encode call to `owner()` function
        bytes memory data = abi.encodeWithSignature("owner()");
        address target = address(ownableExecutable);

        // Use staticcall to simulate the result
        vm.prank(owner);
        (bytes memory returnData) = ownableExecutable.execute(target, data);

        // Decode the result
        address decodedOwner = abi.decode(returnData, (address));
        assertEq(decodedOwner, owner);
    }

    function test_payableCallTransfersETH() public {
        mockToken = new MockToken18();

        uint256 value = 1 ether;
        address target = address(mockToken);
        bytes memory data = "";

        uint256 balanceBefore = target.balance;

        vm.deal(owner, value);
        vm.prank(owner);
        ownableExecutable.execute{value: value}(target, data);

        uint256 balanceAfter = target.balance;
        assertEq(balanceAfter - balanceBefore, value);
    }

    function test_revertsIfCallFails() public {
        vm.prank(owner);
        address target = address(ownableExecutable);
        bytes memory data = ""; // Invalid call

        vm.expectRevert(); // No specific revert reason
        ownableExecutable.execute(target, data);
    }

    function test_revertsIfNotOwner() public {
        address target = address(ownableExecutable);
        bytes memory data = abi.encodeWithSignature("owner()");

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, user));
        ownableExecutable.execute(target, data);
    }

    function test_revertsIfPayableCallFails() public {
        address target = address(ownableExecutable);
        bytes memory data = abi.encodeWithSignature("owner()");
        uint256 value = 1 ether;

        vm.deal(owner, value);
        vm.prank(owner);
        vm.expectRevert(); // Call to owner() is not payable
        ownableExecutable.execute{value: value}(target, data);
    }
}

contract MockOwnerExecutable is MockOwnable, OwnerExecutable {
    function execute(address target, bytes calldata data)
        public
        payable
        override(OwnerExecutable)
        returns (bytes memory result)
    {
        return super.execute(target, data);
    }

    function _beforeAcceptOwner() internal override(MockOwnable, Ownable) {
        super._beforeAcceptOwner();
    }
}
