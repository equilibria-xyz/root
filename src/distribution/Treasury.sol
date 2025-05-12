// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Token, TokenLib } from "../token/types/Token.sol";
import { Ownable } from "../attribute/Ownable.sol";
import { ITreasury } from "./interfaces/ITreasury.sol";
import { Immutable } from "../mutability/Immutable.sol";

contract Treasury is ITreasury, Immutable, Ownable {
    constructor() {
        __Ownable__constructor();
    }

    /// @inheritdoc ITreasury
    function credit(Token token, address spender, uint256 creditAmount) external onlyOwner {
        uint256 currentAllowance = IERC20(Token.unwrap(token)).allowance(address(this), spender);
        token.approve(spender, currentAllowance + creditAmount);
    }

    /// @inheritdoc ITreasury
    function debit(Token token, address spender, uint256 debitAmount) external onlyOwner {
        uint256 currentAllowance = IERC20(Token.unwrap(token)).allowance(address(this), spender);
        uint256 newAllowance = currentAllowance > debitAmount ? currentAllowance - debitAmount : 0;
        token.approve(spender, newAllowance);
    }

    /// @inheritdoc ITreasury
    function reset(Token token, address spender) external onlyOwner {
        token.approve(spender, 0);
    }

    /// @inheritdoc ITreasury
    function pull(Token token, address benefactor, uint256 amount) external {
        token.pull(benefactor, amount);
    }
}
