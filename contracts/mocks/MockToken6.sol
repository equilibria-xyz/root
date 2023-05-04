// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../token/types/Token6.sol";

contract MockToken6 {
    function zero() external pure returns (Token6) {
        return Token6Lib.ZERO;
    }

    function isZero(Token6 token) external pure returns (bool) {
        return Token6Lib.isZero(token);
    }

    function eq(Token6 a, Token6 b) external pure returns (bool) {
        return Token6Lib.eq(a, b);
    }

    function approve(Token6 self, address grantee) external {
        Token6Lib.approve(self, grantee);
    }

    function approve(Token6 self, address grantee, UFixed18 amount) external {
        Token6Lib.approve(self, grantee, amount);
    }

    function approve(Token6 self, address grantee, UFixed18 amount, bool roundUp) external {
        Token6Lib.approve(self, grantee, amount, roundUp);
    }

    function push(Token6 self, address recipient) external {
        Token6Lib.push(self, recipient);
    }

    function push(Token6 self, address recipient, UFixed18 amount) external {
        Token6Lib.push(self, recipient, amount);
    }

    function push(Token6 self, address recipient, UFixed18 amount, bool roundUp) external {
        Token6Lib.push(self, recipient, amount, roundUp);
    }

    function pull(Token6 self, address benefactor, UFixed18 amount) external {
        Token6Lib.pull(self, benefactor, amount);
    }

    function pull(Token6 self, address benefactor, UFixed18 amount, bool roundUp) external {
        Token6Lib.pull(self, benefactor, amount, roundUp);
    }

    function pullTo(Token6 self, address benefactor, address recipient, UFixed18 amount) external {
        Token6Lib.pullTo(self, benefactor, recipient, amount);
    }

    function pullTo(Token6 self, address benefactor, address recipient, UFixed18 amount, bool roundUp) external {
        Token6Lib.pullTo(self, benefactor, recipient, amount, roundUp);
    }

    function name(Token6 self) external view returns (string memory) {
        return Token6Lib.name(self);
    }

    function symbol(Token6 self) external view returns (string memory) {
        return Token6Lib.symbol(self);
    }

    function balanceOf(Token6 self) external view returns (UFixed18) {
        return Token6Lib.balanceOf(self);
    }

    function balanceOf(Token6 self, address account) external view returns (UFixed18) {
        return Token6Lib.balanceOf(self, account);
    }

    function read(Token6Storage slot) external view returns (Token6) {
        return slot.read();
    }

    function store(Token6Storage slot, Token6 value) external {
        slot.store(value);
    }
}
