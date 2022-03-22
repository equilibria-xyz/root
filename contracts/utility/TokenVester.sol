// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (finance/VestingWallet.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/finance/VestingWallet.sol"
import "../token/ERC20/utils/SafeERC20.sol";
import "../utils/Address.sol";
import "../utils/Context.sol";
import "../utils/math/Math.sol";
import "../types/Token.sol";
import "../types/Token.sol";

/**
 * @title VestingWallet
 * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens
 * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.
 * The vesting schedule is customizable through the {vestedAmount} function.
 *
 * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 */
contract TokenVester is VestingWallet {

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(address beneficiaryAddress, uint64 startTimestamp, uint64 durationSeconds)
    VestingWallet(beneficiaryAddress, startTimestamp, durationSeconds)
    { }

    /**
     * @dev Amount of eth already released
     */
    function released(Token token) public view virtual override returns (uint256) {
        return token.isEther() ? VestingWallet.released() : VestingWallet.released(Token.unwrap(token));
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {TokensReleased} event.
     */
    function release(Token token) public virtual override {
        return token.isEther() ? VestingWallet.release() : VestingWallet.release(Token.unwrap(token));
    }

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(Token token, uint64 timestamp) public view virtual returns (uint256) {
        return token.isEther() ? VestingWallet.vestedAmount() : VestingWallet.vestedAmount(Token.unwrap(token));
    }
}
