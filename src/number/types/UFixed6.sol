// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import { Math, NumberMath } from "../NumberMath.sol";
import { Fixed6, Fixed6Lib } from "./Fixed6.sol";
import { UFixed18 } from "./UFixed18.sol";
import "./UFixed6Math.sol" as UFixed6Math;

/// @dev UFixed6 type
type UFixed6 is uint256;
type UFixed6Storage is bytes32;
using UFixed6StorageLib for UFixed6Storage global;

using {
    UFixed6Math.add as +,
    UFixed6Math.sub as -,
    UFixed6Math.mul as *,
    UFixed6Math.div as /,
    UFixed6Math.eq as ==,
    UFixed6Math.neq as !=,
    UFixed6Math.gt as >,
    UFixed6Math.lt as <,
    UFixed6Math.gte as >=,
    UFixed6Math.lte as <=
} for UFixed6 global;

using {
    UFixed6Math.isZero,
    UFixed6Math.add,
    UFixed6Math.sub,
    UFixed6Math.unsafeSub,
    UFixed6Math.mul,
    UFixed6Math.mulOut,
    UFixed6Math.div,
    UFixed6Math.divOut,
    UFixed6Math.unsafeDiv,
    UFixed6Math.unsafeDivOut,
    UFixed6Math.muldiv,
    UFixed6Math.muldivOut,
    UFixed6Math.muldivFixed,
    UFixed6Math.muldivOutFixed,
    UFixed6Math.eq,
    UFixed6Math.neq,
    UFixed6Math.gt,
    UFixed6Math.lt,
    UFixed6Math.gte,
    UFixed6Math.lte,
    UFixed6Math.compare,
    UFixed6Math.min,
    UFixed6Math.max,
    UFixed6Math.truncate,
    UFixed6Math.inside,
    UFixed6Math.outside
} for UFixed6 global;

/**
 * @title UFixed6Lib
 * @notice Library for the unsigned fixed-decimal type.
 */
library UFixed6Lib {
    // sig: 0xb02ef087
    /// @custom:error Arithmetic underflow
    error UFixed6UnderflowError(int256 value);

    uint256 constant BASE = 1e6;
    UFixed6 constant ZERO = UFixed6.wrap(0);
    UFixed6 constant ONE = UFixed6.wrap(BASE);
    UFixed6 constant MAX = UFixed6.wrap(type(uint256).max);

    /**
     * @notice Creates a unsigned fixed-decimal from a signed fixed-decimal
     * @param a Signed fixed-decimal
     * @return New unsigned fixed-decimal
     */
    function from(Fixed6 a) internal pure returns (UFixed6) {
        int256 value = Fixed6.unwrap(a);
        if (value < 0) revert UFixed6UnderflowError(value);
        return UFixed6.wrap(uint256(value));
    }

    /**
     * @notice Creates a unsigned fixed-decimal from a signed fixed-decimal
     * @dev Does not revert on underflow, instead returns `ZERO`
     * @param a Signed fixed-decimal
     * @return New unsigned fixed-decimal
     */
    function unsafeFrom(Fixed6 a) internal pure returns (UFixed6) {
        return a.lt(Fixed6Lib.ZERO) ? ZERO : from(a);
    }

    /**
     * @notice Creates a unsigned fixed-decimal from a unsigned integer
     * @param a Unsigned number
     * @return New unsigned fixed-decimal
     */
    function from(uint256 a) internal pure returns (UFixed6) {
        return UFixed6.wrap(a * BASE);
    }

    /**
     * @notice Creates an unsigned fixed-decimal from a base-18 unsigned fixed-decimal
     * @param a Base-18 unsigned fixed-decimal
     * @return New unsigned fixed-decimal
     */
    function from(UFixed18 a) internal pure returns (UFixed6) {
        return UFixed6.wrap(UFixed18.unwrap(a) / 1e12);
    }

    /**
     * @notice Creates an unsigned fixed-decimal from a base-18 unsigned fixed-decimal
     * @param a Base-18 unsigned fixed-decimal
     * @param roundOut Whether to round the result away from zero if there is a remainder
     * @return New unsigned fixed-decimal
     */
    function from(UFixed18 a, bool roundOut) internal pure returns (UFixed6) {
        return roundOut ? UFixed6.wrap(NumberMath.divOut(UFixed18.unwrap(a), 1e12)): from(a);
    }

    /**
     * @notice Creates an unsigned fixed-decimal from a significand and an exponent
     * @param significand The significand of the number
     * @param exponent The exponent of the number
     * @return New unsigned fixed-decimal
     */
    function from(UFixed6 significand, int256 exponent) internal pure returns (UFixed6) {
        return exponent < 0
            ? significand.div(from(10 ** uint256(-1 * exponent)))
            : significand.mul(from(10 ** uint256(exponent)));
    }

    /**
        * @notice Returns a unsigned fixed-decimal representing the ratio of `a` over `b`
        * @param a First unsigned number
        * @param b Second unsigned number
        * @return Ratio of `a` over `b`
        */
    function ratio(uint256 a, uint256 b) internal pure returns (UFixed6) {
        return UFixed6.wrap(a * UFixed6Lib.BASE / b);
    }
}

library UFixed6StorageLib {
    function read(UFixed6Storage self) internal view returns (UFixed6 value) {
        assembly ("memory-safe") {
            value := sload(self)
        }
    }

    function store(UFixed6Storage self, UFixed6 value) internal {
        assembly ("memory-safe") {
            sstore(self, value)
        }
    }
}
