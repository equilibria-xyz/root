// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

import { RootTest } from "../RootTest.sol";

import {
    Token18,
    Token18Lib,
    Token18Storage,
    Token18StorageLib,
    UFixed18,
    UFixed18Lib
} from "../../src/token/types/Token18.sol";

abstract contract Token18Test is RootTest {
    address public user = makeAddr("user");
    ERC20 public erc20 = new ERC20("Test Token", "TEST");
    Token18 public token = Token18.wrap(address(erc20));
    MockToken18 public m = new MockToken18();
}

contract Token18UnfundedUserTest is Token18Test {
    function test_zero() public view {
        Token18 zeroToken = Token18.wrap(address(0));
        assertEq(zeroToken.isZero(), true, "zero address");

        Token18 nonZeroToken = Token18.wrap(address(1));
        assertEq(nonZeroToken.isZero(), false, "bogus token address not zero");
        assertEq(token.isZero(), false, "wrapped token address not zero");
    }

    function test_eq() public view {
        assertEq(token.eq(Token18.wrap(address(erc20))), true, "address equality");
        assertEq(token.eq(Token18.wrap(address(2))), false, "address inequality");
    }

    function test_approveSome() public {
        token.approve(user, UFixed18Lib.from(100));
        assertEq(erc20.allowance(address(this), user), 100e18, "approve some");
    }

    function test_approveAll() public {
        token.approve(user);
        assertEq(erc20.allowance(address(this), user), type(uint256).max, "approve all");
    }

    function test_revertsApprovingWithPriorAllowance() public {
        m.approve(token, user, UFixed18Lib.from(1));
        vm.expectRevert("SafeERC20: approve from non-zero to non-zero allowance");
        m.approve(token, user, UFixed18Lib.from(100));
    }

    function test_nameAndSymbol() public {
        assertEq(token.name(), "Test Token", "name");
        assertEq(token.symbol(), "TEST", "symbol");
    }

    function test_store() public {
        Token18Storage SLOT = Token18Storage.wrap(keccak256("equilibria.root.Token18.testSlot"));
        Token18StorageLib.store(SLOT, token);
        assertEq(Token18.unwrap(SLOT.read()), address(erc20), "stored and loaded");
    }
}

contract Token18FundedUserTest is Token18Test {
    address public recipient = makeAddr("recipient");

    function setUp() public {
        erc20 = new ERC20PresetFixedSupply("Test Minted Token", "TMNT", 300e18, address(this));
        token = Token18.wrap(address(erc20));
        erc20.transfer(user, 160e18); // send half to user
    }

    function test_push() public {
        vm.startPrank(user);
        token.push(recipient, UFixed18Lib.from(100));
        assertEq(erc20.balanceOf(recipient), 100e18, "push some from user to recipient");
        vm.stopPrank();
        // contract has 140, user has 60, recipient has 100

        // contract uses address.this, so cannot push all from user to recipient
        token.push(recipient);
        // recipient should now have 100 + 140
        assertEq(erc20.balanceOf(recipient), 240e18, "push all from contract to recipient");
    }

    function test_pull() public {
        vm.startPrank(user);
        token.approve(address(this), UFixed18Lib.from(100));
        vm.stopPrank();

        token.pull(user, UFixed18Lib.from(40));
        // contract should now have 140 + 40
        assertEq(erc20.balanceOf(address(this)), 180e18, "pull some from user to contract");

        token.pullTo(user, recipient, UFixed18Lib.from(60));
        assertEq(erc20.balanceOf(recipient), 60e18, "pull some from user to recipient");
    }

    function test_balance() public {
        assertUFixed18Eq(token.balanceOf(), UFixed18Lib.from(140), "balance of contract");
        assertUFixed18Eq(token.balanceOf(user), UFixed18Lib.from(160), "balance of user");
        assertUFixed18Eq(token.balanceOf(recipient), UFixed18Lib.ZERO, "balance of recipient");
    }

    function test_totalSupply() public {
        assertUFixed18Eq(token.totalSupply(), UFixed18Lib.from(300), "total supply");
    }
}

contract MockToken18 {
    function approve(Token18 self, address grantee) external {
        Token18Lib.approve(self, grantee);
    }

    function approve(Token18 self, address grantee, UFixed18 amount) external {
        Token18Lib.approve(self, grantee, amount);
    }
}