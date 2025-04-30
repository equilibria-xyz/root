// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "../attribute/Ownable.sol";

contract Treasury is Ownable {
    using SafeERC20 for IERC20;

    function initialize() external initializer(1) {
        __Ownable__initialize();
    }

    /// @notice Approves the transfer of ERC20 tokens from the escrow to a specified address.
    /// @param token The address of the ERC20 token contract.
    /// @param to The address to approve the tokens for.
    /// @param amount The amount of tokens to approve.
    function approve(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).approve(to, amount);
    }

    /// @notice Deposits ERC20 tokens into the escrow contract.
    /// @param token The address of the ERC20 token contract.
    /// @param amount The amount of tokens to deposit.
    function deposit(address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }
}
