// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../token/types/TokenOrEther18.sol";

contract MockTokenOrEther18 {
    function zero() external pure returns (TokenOrEther18) {
        return TokenOrEther18Lib.ZERO;
    }

    function etherToken() external pure returns (TokenOrEther18) {
        return TokenOrEther18Lib.ETHER;
    }

    function isZero(TokenOrEther18 token) external pure returns (bool) {
        return TokenOrEther18Lib.isZero(token);
    }

    function isEther(TokenOrEther18 token) external pure returns (bool) {
        return TokenOrEther18Lib.isEther(token);
    }

    function eq(TokenOrEther18 a, TokenOrEther18 b) external pure returns (bool) {
        return TokenOrEther18Lib.eq(a, b);
    }

    function approve(TokenOrEther18 self, address grantee) external {
        TokenOrEther18Lib.approve(self, grantee);
    }

    function approve(TokenOrEther18 self, address grantee, UFixed18 amount) external {
        TokenOrEther18Lib.approve(self, grantee, amount);
    }

    function push(TokenOrEther18 self, address recipient) external {
        TokenOrEther18Lib.push(self, recipient);
    }

    function push(TokenOrEther18 self, address recipient, UFixed18 amount) external {
        TokenOrEther18Lib.push(self, recipient, amount);
    }

    function pull(TokenOrEther18 self, address benefactor, UFixed18 amount) external {
        TokenOrEther18Lib.pull(self, benefactor, amount);
    }

    function pullTo(TokenOrEther18 self, address benefactor, address recipient, UFixed18 amount) external {
        TokenOrEther18Lib.pullTo(self, benefactor, recipient, amount);
    }

    function name(TokenOrEther18 self) external view returns (string memory) {
        return TokenOrEther18Lib.name(self);
    }

    function symbol(TokenOrEther18 self) external view returns (string memory) {
        return TokenOrEther18Lib.symbol(self);
    }

    function balanceOf(TokenOrEther18 self) external view returns (UFixed18) {
        return TokenOrEther18Lib.balanceOf(self);
    }

    function balanceOf(TokenOrEther18 self, address account) external view returns (UFixed18) {
        return TokenOrEther18Lib.balanceOf(self, account);
    }

    function read(TokenOrEther18Storage slot) external view returns (TokenOrEther18) {
        return slot.read();
    }

    function store(TokenOrEther18Storage slot, TokenOrEther18 value) external {
        slot.store(value);
    }

    receive() external payable { }
}