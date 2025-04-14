// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { RootTest } from "../RootTest.sol";

import { JumpRateUtilizationCurve6, JumpRateUtilizationCurve6Lib } from "src/utilization/types/JumpRateUtilizationCurve6.sol";
import { UFixed6, UFixed6Lib } from "src/number/types/UFixed6.sol";

contract JumpRateUtilizationCurve6Test is RootTest {
    uint256 constant FROM_TIMESTAMP = 1626156000;
    uint256 constant TO_TIMESTAMP = 1626159000;
    UFixed6 NOTIONAL;

    JumpRateUtilizationCurve6 curve1 = JumpRateUtilizationCurve6({
        minRate: UFixed6.wrap(100_000), // 0.1
        maxRate: UFixed6Lib.ONE,
        targetRate: UFixed6.wrap(500_000), // 0.5
        targetUtilization: UFixed6.wrap(800_000) // 0.8
    });

    JumpRateUtilizationCurve6 curve2 = JumpRateUtilizationCurve6({
        minRate: UFixed6Lib.ONE,
        maxRate: UFixed6Lib.ONE,
        targetRate: UFixed6.wrap(500_000), // 0.5
        targetUtilization: UFixed6.wrap(800_000) // 0.8
    });

    JumpRateUtilizationCurve6 curve3 = JumpRateUtilizationCurve6({
        minRate: UFixed6.wrap(500_000), // 0.5
        maxRate: UFixed6.wrap(500_000), // 0.5
        targetRate: UFixed6Lib.ONE,
        targetUtilization: UFixed6.wrap(800_000) // 0.8
    });

    JumpRateUtilizationCurve6 curve4 = JumpRateUtilizationCurve6({
        minRate: UFixed6Lib.ONE,
        maxRate: UFixed6.wrap(100_000), // 0.1
        targetRate: UFixed6.wrap(500_000), // 0.5
        targetUtilization: UFixed6.wrap(800_000) // 0.8
    });

    function setUp() public {
        NOTIONAL = UFixed6Lib.from(500);
    }

    function test_computeCurve1() public view {
        assertUFixed6Eq(
            curve1.compute(UFixed6Lib.ZERO),
            UFixed6.wrap(100_000), // 0.1
            "curve1 returns correct rate at zero"
        );
        assertUFixed6Eq(
            curve1.compute(UFixed6.wrap(400_000)), // 0.4
            UFixed6.wrap(300_000), // 0.3
            "curve1 returns correct rate below target"
        );
        assertUFixed6Eq(
            curve1.compute(UFixed6.wrap(800_000)), // 0.8
            UFixed6.wrap(500_000), // 0.5
            "curve1 returns correct rate at target"
        );
        assertUFixed6Eq(
            curve1.compute(UFixed6.wrap(900_000)), // 0.9
            UFixed6.wrap(750_000), // 0.75
            "curve1 returns correct rate above target"
        );
        assertUFixed6Eq(
            curve1.compute(UFixed6Lib.ONE),
            UFixed6Lib.from(1),
            "curve1 returns correct rate at max"
        );
        assertUFixed6Eq(
            curve1.compute(UFixed6.wrap(1_100000)), // 1.1
            UFixed6Lib.from(1),
            "curve1 returns correct rate above max"
        );
    }

    function test_computeCurve2() public view {
        assertUFixed6Eq(
            curve2.compute(UFixed6Lib.ZERO),
            UFixed6Lib.from(1),
            "curve2 returns correct rate at zero"
        );
        assertUFixed6Eq(
            curve2.compute(UFixed6.wrap(400_000)), // 0.4
            UFixed6.wrap(750_000), // 0.75
            "curve2 returns correct rate below target"
        );
        assertUFixed6Eq(
            curve2.compute(UFixed6.wrap(800_000)), // 0.8
            UFixed6.wrap(500_000), // 0.5
            "curve2 returns correct rate at target"
        );
        assertUFixed6Eq(
            curve2.compute(UFixed6.wrap(900_000)), // 0.9
            UFixed6.wrap(750_000), // 0.75
            "curve2 returns correct rate above target"
        );
        assertUFixed6Eq(
            curve2.compute(UFixed6Lib.ONE),
            UFixed6Lib.ONE,
            "curve2 returns correct rate at max"
        );
        assertUFixed6Eq(
            curve2.compute(UFixed6.wrap(1_100000)), // 1.1
            UFixed6Lib.ONE,
            "curve2 returns correct rate above max"
        );
    }

    function test_computeCurve3() public view {
        assertUFixed6Eq(
            curve3.compute(UFixed6Lib.ZERO),
            UFixed6.wrap(500_000), // 0.5
            "curve3 returns correct rate at zero"
        );
        assertUFixed6Eq(
            curve3.compute(UFixed6.wrap(400_000)), // 0.4
            UFixed6.wrap(750_000), // 0.75
            "curve3 returns correct rate below target"
        );
        assertUFixed6Eq(
            curve3.compute(UFixed6.wrap(800_000)), // 0.8
            UFixed6Lib.ONE,
            "curve3 returns correct rate at target"
        );
        assertUFixed6Eq(
            curve3.compute(UFixed6.wrap(900_000)), // 0.9
            UFixed6.wrap(750_000), // 0.75
            "curve3 returns correct rate above target"
        );
        assertUFixed6Eq(
            curve3.compute(UFixed6Lib.ONE),
            UFixed6.wrap(500_000), // 0.5
            "curve3 returns correct rate at max"
        );
        assertUFixed6Eq(
            curve3.compute(UFixed6.wrap(1_100000)), // 1.1
            UFixed6.wrap(500_000), // 0.5
            "curve3 returns correct rate above max"
        );
    }

    function test_computeCurve4() public view {
        assertUFixed6Eq(
            curve4.compute(UFixed6Lib.ZERO),
            UFixed6Lib.ONE,
            "curve4 returns correct rate at zero"
        );
        assertUFixed6Eq(
            curve4.compute(UFixed6.wrap(400_000)), // 0.4
            UFixed6.wrap(750_000), // 0.75
            "curve4 returns correct rate below target"
        );
        assertUFixed6Eq(
            curve4.compute(UFixed6.wrap(800_000)), // 0.8
            UFixed6.wrap(500_000), // 0.5
            "curve4 returns correct rate at target"
        );
        assertUFixed6Eq(
            curve4.compute(UFixed6.wrap(900_000)), // 0.9
            UFixed6.wrap(300_000), // 0.30
            "curve4 returns correct rate above target"
        );
        assertUFixed6Eq(
            curve4.compute(UFixed6Lib.ONE),
            UFixed6.wrap(100_000), // 0.1
            "curve4 returns correct rate at max"
        );
        assertUFixed6Eq(
            curve4.compute(UFixed6.wrap(1_100000)), // 1.1
            UFixed6.wrap(100_000), // 0.1
            "curve4 returns correct rate above max"
        );
    }

    function test_accumulateCurve1() public view {
        assertUFixed6Eq(
            curve1.accumulate(UFixed6Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(4756), // 0.004756
            "curve1 returns correct accumulation at zero utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(400_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(14269), // 0.014269
            "curve1 returns correct accumulation below target utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(800_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(23782), // 0.023782
            "curve1 returns correct accumulation at target utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(900_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(35673), // 0.035673
            "curve1 returns correct accumulation above target utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(47564), // 0.047564
            "curve1 returns correct accumulation at max utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(47564), // 0.047564
            "curve1 returns correct accumulation above max utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed6Lib.ZERO,
            "curve1 returns correct accumulation at zero time elapsed"
        );
    }

    function test_accumulateCurve2() public view {
        assertUFixed6Eq(
            curve2.accumulate(UFixed6Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(47564), // 0.047564
            "curve2 returns correct accumulation at zero utilization"
        );
        assertUFixed6Eq(
            curve2.accumulate(UFixed6.wrap(400_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(35673), // 0.035673
            "curve2 returns correct accumulation below target utilization"
        );
        assertUFixed6Eq(
            curve2.accumulate(UFixed6.wrap(800_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(23782), // 0.023782
            "curve2 returns correct accumulation at target utilization"
        );
        assertUFixed6Eq(
            curve2.accumulate(UFixed6.wrap(900_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(35673), // 0.035673
            "curve2 returns correct accumulation above target utilization"
        );
        assertUFixed6Eq(
            curve2.accumulate(UFixed6Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(47564), // 0.047564
            "curve2 returns correct accumulation at max utilization"
        );
        assertUFixed6Eq(
            curve2.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(47564), // 0.047564
            "curve2 returns correct accumulation above max utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed6Lib.ZERO,
            "curve1 returns correct accumulation at zero time elapsed"
        );
    }

    function test_accumulateCurve3() public view {
        assertUFixed6Eq(
            curve3.accumulate(UFixed6Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(23782), // 0.023782
            "curve3 returns correct accumulation at zero utilization"
        );
        assertUFixed6Eq(
            curve3.accumulate(UFixed6.wrap(400_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(35673), // 0.035673
            "curve3 returns correct accumulation below target utilization"
        );
        assertUFixed6Eq(
            curve3.accumulate(UFixed6.wrap(800_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(47564), // 0.047564
            "curve3 returns correct accumulation at target utilization"
        );
        assertUFixed6Eq(
            curve3.accumulate(UFixed6.wrap(900_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(35673), // 0.035673
            "curve3 returns correct accumulation above target utilization"
        );
        assertUFixed6Eq(
            curve3.accumulate(UFixed6Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(23782), // 0.023782
            "curve3 returns correct accumulation at max utilization"
        );
        assertUFixed6Eq(
            curve3.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(23782), // 0.023782
            "curve3 returns correct accumulation above max utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed6Lib.ZERO,
            "curve1 returns correct accumulation at zero time elapsed"
        );
    }

    function test_accumulateCurve4() public view {
        assertUFixed6Eq(
            curve4.accumulate(UFixed6Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(47564), // 0.047564
            "curve4 returns correct accumulation at zero utilization"
        );
        assertUFixed6Eq(
            curve4.accumulate(UFixed6.wrap(400_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(35673), // 0.035673
            "curve4 returns correct accumulation below target utilization"
        );
        assertUFixed6Eq(
            curve4.accumulate(UFixed6.wrap(800_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(23782), // 0.023782
            "curve4 returns correct accumulation at target utilization"
        );
        assertUFixed6Eq(
            curve4.accumulate(UFixed6.wrap(900_000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(14269), // 0.014269
            "curve4 returns correct accumulation above target utilization"
        );
        assertUFixed6Eq(
            curve4.accumulate(UFixed6Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(4756), // 0.004756
            "curve4 returns correct accumulation at max utilization"
        );
        assertUFixed6Eq(
            curve4.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed6.wrap(4756), // 0.004756
            "curve4 returns correct accumulation above max utilization"
        );
        assertUFixed6Eq(
            curve1.accumulate(UFixed6.wrap(1_100000), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed6Lib.ZERO,
            "curve1 returns correct accumulation at zero time elapsed"
        );
    }
}
