// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a minting capability for testing purposes.
 * This contract allows anyone to mint tokens, which is useful for testing but should
 * never be used in production.
 */
contract ERC20Mintable is ERC20 {
    /**
     * @dev Initializes the token with a name and symbol.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    /**
     * @dev Creates `amount` new tokens and assigns them to `account`.
     *
     * @param account The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
