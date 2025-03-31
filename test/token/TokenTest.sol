// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { RootTest } from "../RootTest.sol";

abstract contract TokenTest is RootTest {
    address public user = makeAddr("user");
    ERC20 public erc20;

    /// @dev Creates a new ERC20 token with specified parameters
    /// @param decimals Number of decimals for the token
    /// @param mintAmount Initial supply minted to the test contract
    function setUpToken(uint8 decimals, uint256 mintAmount) public {
        erc20 = new ERC20TestToken("Test MiNted Token", "TMNT", decimals, mintAmount);
    }
}

contract ERC20TestToken is ERC20 {
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _decimals = decimals_;
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
