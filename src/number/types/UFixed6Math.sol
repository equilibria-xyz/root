// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import { Math, NumberMath } from "../NumberMath.sol";
import { UFixed6, UFixed6Lib } from "./UFixed6.sol";
import { Fixed6, Fixed6Lib } from "./Fixed6.sol";
import { UFixed18 } from "./UFixed18.sol";

/**
    * @notice Returns whether the unsigned fixed-decimal is equal to zero.
    * @param a Unsigned fixed-decimal
    * @return Whether the unsigned fixed-decimal is zero.
    */
function isZero(UFixed6 a) pure returns (bool) {
    return UFixed6.unwrap(a) == 0;
}

/**
    * @notice Adds two unsigned fixed-decimals `a` and `b` together
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Resulting summed unsigned fixed-decimal
    */
function add(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(UFixed6.unwrap(a) + UFixed6.unwrap(b));
}

/**
    * @notice Subtracts unsigned fixed-decimal `b` from `a`
    * @param a Unsigned fixed-decimal to subtract from
    * @param b Unsigned fixed-decimal to subtract
    * @return Resulting subtracted unsigned fixed-decimal
    */
function sub(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(UFixed6.unwrap(a) - UFixed6.unwrap(b));
}

/**
    * @notice Subtracts unsigned fixed-decimal `a` by `b`
    * @dev Does not revert on underflow, instead returns `ZERO`
    * @param a Unsigned fixed-decimal to subtract from
    * @param b Unsigned fixed-decimal to subtract
    * @return Resulting subtracted unsigned fixed-decimal
    */
function unsafeSub(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return gt(b, a) ? UFixed6Lib.ZERO : sub(a, b);
}

/**
    * @notice Multiplies two unsigned fixed-decimals `a` and `b` together
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Resulting multiplied unsigned fixed-decimal
    */
function mul(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(UFixed6.unwrap(a) * UFixed6.unwrap(b) / UFixed6Lib.BASE);
}

/**
    * @notice Multiplies two unsigned fixed-decimals `a` and `b` together, rounding the result up to the next integer if there is a remainder
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Resulting multiplied unsigned fixed-decimal
    */
function mulOut(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(NumberMath.divOut(UFixed6.unwrap(a) * UFixed6.unwrap(b), UFixed6Lib.BASE));
}

/**
    * @notice Divides unsigned fixed-decimal `a` by `b`
    * @param a Unsigned fixed-decimal to divide
    * @param b Unsigned fixed-decimal to divide by
    * @return Resulting divided unsigned fixed-decimal
    */
function div(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(UFixed6.unwrap(a) * UFixed6Lib.BASE / UFixed6.unwrap(b));
}

/**
    * @notice Divides unsigned fixed-decimal `a` by `b`, rounding the result up to the next integer if there is a remainder
    * @param a Unsigned fixed-decimal to divide
    * @param b Unsigned fixed-decimal to divide by
    * @return Resulting divided unsigned fixed-decimal
    */
function divOut(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(NumberMath.divOut(UFixed6.unwrap(a) * UFixed6Lib.BASE, UFixed6.unwrap(b)));
}

/**
    * @notice Divides unsigned fixed-decimal `a` by `b`
    * @dev Does not revert on divide-by-0, instead returns `ONE` for `0/0` and `MAX` for `n/0`.
    * @param a Unsigned fixed-decimal to divide
    * @param b Unsigned fixed-decimal to divide by
    * @return Resulting divided unsigned fixed-decimal
    */
function unsafeDiv(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    if (isZero(b)) {
        return isZero(a) ? UFixed6Lib.ONE : UFixed6Lib.MAX;
    } else {
        return div(a, b);
    }
}

/**
    * @notice Divides unsigned fixed-decimal `a` by `b`, rounding the result up to the next integer if there is a remainder
    * @dev Does not revert on divide-by-0, instead returns `ONE` for `0/0` and `MAX` for `n/0`.
    * @param a Unsigned fixed-decimal to divide
    * @param b Unsigned fixed-decimal to divide by
    * @return Resulting divided unsigned fixed-decimal
    */
function unsafeDivOut(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    if (isZero(b)) {
        return isZero(a) ? UFixed6Lib.ONE : UFixed6Lib.MAX;
    } else {
        return divOut(a, b);
    }
}

/**
    * @notice Computes a * b / c without loss of precision due to BASE conversion
    * @param a First unsigned fixed-decimal
    * @param b Unsigned number to multiply by
    * @param c Unsigned number to divide by
    * @return Resulting computation
    */
function muldiv(UFixed6 a, uint256 b, uint256 c) pure returns (UFixed6) {
    return muldivFixed(a, UFixed6.wrap(b), UFixed6.wrap(c));
}

/**
    * @notice Computes a * b / c without loss of precision due to BASE conversion, rounding the result up to the next integer if there is a remainder
    * @param a First unsigned fixed-decimal
    * @param b Unsigned number to multiply by
    * @param c Unsigned number to divide by
    * @return Resulting computation
    */
