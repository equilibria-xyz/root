// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { TokenTest } from "./TokenTest.sol";

import {
    Token6,
    Token6Lib,
    Token6Storage,
    Token6StorageLib,
    UFixed6,
    UFixed6Lib
} from "src/token/types/Token6.sol";
import { Fixed6Lib } from "src/number/types/Fixed6.sol";

abstract contract Token6Test is TokenTest {
    Token6 public token;
    MockToken6 public m = new MockToken6();
}

contract Token6UnfundedUserTest is Token6Test {
    function setUp() public {
        super.setUpToken(6, 0);
        token = Token6.wrap(address(erc20));
    }

    function test_zero() public view {
        Token6 zeroToken = Token6.wrap(address(0));
        assertEq(zeroToken.isZero(), true, "zero address");

        Token6 nonZeroToken = Token6.wrap(address(1));
        assertEq(nonZeroToken.isZero(), false, "bogus token address not zero");
        assertEq(token.isZero(), false, "wrapped token address not zero");
    }

    function test_eq() public view {
        assertEq(token.eq(Token6.wrap(address(erc20))), true, "address equality");
        assertEq(token.eq(Token6.wrap(address(2))), false, "address inequality");
    }

    function test_approveSome() public {
        token.approve(user, UFixed6Lib.from(100));
        assertEq(erc20.allowance(address(this), user), 100e6, "approve some");
    }

    function test_approveAll() public {
        token.approve(user);
        assertEq(erc20.allowance(address(this), user), type(uint256).max, "approve all");
    }

    function test_nameAndSymbol() public view {
        assertEq(token.name(), "Test MiNted Token", "name");
        assertEq(token.symbol(), "TMNT", "symbol");
    }

    function test_store() public {
        Token6Storage SLOT = Token6Storage.wrap(keccak256("equilibria.root.Token6.testSlot"));
        Token6StorageLib.store(SLOT, token);
        assertEq(Token6.unwrap(SLOT.read()), address(erc20), "stored and loaded");
    }
}

contract Token6FundedUserTest is Token6Test {
    address public recipient = makeAddr("recipient");

    function setUp() public {
        super.setUpToken(6, 300e6);
        token = Token6.wrap(address(erc20));
        erc20.transfer(user, 160e6);
    }

    function test_push() public {
        vm.prank(user);
        token.push(recipient, UFixed6Lib.from(100));
        assertEq(erc20.balanceOf(recipient), 100e6, "push some from user to recipient");
        // contract has 140, user has 60, recipient has 100

        // contract uses address.this, so cannot push all from user to recipient
        token.push(recipient);
        // recipient should now have 100 + 140
        assertEq(erc20.balanceOf(recipient), 240e6, "push all from contract to recipient");
    }

    function test_pull() public {
        vm.prank(user);
        token.approve(address(this), UFixed6Lib.from(100));

        token.pull(user, UFixed6Lib.from(40));
        // contract should now have 140 + 40
        assertEq(erc20.balanceOf(address(this)), 180e6, "pull some from user to contract");

        token.pullTo(user, recipient, UFixed6Lib.from(60));
        assertEq(erc20.balanceOf(recipient), 60e6, "pull some from user to recipient");
    }

    function test_update() public {
        vm.prank(user);
        token.approve(address(this), UFixed6Lib.from(100));

        // transfer from user to contract
        token.update(user, Fixed6Lib.from(100));
        // contract should now have 140 + 100
        assertEq(erc20.balanceOf(address(this)), 240e6, "contract should have 240");
        assertEq(erc20.balanceOf(user), 60e6, "user should have 60");

        // transfer from contract to user
        token.update(user, Fixed6Lib.from(-100));
        // contract should now have 240 - 100
        assertEq(erc20.balanceOf(address(this)), 140e6, "contract should have 140");
        assertEq(erc20.balanceOf(user), 160e6, "user should have 160");

        // should not revert if amount is 0
        token.update(user, Fixed6Lib.from(0));
        assertEq(erc20.balanceOf(address(this)), 140e6, "contract should have 140");
        assertEq(erc20.balanceOf(user), 160e6, "user should have 160");
    }

    function test_balance() public view {
        assertUFixed6Eq(token.balanceOf(), UFixed6Lib.from(140), "balance of contract");
        assertUFixed6Eq(token.balanceOf(user), UFixed6Lib.from(160), "balance of user");
        assertUFixed6Eq(token.balanceOf(recipient), UFixed6Lib.ZERO, "balance of recipient");
    }

    function test_totalSupply() public view {
        assertUFixed6Eq(token.totalSupply(), UFixed6Lib.from(300), "total supply");
    }
}

contract MockToken6 {
    function approve(Token6 self, address grantee) external {
        Token6Lib.approve(self, grantee);
    }

    function approve(Token6 self, address grantee, UFixed6 amount) external {
        Token6Lib.approve(self, grantee, amount);
    }
}
