// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/UFixed18.sol";
import "../number/types/UFixed6.sol";

contract MockUFixed18 {
    function ZERO() external pure returns (UFixed18) {
        return UFixed18Lib.ZERO;
    }

    function ONE() external pure returns (UFixed18) {
        return UFixed18Lib.ONE;
    }

    function MAX() external pure returns (UFixed18) {
        return UFixed18Lib.MAX;
    }

    function from(Fixed18 a) external pure returns (UFixed18) {
        return UFixed18Lib.from(a);
    }

    function from(uint256 a) external pure returns (UFixed18) {
        return UFixed18Lib.from(a);
    }

    function fromUFixed6(UFixed6 a) external pure returns (UFixed18) {
        return UFixed18Lib.from(a);
    }

    function pack(UFixed18 a) external pure returns (PackedUFixed18) {
        return UFixed18Lib.pack(a);
    }

    function isZero(UFixed18 a) external pure returns (bool) {
        return UFixed18Lib.isZero(a);
    }

    function add(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.add(a, b);
    }

    function sub(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.sub(a, b);
    }

    function mul(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.mul(a, b);
    }

    function mulOut(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.mulOut(a, b);
    }

    function div(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.div(a, b);
    }

    function divOut(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.divOut(a, b);
    }

    function unsafeDiv(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.unsafeDiv(a, b);
    }

    function unsafeDivOut(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.unsafeDivOut(a, b);
    }

    function muldiv1(UFixed18 a, uint256 b, uint256 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldiv(a, b, c);
    }

    function muldivOut1(UFixed18 a, uint256 b, uint256 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldivOut(a, b, c);
    }

    function muldiv2(UFixed18 a, UFixed18 b, UFixed18 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldiv(a, b, c);
    }

    function muldivOut2(UFixed18 a, UFixed18 b, UFixed18 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldivOut(a, b, c);
    }

    function eq(UFixed18 a, UFixed18 b) external pure returns (bool) {
        return UFixed18Lib.eq(a, b);
    }

    function gt(UFixed18 a, UFixed18 b) external pure returns (bool) {
        return UFixed18Lib.gt(a, b);
    }

    function lt(UFixed18 a, UFixed18 b) external pure returns (bool) {
        return UFixed18Lib.lt(a, b);
    }

    function gte(UFixed18 a, UFixed18 b) external pure returns (bool) {
        return UFixed18Lib.gte(a, b);
    }

    function lte(UFixed18 a, UFixed18 b) external pure returns (bool) {
        return UFixed18Lib.lte(a, b);
    }

    function compare(UFixed18 a, UFixed18 b) external pure returns (uint256) {
        return UFixed18Lib.compare(a, b);
    }

    function ratio(uint256 a, uint256 b) external pure returns (UFixed18) {
        return UFixed18Lib.ratio(a, b);
    }

    function min(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.min(a, b);
    }

    function max(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.max(a, b);
    }

    function truncate(UFixed18 a) external pure returns (uint256) {
        return UFixed18Lib.truncate(a);
    }

    function read(UFixed18Storage slot) external view returns (UFixed18) {
        return slot.read();
    }

    function store(UFixed18Storage slot, UFixed18 value) external {
        slot.store(value);
    }
}
