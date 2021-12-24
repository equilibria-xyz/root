// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./UFixed18.sol";

/// @dev Token
type Token is address;

/**
 * @title TokenLib
 * @notice Library to manager Ether and ERC20s that is compliant with the fixed-decimal types.
 * @dev Normalizes token operations with Ether operations (using a magic Ether address).
 */
library TokenLib {
    using UFixed18Lib for UFixed18;
    using Address for address;
    using SafeERC20 for IERC20;

    error TokenPullEtherError();

    uint256 private constant BASE = 1e18;
    Token public constant ETHER = Token.wrap(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE));

    /**
     * @notice Returns whether a token is the Ether address
     * @param self Token to check for
     * @return Whether the token is Ether
     */
    function isEther(Token self) internal pure returns (bool) {
        return Token.unwrap(self) == Token.unwrap(ETHER);
    }

    /**
     * @notice Transfers all held tokens from the caller to the `recipient`
     * @param self Token to transfer
     * @param recipient Address to receive the tokens
     */
    function push(Token self, address recipient) internal {
        push(self, recipient, balanceOf(self, address(this)));
    }

    /**
     * @notice Transfers `amount` tokens from the caller to the `recipient`
     * @param self Token to transfer
     * @param recipient Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function push(
        Token self,
        address recipient,
        UFixed18 amount
    ) internal {
        isEther(self)
            ? Address.sendValue(payable(recipient), UFixed18.unwrap(amount))
            : IERC20(Token.unwrap(self)).safeTransfer(recipient, toTokenAmount(self, amount));
    }

    /**
     * @notice Transfers `amount` tokens from the `benefactor` to the caller
     * @dev Reverts if trying to pull Ether
     * @param self Token to transfer
     * @param benefactor Address to transfer tokens from
     * @param amount Amount of tokens to transfer
     */
    function pull(
        Token self,
        address benefactor,
        UFixed18 amount
    ) internal {
        if (isEther(self)) revert TokenPullEtherError();
        IERC20(Token.unwrap(self)).safeTransferFrom(benefactor, address(this), toTokenAmount(self, amount));
    }

    /**
     * @notice Transfers `amount` tokens from the `benefactor` to `recipient`
     * @dev Reverts if trying to pull Ether
     * @param self Token to transfer
     * @param benefactor Address to transfer tokens from
     * @param recipient Address to transfer tokens to
     * @param amount Amount of tokens to transfer
     */
    function pullTo(
        Token self,
        address benefactor,
        address recipient,
        UFixed18 amount
    ) internal {
        if (isEther(self)) revert TokenPullEtherError();
        IERC20(Token.unwrap(self)).safeTransferFrom(benefactor, recipient, toTokenAmount(self, amount));
    }

    /**
     * @notice Returns the name of the token
     * @param self Token to check for
     * @return Token name
     */
    function name(Token self) internal view returns (string memory) {
        return isEther(self) ? "Ether" : IERC20Metadata(Token.unwrap(self)).name();
    }

    /**
     * @notice Returns the symbol of the token
     * @param self Token to check for
     * @return Token symbol
     */
    function symbol(Token self) internal view returns (string memory) {
        return isEther(self) ? "ETH" : IERC20Metadata(Token.unwrap(self)).symbol();
    }

    /**
     * @notice Returns the decimals of the token
     * @param self Token to check for
     * @return Token decimals
     */
    function decimals(Token self) internal view returns (uint8) {
        return isEther(self) ? 18 : IERC20Metadata(Token.unwrap(self)).decimals();
    }

    /**
     * @notice Returns the `self` token balance of the caller
     * @param self Token to check for
     * @return Token balance of the caller
     */
    function balanceOf(Token self) internal view returns (UFixed18) {
        return balanceOf(self, address(this));
    }

    /**
     * @notice Returns the `self` token balance of `account`
     * @param self Token to check for
     * @param account Account to check
     * @return Token balance of the account
     */
    function balanceOf(Token self, address account) internal view returns (UFixed18) {
        return isEther(self) ?
            UFixed18.wrap(account.balance) :
            fromTokenAmount(self, IERC20(Token.unwrap(self)).balanceOf(account));
    }

    /**
     * @notice Converts the unsigned fixed-decimal amount into the token amount according to
     *         it's defined decimals
     * @param self Token to check for
     * @param amount Amount to convert
     * @return Normalized token amount
     */
    function toTokenAmount(Token self, UFixed18 amount) private view returns (uint256) {
        UFixed18 conversion = UFixed18Lib.ratio(10 ** uint256(decimals(self)), BASE);
        return UFixed18.unwrap(amount.mul(conversion));
    }

    /**
     * @notice Converts the token amount into the unsigned fixed-decimal amount according to
     *         it's defined decimals
     * @param self Token to check for
     * @param amount Token amount to convert
     * @return Normalized unsigned fixed-decimal amount
     */
    function fromTokenAmount(Token self, uint256 amount) private view returns (UFixed18) {
        UFixed18 conversion = UFixed18Lib.ratio(BASE, 10 ** uint256(decimals(self)));
        return UFixed18.wrap(amount).mul(conversion);
    }
}