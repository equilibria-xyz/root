// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../types/Token.sol";

contract MockToken {
    function etherToken() external pure returns (Token) {
        return TokenLib.ETHER;
    }

    function isEther(Token token) external pure returns (bool) {
        return TokenLib.isEther(token);
    }

    function push(Token self, address recipient) external {
        TokenLib.push(self, recipient);
    }

    function push(Token self, address recipient, UFixed18 amount) external {
        TokenLib.push(self, recipient, amount);
    }

    function pull(Token self, address benefactor, UFixed18 amount) external {
        TokenLib.pull(self, benefactor, amount);
    }

    function pullTo(Token self, address benefactor, address recipient, UFixed18 amount) external {
        TokenLib.pullTo(self, benefactor, recipient, amount);
    }

    function name(Token self) external view returns (string memory) {
        return TokenLib.name(self);
    }

    function symbol(Token self) external view returns (string memory) {
        return TokenLib.symbol(self);
    }

    function decimals(Token self) external view returns (uint8) {
        return TokenLib.decimals(self);
    }

    function balanceOf(Token self) external view returns (UFixed18) {
        return TokenLib.balanceOf(self);
    }

    function balanceOf(Token self, address account) external view returns (UFixed18) {
        return TokenLib.balanceOf(self, account);
    }

    receive() external payable { }
}