function muldivOut(UFixed6 a, uint256 b, uint256 c) pure returns (UFixed6) {
    return muldivOutFixed(a, UFixed6.wrap(b), UFixed6.wrap(c));
}


/**
    * @notice Computes a * b / c without loss of precision due to BASE conversion
    * @param a First unsigned fixed-decimal
    * @param b Unsigned fixed-decimal to multiply by
    * @param c Unsigned fixed-decimal to divide by
    * @return Resulting computation
    */
function muldivFixed(UFixed6 a, UFixed6 b, UFixed6 c) pure returns (UFixed6) {
    return UFixed6.wrap(UFixed6.unwrap(a) * UFixed6.unwrap(b) / UFixed6.unwrap(c));
}

/**
    * @notice Computes a * b / c without loss of precision due to BASE conversion, rounding the result up to the next integer if there is a remainder
    * @param a First unsigned fixed-decimal
    * @param b Unsigned fixed-decimal to multiply by
    * @param c Unsigned fixed-decimal to divide by
    * @return Resulting computation
    */
function muldivOutFixed(UFixed6 a, UFixed6 b, UFixed6 c) pure returns (UFixed6) {
    return UFixed6.wrap(NumberMath.divOut(UFixed6.unwrap(a) * UFixed6.unwrap(b), UFixed6.unwrap(c)));
}

/**
    * @notice Returns whether unsigned fixed-decimal `a` is equal to `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Whether `a` is equal to `b`
    */
function eq(UFixed6 a, UFixed6 b) pure returns (bool) {
    return compare(a, b) == 1;
}

/**
    * @notice Returns whether unsigned fixed-decimal `a` is not equal to `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Whether `a` is not equal to `b`
    */
function neq(UFixed6 a, UFixed6 b) pure returns (bool) {
    return compare(a, b) != 1;
}

/**
    * @notice Returns whether unsigned fixed-decimal `a` is greater than `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Whether `a` is greater than `b`
    */
function gt(UFixed6 a, UFixed6 b) pure returns (bool) {
    return compare(a, b) == 2;
}

/**
    * @notice Returns whether unsigned fixed-decimal `a` is less than `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Whether `a` is less than `b`
    */
function lt(UFixed6 a, UFixed6 b) pure returns (bool) {
    return compare(a, b) == 0;
}

/**
    * @notice Returns whether unsigned fixed-decimal `a` is greater than or equal to `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Whether `a` is greater than or equal to `b`
    */
function gte(UFixed6 a, UFixed6 b) pure returns (bool) {
    return gt(a, b) || eq(a, b);
}

/**
    * @notice Returns whether unsigned fixed-decimal `a` is less than or equal to `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Whether `a` is less than or equal to `b`
    */
function lte(UFixed6 a, UFixed6 b) pure returns (bool) {
    return lt(a, b) || eq(a, b);
}

/**
    * @notice Compares the unsigned fixed-decimals `a` and `b`
    * @dev Returns: 2 for greater than
    *               1 for equal to
    *               0 for less than
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Compare result of `a` and `b`
    */
function compare(UFixed6 a, UFixed6 b) pure returns (uint256) {
    (uint256 au, uint256 bu) = (UFixed6.unwrap(a), UFixed6.unwrap(b));
    if (au > bu) return 2;
    if (au < bu) return 0;
    return 1;
}

/**
    * @notice Returns the minimum of unsigned fixed-decimals `a` and `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Minimum of `a` and `b`
    */
function min(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(Math.min(UFixed6.unwrap(a), UFixed6.unwrap(b)));
}

/**
    * @notice Returns the maximum of unsigned fixed-decimals `a` and `b`
    * @param a First unsigned fixed-decimal
    * @param b Second unsigned fixed-decimal
    * @return Maximum of `a` and `b`
    */
function max(UFixed6 a, UFixed6 b) pure returns (UFixed6) {
    return UFixed6.wrap(Math.max(UFixed6.unwrap(a), UFixed6.unwrap(b)));
}

/**
    * @notice Converts the unsigned fixed-decimal into an integer, truncating any decimal portion
    * @param a Unsigned fixed-decimal
    * @return Truncated unsigned number
    */
function truncate(UFixed6 a) pure returns (uint256) {
    return UFixed6.unwrap(a) / UFixed6Lib.BASE;
}

/**
    * @notice Returns whether the unsigned fixed-decimal `value` is inside the range `min` and `max`
    * @param value Unsigned fixed-decimal to check
    * @param min_ Minimum value
    * @param max_ Maximum value
    * @return Whether `value` is inside the range `min` and `max`
    */
function inside(UFixed6 value, UFixed6 min_, UFixed6 max_) pure returns (bool) {
    return !outside(value, min_, max_);
}

/**
    * @notice Returns whether the unsigned fixed-decimal `value` is outside the range `min` and `max`
    * @param value Unsigned fixed-decimal to check
    * @param min_ Minimum value
    * @param max_ Maximum value
    * @return Whether `value` is outside the range `min` and `max`
    */
function outside(UFixed6 value, UFixed6 min_, UFixed6 max_) pure returns (bool) {
    return lt(value, min_) || gt(value, max_);
}