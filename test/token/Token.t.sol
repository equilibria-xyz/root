// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Token, TokenLib } from "../../src/token/types/Token.sol";
import { TokenTest } from "./TokenTest.sol";

abstract contract TokenUTest is TokenTest {
    Token public token;
    MockToken public m = new MockToken();
}

contract TokenUnfundedUserTest is TokenUTest {
    function setUp() public {
        super.setUpToken(6, 0);
        token = Token.wrap(address(erc20));
    }

    function test_zero() public view {
        Token zeroToken = Token.wrap(address(0));
        assertEq(zeroToken.isZero(), true, "zero address");

        Token nonZeroToken = Token.wrap(address(1));
        assertEq(nonZeroToken.isZero(), false, "bogus token address not zero");
        assertEq(token.isZero(), false, "wrapped token address not zero");
    }

    function test_eq() public view {
        assertEq(token.eq(Token.wrap(address(erc20))), true, "address equality");
        assertEq(token.eq(Token.wrap(address(2))), false, "address inequality");
    }

    function test_approveSome() public {
        token.approve(user, 100e18);
        assertEq(erc20.allowance(address(this), user), 100e18, "approve some");
    }

    function test_approveAll() public {
        token.approve(user);
        assertEq(erc20.allowance(address(this), user), type(uint256).max, "approve all");
    }

    function test_nameAndSymbol() public view {
        assertEq(token.name(), "Test MiNted Token", "name");
        assertEq(token.symbol(), "TMNT", "symbol");
    }
}

contract TokenFundedUserTest is TokenUTest {
    address public recipient = makeAddr("recipient");

    function setUp() public {
        super.setUpToken(18, 300e18);
        token = Token.wrap(address(erc20));
        erc20.transfer(user, 160e18);
    }

    function test_push() public {
        vm.prank(user);
        token.push(recipient, 100e18);
        assertEq(erc20.balanceOf(recipient), 100e18, "push some from user to recipient");
        // contract has 140, user has 60, recipient has 100

        // contract uses address.this, so cannot push all from user to recipient
        token.push(recipient);
        // recipient should now have 100 + 140
        assertEq(erc20.balanceOf(recipient), 240e18, "push all from contract to recipient");
    }

    function test_pull() public {
        vm.prank(user);
        token.approve(address(this), 100e18);

        token.pull(user, 40e18);
        // contract should now have 140 + 40
        assertEq(erc20.balanceOf(address(this)), 180e18, "pull some from user to contract");

        token.pullTo(user, recipient, 60e18);
        assertEq(erc20.balanceOf(recipient), 60e18, "pull some from user to recipient");
    }

    function test_update() public {
        vm.prank(user);
        token.approve(address(this), 100e18);

        // transfer from user to contract
        token.update(user, 100e18);
        // contract should now have 140 + 100
        assertEq(erc20.balanceOf(address(this)), 240e18, "contract should have 240");
        assertEq(erc20.balanceOf(user), 60e18, "user should have 60");

        // transfer from contract to user
        token.update(user, -100e18);
        // contract should now have 240 - 100
        assertEq(erc20.balanceOf(address(this)), 140e18, "contract should have 140");
        assertEq(erc20.balanceOf(user), 160e18, "user should have 160");

        // should not revert if amount is 0
        token.update(user, 0);
        assertEq(erc20.balanceOf(address(this)), 140e18, "contract should have 140");
        assertEq(erc20.balanceOf(user), 160e18, "user should have 160");
    }

    function test_balance() public view {
        assertEq(token.balanceOf(), 140e18, "balance of contract");
        assertEq(token.balanceOf(user), 160e18, "balance of user");
        assertEq(token.balanceOf(recipient), 0, "balance of recipient");
    }

    function test_totalSupply() public view {
        assertEq(token.totalSupply(), 300e18, "total supply");
    }
}

contract MockToken {
    function approve(Token self, address grantee) external {
        TokenLib.approve(self, grantee);
    }

    function approve(Token self, address grantee, uint256 amount) external {
        TokenLib.approve(self, grantee, amount);
    }
}
