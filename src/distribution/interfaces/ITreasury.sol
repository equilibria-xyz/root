// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Token } from "../../token/types/Token.sol";

interface ITreasury {
    function initialize() external;

    /// @notice Increases the approval for `spender` by `amount`
    /// @param token Token to increase approval for
    /// @param spender Address to increase approval for
    /// @param creditAmount Amount to increase approval by
    function credit(Token token, address spender, uint256 creditAmount) external;

    /// @notice Decreases the approval for `spender` by `amount`
    /// @param token Token to decrease approval for
    /// @param spender Address to decrease approval for
    /// @param debitAmount Amount to decrease approval by
    function debit(Token token, address spender, uint256 debitAmount) external;

    /// @notice Sets the approval for `spender` to zero
    /// @param token Token to reset approval for
    /// @param spender Address to reset approval for
    function reset(Token token, address spender) external;

    /// @notice Pulls ERC20 tokens from the benefactor to the treasury
    /// @param token The address of the ERC20 token contract.
    /// @param benefactor The address to pull the tokens from.
    /// @param amount The amount of tokens to pull.
    function pull(Token token, address benefactor, uint256 amount) external;
}
