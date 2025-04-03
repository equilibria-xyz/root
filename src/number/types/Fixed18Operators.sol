// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import { Fixed18, Fixed18Lib } from "./Fixed18.sol";

/**
    * @notice Adds two signed fixed-decimals `a` and `b` together
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Resulting summed signed fixed-decimal
    */
function add(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap(Fixed18.unwrap(a) + Fixed18.unwrap(b));
}

/**
    * @notice Subtracts signed fixed-decimal `b` from `a`
    * @param a Signed fixed-decimal to subtract from
    * @param b Signed fixed-decimal to subtract
    * @return Resulting subtracted signed fixed-decimal
    */
function sub(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap(Fixed18.unwrap(a) - Fixed18.unwrap(b));
}

/**
    * @notice Multiplies two signed fixed-decimals `a` and `b` together
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Resulting multiplied signed fixed-decimal
    */
function mul(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap(Fixed18.unwrap(a) * Fixed18.unwrap(b) / Fixed18Lib.BASE);
}

/**
    * @notice Divides signed fixed-decimal `a` by `b`
    * @param a Signed fixed-decimal to divide
    * @param b Signed fixed-decimal to divide by
    * @return Resulting divided signed fixed-decimal
    */
function div(Fixed18 a, Fixed18 b) pure returns (Fixed18) {
    return Fixed18.wrap(Fixed18.unwrap(a) * Fixed18Lib.BASE / Fixed18.unwrap(b));
}

/**
    * @notice Returns whether signed fixed-decimal `a` is equal to `b`
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Whether `a` is equal to `b`
    */
function eq(Fixed18 a, Fixed18 b) pure returns (bool) {
    return Fixed18Lib.compare(a, b) == 1;
}

/**
    * @notice Returns whether signed fixed-decimal `a` is not equal to `b`
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Whether `a` is not equal to `b`
    */
function neq(Fixed18 a, Fixed18 b) pure returns (bool) {
    return Fixed18Lib.compare(a, b) != 1;
}

/**
    * @notice Returns whether signed fixed-decimal `a` is greater than `b`
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Whether `a` is greater than `b`
    */
function gt(Fixed18 a, Fixed18 b) pure returns (bool) {
    return Fixed18Lib.compare(a, b) == 2;
}

/**
    * @notice Returns whether signed fixed-decimal `a` is less than `b`
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Whether `a` is less than `b`
    */
function lt(Fixed18 a, Fixed18 b) pure returns (bool) {
    return Fixed18Lib.compare(a, b) == 0;
}

/**
    * @notice Returns whether signed fixed-decimal `a` is greater than or equal to `b`
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Whether `a` is greater than or equal to `b`
    */
function gte(Fixed18 a, Fixed18 b) pure returns (bool) {
    return gt(a, b) || eq(a, b);
}

/**
    * @notice Returns whether signed fixed-decimal `a` is less than or equal to `b`
    * @param a First signed fixed-decimal
    * @param b Second signed fixed-decimal
    * @return Whether `a` is less than or equal to `b`
    */
function lte(Fixed18 a, Fixed18 b) pure returns (bool) {
    return lt(a, b) || eq(a, b);
}