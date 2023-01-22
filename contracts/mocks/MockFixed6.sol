// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/Fixed6.sol";

contract MockFixed6 {
    function ZERO() external pure returns (Fixed6) {
        return Fixed6Lib.ZERO;
    }

    function ONE() external pure returns (Fixed6) {
        return Fixed6Lib.ONE;
    }

    function NEG_ONE() external pure returns (Fixed6) {
        return Fixed6Lib.NEG_ONE;
    }

    function MAX() external pure returns (Fixed6) {
        return Fixed6Lib.MAX;
    }

    function MIN() external pure returns (Fixed6) {
        return Fixed6Lib.MIN;
    }

    function from(UFixed6 a) external pure returns (Fixed6) {
        return Fixed6Lib.from(a);
    }

    function from(int256 s, UFixed6 m) external pure returns (Fixed6) {
        return Fixed6Lib.from(s, m);
    }

    function from(int256 a) external pure returns (Fixed6) {
        return Fixed6Lib.from(a);
    }

    function fromBase18(Fixed18 a) external pure returns (Fixed6) {
        return Fixed6Lib.from(a);
    }

    function fromBase18(Fixed18 a, bool roundOut) external pure returns (Fixed6) {
        return Fixed6Lib.from(a, roundOut);
    }

    function isZero(Fixed6 a) external pure returns (bool) {
        return Fixed6Lib.isZero(a);
    }

    function add(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.add(a, b);
    }

    function sub(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.sub(a, b);
    }

    function mul(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.mul(a, b);
    }

    function mulOut(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.mulOut(a, b);
    }

    function div(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.div(a, b);
    }

    function divOut(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.divOut(a, b);
    }

    function unsafeDiv(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.unsafeDiv(a, b);
    }

    function unsafeDivOut(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.unsafeDivOut(a, b);
    }

    function muldiv1(Fixed6 a, int256 b, int256 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldiv(a, b, c);
    }

    function muldivOut1(Fixed6 a, int256 b, int256 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldivOut(a, b, c);
    }

    function muldiv2(Fixed6 a, Fixed6 b, Fixed6 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldiv(a, b, c);
    }

    function muldivOut2(Fixed6 a, Fixed6 b, Fixed6 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldivOut(a, b, c);
    }

    function eq(Fixed6 a, Fixed6 b) external pure returns (bool) {
        return Fixed6Lib.eq(a, b);
    }

    function gt(Fixed6 a, Fixed6 b) external pure returns (bool) {
        return Fixed6Lib.gt(a, b);
    }

    function lt(Fixed6 a, Fixed6 b) external pure returns (bool) {
        return Fixed6Lib.lt(a, b);
    }

    function gte(Fixed6 a, Fixed6 b) external pure returns (bool) {
        return Fixed6Lib.gte(a, b);
    }

    function lte(Fixed6 a, Fixed6 b) external pure returns (bool) {
        return Fixed6Lib.lte(a, b);
    }

    function compare(Fixed6 a, Fixed6 b) external pure returns (uint256) {
        return Fixed6Lib.compare(a, b);
    }

    function ratio(int256 a, int256 b) external pure returns (Fixed6) {
        return Fixed6Lib.ratio(a, b);
    }

    function min(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.min(a, b);
    }

    function max(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.max(a, b);
    }

    function truncate(Fixed6 a) external pure returns (int256) {
        return Fixed6Lib.truncate(a);
    }

    function sign(Fixed6 a) external pure returns (int256) {
        return Fixed6Lib.sign(a);
    }

    function abs(Fixed6 a) external pure returns (UFixed6) {
        return Fixed6Lib.abs(a);
    }

    function read(Fixed6Storage slot) external view returns (Fixed6) {
        return slot.read();
    }

    function store(Fixed6Storage slot, Fixed6 value) external {
        slot.store(value);
    }
}
