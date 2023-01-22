// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/UFixed6.sol";

contract MockUFixed6 {
    function ZERO() external pure returns (UFixed6) {
        return UFixed6Lib.ZERO;
    }

    function ONE() external pure returns (UFixed6) {
        return UFixed6Lib.ONE;
    }

    function MAX() external pure returns (UFixed6) {
        return UFixed6Lib.MAX;
    }

    function from(Fixed6 a) external pure returns (UFixed6) {
        return UFixed6Lib.from(a);
    }

    function from(uint256 a) external pure returns (UFixed6) {
        return UFixed6Lib.from(a);
    }

    function fromBase18(UFixed18 a) external pure returns (UFixed6) {
        return UFixed6Lib.from(a);
    }

    function fromBase18(UFixed18 a, bool roundOut) external pure returns (UFixed6) {
        return UFixed6Lib.from(a, roundOut);
    }

    function isZero(UFixed6 a) external pure returns (bool) {
        return UFixed6Lib.isZero(a);
    }

    function add(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.add(a, b);
    }

    function sub(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.sub(a, b);
    }

    function mul(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.mul(a, b);
    }

    function mulOut(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.mulOut(a, b);
    }

    function div(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.div(a, b);
    }

    function divOut(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.divOut(a, b);
    }

    function unsafeDiv(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.unsafeDiv(a, b);
    }

    function unsafeDivOut(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.unsafeDivOut(a, b);
    }

    function muldiv1(UFixed6 a, uint256 b, uint256 c) external pure returns (UFixed6) {
        return UFixed6Lib.muldiv(a, b, c);
    }

    function muldivOut1(UFixed6 a, uint256 b, uint256 c) external pure returns (UFixed6) {
        return UFixed6Lib.muldivOut(a, b, c);
    }

    function muldiv2(UFixed6 a, UFixed6 b, UFixed6 c) external pure returns (UFixed6) {
        return UFixed6Lib.muldiv(a, b, c);
    }

    function muldivOut2(UFixed6 a, UFixed6 b, UFixed6 c) external pure returns (UFixed6) {
        return UFixed6Lib.muldivOut(a, b, c);
    }

    function eq(UFixed6 a, UFixed6 b) external pure returns (bool) {
        return UFixed6Lib.eq(a, b);
    }

    function gt(UFixed6 a, UFixed6 b) external pure returns (bool) {
        return UFixed6Lib.gt(a, b);
    }

    function lt(UFixed6 a, UFixed6 b) external pure returns (bool) {
        return UFixed6Lib.lt(a, b);
    }

    function gte(UFixed6 a, UFixed6 b) external pure returns (bool) {
        return UFixed6Lib.gte(a, b);
    }

    function lte(UFixed6 a, UFixed6 b) external pure returns (bool) {
        return UFixed6Lib.lte(a, b);
    }

    function compare(UFixed6 a, UFixed6 b) external pure returns (uint256) {
        return UFixed6Lib.compare(a, b);
    }

    function ratio(uint256 a, uint256 b) external pure returns (UFixed6) {
        return UFixed6Lib.ratio(a, b);
    }

    function min(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.min(a, b);
    }

    function max(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return UFixed6Lib.max(a, b);
    }

    function truncate(UFixed6 a) external pure returns (uint256) {
        return UFixed6Lib.truncate(a);
    }

    function read(UFixed6Storage slot) external view returns (UFixed6) {
        return slot.read();
    }

    function store(UFixed6Storage slot, UFixed6 value) external {
        slot.store(value);
    }
}
