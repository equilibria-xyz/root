// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./AccumulatorValue6.sol";
import "../../number/types/Fixed6.sol";
import "../../number/types/UFixed6.sol";

/// @dev Accumulator6 type
struct Accumulator6 {
    AccumulatorValue6 _value;
    UFixed6 _total;
}
using Accumulator6Lib for Accumulator6 global;

/**
 * @title Accumulator6Lib
 * @notice Library 
 */
library Accumulator6Lib {
    /**
     * Accumulates to current point and returns how much has been accumulated
     * @param self The latest accumulated point
     * @param to The point to accumulate to
     * @return The accumulated value between the two points
     */
    function accumulate(Accumulator6 memory self, AccumulatorValue6 memory to) internal pure returns (Fixed6) {
        return self._value.accumulated(to, self._total);
    }

    /**
     * @notice Increments an accumulator by a given ratio
     * @dev Always rounds down in order to prevent overstating the accumulated value
     * @param self The accumulator to increment
     * @param amount Numerator of the ratio
     */
    function increment(Accumulator6 memory self, Fixed6 amount) internal pure {
        self._value.increment(amount, self._total);
    }

    /**
     * @notice Decrements an accumulator by a given ratio
     * @dev Always rounds down in order to prevent overstating the accumulated value
     * @param self The accumulator to decrement
     * @param amount Numerator of the ratio
     */
    function decrement(Accumulator6 memory self, Fixed6 amount) internal pure {
        self._value.decrement(amount, self._total);
    }

    /**
     * @notice Transfers an amount between two accumulators
     * @param from The accumulator to transfer from
     * @param to The accumulator to transfer to
     * @param amount The amount to transfer
     */
    function transfer(Accumulator6 memory from, Accumulator6 memory to, Fixed6 amount) internal pure {
        transfer(from, to, amount, UFixed6Lib.ZERO);
    }

    /**
     * @notice Transfers an amount between two accumulators with a fee
     * @param from The accumulator to transfer from
     * @param to The accumulator to transfer to
     * @param amount The amount to transfer
     * @param fee The fee percentage to take
     * @return The fee amount taken
     */
    function transfer(
        Accumulator6 memory from,
        Accumulator6 memory to,
        Fixed6 amount,
        UFixed6 fee
    ) internal pure returns (UFixed6) {
        (Fixed6 amountWithoutFee, UFixed6 feeAmount) = _takeFee(amount, fee);

        decrement(from, amount.gt(Fixed6Lib.ZERO) ? amount : amountWithoutFee);
        increment(to, amount.gt(Fixed6Lib.ZERO) ? amountWithoutFee : amount);

        return feeAmount;
    }

    /**
     * @notice Transfers an amount between two accumulators with a fee using a supplementary accumulator
     * @dev The supplementary accumulator bridges the gap between the total's of the two accumulators such that the
     *      magnitude of the delta per share is the same for both accumulators.
     * @param from The accumulator to transfer from
     * @param to The accumulator to transfer to
     * @param supplement The supplementary accumulator to balance the transfer
     * @param amount The amount to transfer
     * @param fee The fee percentage to take
     * @return The fee amount taken
     */
    function transfer(
        Accumulator6 memory from,
        Accumulator6 memory to,
        Accumulator6 memory supplement,
        Fixed6 amount,
        UFixed6 fee
    ) internal pure returns (UFixed6) {
        (Fixed6 amountWithoutFee, UFixed6 feeAmount) = _takeFee(amount, fee);

        UFixed6 major = from._total.max(to._total);
        bool fromIsMajor = from._total.eq(major);

        (Fixed6 fromAmount, Fixed6 toAmount) = (
            (fromIsMajor ? amount : amountWithoutFee).muldiv(Fixed6Lib.from(from._total), Fixed6Lib.from(major)),
            (fromIsMajor ? amountWithoutFee : amount).muldiv(Fixed6Lib.from(to._total), Fixed6Lib.from(major))
        );

        decrement(from, fromAmount);
        increment(to, toAmount);
        increment(supplement, fromAmount.sub(toAmount).sub(Fixed6Lib.from(feeAmount)));

        return feeAmount;
    }

    /// @notice Takes a fee from an amount
    /// @param amount The amount to take the fee from
    /// @param fee The fee percentage to take
    /// @return amountWithoutFee The amount without the fee taken
    /// @return feeAmount The fee amount taken
    function _takeFee(Fixed6 amount, UFixed6 fee) private pure returns (Fixed6 amountWithoutFee, UFixed6 feeAmount) {
        feeAmount = amount.abs().mul(fee);
        amountWithoutFee = Fixed6Lib.from(amount.sign(), amount.abs().sub(feeAmount));
    }
}
