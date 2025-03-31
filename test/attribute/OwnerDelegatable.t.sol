// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { ERC20, ERC20Permit, ERC20Votes } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { Test } from "forge-std/Test.sol";

import { OwnerDelegatable, Ownable } from "src/attribute/OwnerDelegatable.sol";
import { MockOwnable } from "./Ownable.t.sol";

contract OwnerDelegatableTest is Test {
    // Event must match MockERC20Votes' definition
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    error OwnableNotOwnerError(address owner);

    MockOwnerDelegatable public ownerDelegatable;
    MockERC20Votes public mockToken;

    address public owner;
    address public user;
    address public unrelated;

    function setUp() public {
        owner = makeAddr("owner");
        user = makeAddr("user");
        unrelated = makeAddr("unrelated");

        // Deploy contracts from the owner address
        vm.startPrank(owner);
        ownerDelegatable = new MockOwnerDelegatable();
        ownerDelegatable.__initialize();

        mockToken = new MockERC20Votes();
        mockToken.mint(owner, 1000 ether);
        vm.stopPrank();
    }

    function test_successfulDelegation() public {
        // Expect DelegateChanged event on delegation
        vm.prank(owner);
        vm.expectEmit(true, true, true, false); // indexed fields only
        emit DelegateChanged(address(ownerDelegatable), address(0), user);

        ownerDelegatable.delegate(IVotes(address(mockToken)), user);
    }

    function test_revertsIfNotOwner() public {
        // Attempting delegation from non-owner should revert
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableNotOwnerError.selector, user));
        ownerDelegatable.delegate(IVotes(address(mockToken)), unrelated);
    }
}

contract MockOwnerDelegatable is MockOwnable, OwnerDelegatable {
    function delegate(IVotes token, address delegatee) public override(OwnerDelegatable) {
        super.delegate(token, delegatee);
    }

    function _beforeAcceptOwner() internal override(MockOwnable, Ownable) {
        super._beforeAcceptOwner();
    }
}

contract MockERC20Votes is ERC20Votes {
    constructor() ERC20("Mock ERC20 Votes", "MOCK") ERC20Permit("Mock ERC20 Votes") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
