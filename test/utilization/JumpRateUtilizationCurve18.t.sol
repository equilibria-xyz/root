// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { RootTest } from "../RootTest.sol";

import { JumpRateUtilizationCurve18, JumpRateUtilizationCurve18Lib } from "../../src/utilization/types/JumpRateUtilizationCurve18.sol";
import { UFixed18, UFixed18Lib } from "../../src/number/types/UFixed18.sol";

contract JumpRateUtilizationCurve18Test is RootTest {
    uint256 constant FROM_TIMESTAMP = 1626156000;
    uint256 constant TO_TIMESTAMP = 1626159000;
    UFixed18 NOTIONAL;

    JumpRateUtilizationCurve18 curve1 = JumpRateUtilizationCurve18({
        minRate: UFixed18.wrap(1e17), // 0.1
        maxRate: UFixed18Lib.ONE,
        targetRate: UFixed18.wrap(5e17), // 0.5
        targetUtilization: UFixed18.wrap(8e17) // 0.8
    });

    JumpRateUtilizationCurve18 curve2 = JumpRateUtilizationCurve18({
        minRate: UFixed18Lib.ONE,
        maxRate: UFixed18Lib.ONE,
        targetRate: UFixed18.wrap(5e17), // 0.5
        targetUtilization: UFixed18.wrap(8e17) // 0.8
    });

    JumpRateUtilizationCurve18 curve3 = JumpRateUtilizationCurve18({
        minRate: UFixed18.wrap(5e17), // 0.5
        maxRate: UFixed18.wrap(5e17), // 0.5
        targetRate: UFixed18Lib.ONE,
        targetUtilization: UFixed18.wrap(8e17) // 0.8
    });

    JumpRateUtilizationCurve18 curve4 = JumpRateUtilizationCurve18({
        minRate: UFixed18Lib.ONE,
        maxRate: UFixed18.wrap(1e17), // 0.1
        targetRate: UFixed18.wrap(5e17), // 0.5
        targetUtilization: UFixed18.wrap(8e17) // 0.8
    });

    function setUp() public {
        NOTIONAL = UFixed18Lib.from(500);
    }

    function test_computeCurve1() public view {
        assertUFixed18Eq(
            JumpRateUtilizationCurve18Lib.compute(curve1, UFixed18Lib.ZERO),
            UFixed18.wrap(1e17), // 0.1
            "curve1 returns correct rate at zero"
        );
        assertUFixed18Eq(
            curve1.compute(UFixed18.wrap(4e17)), // 0.4
            UFixed18.wrap(3e17), // 0.3
            "curve1 returns correct rate below target"
        );
        assertUFixed18Eq(
            curve1.compute(UFixed18.wrap(8e17)), // 0.8
            UFixed18.wrap(5e17), // 0.5
            "curve1 returns correct rate at target"
        );
        assertUFixed18Eq(
            curve1.compute(UFixed18.wrap(9e17)), // 0.9
            UFixed18.wrap(75e16), // 0.75
            "curve1 returns correct rate above target"
        );
        assertUFixed18Eq(
            curve1.compute(UFixed18Lib.ONE),
            UFixed18Lib.ONE,
            "curve1 returns correct rate at max"
        );
        assertUFixed18Eq(
            curve1.compute(UFixed18.wrap(11e17)), // 1.1
            UFixed18Lib.ONE,
            "curve1 returns correct rate above max"
        );
    }

    function test_computeCurve2() public view {
        assertUFixed18Eq(
            JumpRateUtilizationCurve18Lib.compute(curve2, UFixed18Lib.ZERO),
            UFixed18Lib.ONE,
            "curve2 returns correct rate at zero"
        );
        assertUFixed18Eq(
            curve2.compute(UFixed18.wrap(4e17)), // 0.4
            UFixed18.wrap(75e16), // 0.75
            "curve2 returns correct rate below target"
        );
        assertUFixed18Eq(
            curve2.compute(UFixed18.wrap(8e17)), // 0.8
            UFixed18.wrap(5e17), // 0.5
            "curve2 returns correct rate at target"
        );
        assertUFixed18Eq(
            curve2.compute(UFixed18.wrap(9e17)), // 0.9
            UFixed18.wrap(75e16), // 0.75
            "curve2 returns correct rate above target"
        );
        assertUFixed18Eq(
            curve2.compute(UFixed18Lib.ONE),
            UFixed18Lib.ONE,
            "curve2 returns correct rate at max"
        );
        assertUFixed18Eq(
            curve2.compute(UFixed18.wrap(11e17)), // 1.1
            UFixed18Lib.ONE,
            "curve2 returns correct rate above max"
        );
    }

    function test_computeCurve3() public view {
        assertUFixed18Eq(
            JumpRateUtilizationCurve18Lib.compute(curve3, UFixed18Lib.ZERO),
            UFixed18.wrap(5e17), // 0.5
            "curve3 returns correct rate at zero"
        );
        assertUFixed18Eq(
            curve3.compute(UFixed18.wrap(4e17)), // 0.4
            UFixed18.wrap(75e16), // 0.75
            "curve3 returns correct rate below target"
        );
        assertUFixed18Eq(
            curve3.compute(UFixed18.wrap(8e17)), // 0.8
            UFixed18Lib.ONE,
            "curve3 returns correct rate at target"
        );
        assertUFixed18Eq(
            curve3.compute(UFixed18.wrap(9e17)), // 0.9
            UFixed18.wrap(75e16), // 0.75
            "curve3 returns correct rate above target"
        );
        assertUFixed18Eq(
            curve3.compute(UFixed18Lib.ONE),
            UFixed18.wrap(5e17), // 0.5
            "curve3 returns correct rate at max"
        );
        assertUFixed18Eq(
            curve3.compute(UFixed18.wrap(11e17)), // 1.1
            UFixed18.wrap(5e17), // 0.5
            "curve3 returns correct rate above max"
        );
    }

    function test_computeCurve4() public view {
        assertUFixed18Eq(
            JumpRateUtilizationCurve18Lib.compute(curve4, UFixed18Lib.ZERO),
            UFixed18Lib.ONE,
            "curve4 returns correct rate at zero"
        );
        assertUFixed18Eq(
            curve4.compute(UFixed18.wrap(4e17)), // 0.4
            UFixed18.wrap(75e16), // 0.75
            "curve4 returns correct rate below target"
        );
        assertUFixed18Eq(
            curve4.compute(UFixed18.wrap(8e17)), // 0.8
            UFixed18.wrap(5e17), // 0.5
            "curve4 returns correct rate at target"
        );
        assertUFixed18Eq(
            curve4.compute(UFixed18.wrap(9e17)), // 0.9
            UFixed18.wrap(3e17), // 0.3
            "curve4 returns correct rate above target"
        );
        assertUFixed18Eq(
            curve4.compute(UFixed18Lib.ONE),
            UFixed18.wrap(1e17), // 0.1
            "curve4 returns correct rate at max"
        );
        assertUFixed18Eq(
            curve4.compute(UFixed18.wrap(11e17)), // 1.1
            UFixed18.wrap(1e17), // 0.1
            "curve4 returns correct rate above max"
        );
    }

    // TODO: confirm results of accumulation tests are appropriate; old tests used 6-decimal inputs

    function test_accumulateCurve1() public view {
        assertUFixed18Eq(
            curve1.accumulate(UFixed18Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(4756468_797564687), // 0.004756468797564687
            "curve1 returns correct accumulation at zero utilization"
        );
        assertUFixed18Eq(
            curve1.accumulate(UFixed18.wrap(4e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(14269406_392694063), // 0.014269406392694063
            "curve1 returns correct accumulation below target utilization"
        );
        assertUFixed18Eq(
            curve1.accumulate(UFixed18.wrap(8e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(23782343_987823439), // 0.023782343987823439
            "curve1 returns correct accumulation at target utilization"
        );
        assertUFixed18Eq(
            curve1.accumulate(UFixed18.wrap(9e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(35673515_981735159), // 0.035673515981735159
            "curve1 returns correct accumulation above target utilization"
        );
        assertUFixed18Eq(
            curve1.accumulate(UFixed18Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(47564687_975646879), // 0.047564687975646879
            "curve1 returns correct accumulation at max utilization"
        );
        assertUFixed18Eq(
            curve1.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(47564687_975646879), // 0.047564687975646879
            "curve1 returns correct accumulation above max utilization"
        );
        assertUFixed18Eq(
            curve1.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed18Lib.ZERO,
            "curve1 returns correct accumulation at zero time elapsed"
        );
    }

    function test_accumulateCurve2() public view {
        assertUFixed18Eq(
            curve2.accumulate(UFixed18Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(47564687_975646879), // 0.047564687975646879
            "curve2 returns correct accumulation at zero utilization"
        );
        assertUFixed18Eq(
            curve2.accumulate(UFixed18.wrap(4e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(35673515_981735159), // 0.035673515981735159
            "curve2 returns correct accumulation below target utilization"
        );
        assertUFixed18Eq(
            curve2.accumulate(UFixed18.wrap(8e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(23782343_987823439), // 0.023782343987823439
            "curve2 returns correct accumulation at target utilization"
        );
        assertUFixed18Eq(
            curve2.accumulate(UFixed18.wrap(9e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(35673515_981735159), // 0.035673515981735159
            "curve2 returns correct accumulation above target utilization"
        );
        assertUFixed18Eq(
            curve2.accumulate(UFixed18Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(47564687_975646879), // 0.047564687975646879
            "curve2 returns correct accumulation at max utilization"
        );
        assertUFixed18Eq(
            curve2.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(47564687_975646879), // 0.047564687975646879
            "curve2 returns correct accumulation above max utilization"
        );
        assertUFixed18Eq(
            curve2.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed18Lib.ZERO,
            "curve2 returns correct accumulation at zero time elapsed"
        );
    }

    function test_accumulateCurve3() public view {
        assertUFixed18Eq(
            curve3.accumulate(UFixed18Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(23782343_987823439), // 0.023782343987823439
            "curve3 returns correct accumulation at zero utilization"
        );
        assertUFixed18Eq(
            curve3.accumulate(UFixed18.wrap(4e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(35673515_981735159), // 0.035673515981735159
            "curve3 returns correct accumulation below target utilization"
        );
        assertUFixed18Eq(
            curve3.accumulate(UFixed18.wrap(8e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(47564687_975646879), // 0.047564687975646879
            "curve3 returns correct accumulation at target utilization"
        );
        assertUFixed18Eq(
            curve3.accumulate(UFixed18.wrap(9e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(35673515_981735159), // 0.035673515981735159
            "curve3 returns correct accumulation above target utilization"
        );
        assertUFixed18Eq(
            curve3.accumulate(UFixed18Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(23782343_987823439), // 0.023782343987823439
            "curve3 returns correct accumulation at max utilization"
        );
        assertUFixed18Eq(
            curve3.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(23782343_987823439), // 0.023782343987823439
            "curve3 returns correct accumulation above max utilization"
        );
        assertUFixed18Eq(
            curve3.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed18Lib.ZERO,
            "curve3 returns correct accumulation at zero time elapsed"
        );
    }

    function test_accumulateCurve4() public view {
        assertUFixed18Eq(
            curve4.accumulate(UFixed18Lib.ZERO, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(47564687_975646879), // 0.047564687975646879
            "curve4 returns correct accumulation at zero utilization"
        );
        assertUFixed18Eq(
            curve4.accumulate(UFixed18.wrap(4e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(35673515_981735159), // 0.035673515981735159
            "curve4 returns correct accumulation below target utilization"
        );
        assertUFixed18Eq(
            curve4.accumulate(UFixed18.wrap(8e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(23782343_987823439), // 0.023782343987823439
            "curve4 returns correct accumulation at target utilization"
        );
        assertUFixed18Eq(
            curve4.accumulate(UFixed18.wrap(9e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(14269406_392694063), // 0.014269406392694063
            "curve4 returns correct accumulation above target utilization"
        );
        assertUFixed18Eq(
            curve4.accumulate(UFixed18Lib.ONE, FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(4756468_797564687), // 0.004756468797564687
            "curve4 returns correct accumulation at max utilization"
        );
        assertUFixed18Eq(
            curve4.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, TO_TIMESTAMP, NOTIONAL),
            UFixed18.wrap(4756468_797564687), // 0.004756468797564687
            "curve4 returns correct accumulation above max utilization"
        );
        assertUFixed18Eq(
            curve4.accumulate(UFixed18.wrap(11e17), FROM_TIMESTAMP, FROM_TIMESTAMP, NOTIONAL),
            UFixed18Lib.ZERO,
            "curve4 returns correct accumulation at zero time elapsed"
        );
    }
}