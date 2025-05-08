// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Token, TokenLib } from "../token/types/Token.sol";
import { Ownable } from "../attribute/Ownable.sol";
import { ITreasury } from "./interfaces/ITreasury.sol";

contract Treasury is ITreasury, Ownable {
    function initialize() external initializer(1) {
        __Ownable__initialize();
    }

    /// @inheritdoc ITreasury
    function approve(Token token, address to, uint256 amount) external onlyOwner {
        TokenLib.approve(token, to, amount);
    }

    /// @inheritdoc ITreasury
    function credit(Token token, address spender, uint256 creditAmount) external {
        uint256 currentAllowance = IERC20(Token.unwrap(token)).allowance(address(this), spender);
        token.approve(spender, currentAllowance + creditAmount);
    }

    /// @inheritdoc ITreasury
    function debit(Token token, address spender, uint256 debitAmount) external {
        uint256 currentAllowance = IERC20(Token.unwrap(token)).allowance(address(this), spender);
        uint256 newAllowance = currentAllowance > debitAmount ? currentAllowance - debitAmount : 0;
        token.approve(spender, newAllowance);
    }

    /// @inheritdoc ITreasury
    function reset(Token token, address spender) external {
        token.approve(spender, 0);
    }

    /// @inheritdoc ITreasury
    function pull(Token token, address benefactor, uint256 amount) external {
        TokenLib.pull(token, benefactor, amount);
    }
}
