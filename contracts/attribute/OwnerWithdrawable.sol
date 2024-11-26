// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Ownable } from "./Ownable.sol";
import { Token18 } from "../token/types/Token18.sol";

/**
 * @title OwnerWithdrawable
 * @notice Allows the owner to withdraw ERC20 tokens from the contract
 */
abstract contract OwnerWithdrawable is Ownable {
    /**
     * @notice Withdraws all ERC20 tokens from the contract to the owner
     * @dev Can only be called by the owner
     * @param token Address of the ERC20 token
     */
    function withdraw(Token18 token) public virtual onlyOwner {
        token.push(owner(), token.balanceOf(address(this)));
    }
}
