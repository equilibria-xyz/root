// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Ownable.sol";

/**
 * @title OwnerWithdrawable
 * @notice Allows the owner to withdraw ERC20 tokens from the contract
 */
contract OwnerWithdrawable is Ownable {
    /**
     * @notice Withdraws ERC20 tokens from the contract
     * @dev Can only be called by the owner
     * @param token Address of the ERC20 token
     * @param amount Amount of tokens to withdraw
     */
    function withdraw(address token, uint256 amount) public virtual onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }
}
