// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { RootTest } from "../RootTest.sol";

import { SynBook6 } from "../../src/synbook/types/SynBook6.sol";
import { Fixed6, Fixed6Lib } from "../../src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";

contract SynBook6Test is RootTest {
    SynBook6 curve1 = SynBook6({
        d0: UFixed6.wrap(2000), // 0.002
        d1: UFixed6Lib.ZERO,
        d2: UFixed6.wrap(1000), // 0.001
        d3: UFixed6.wrap(10000), // 0.01
        scale: UFixed6Lib.from(1000)
    });

    function test_computeCurve1ZeroSkewZeroChange() public pure {
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.ZERO, UFixed6Lib.from(123)),
            Fixed6Lib.ZERO,
            "zero skew, zero change"
        );
    }
}