// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { UFixed18, UFixed18Lib } from "../../src/number/types/UFixed18.sol";
import { VRGDADecayMath } from "../../src/vrgda/VRGDADecayMath.sol";
import { VRGDAIssuanceMath } from "../../src/vrgda/VRGDAIssuanceMath.sol";
import { RootTest } from "../RootTest.sol";

contract VRGDAMathTest is RootTest {
    function setUp() public virtual {
        vm.warp(1728000000); // time() -> 20_000 (days)
    }

    function test_time() external {
        assertUFixed18Eq(VRGDADecayMath.time(), UFixed18.wrap(20_000e18), "value mismatch");
        skip(1);
        assertUFixed18Eq(VRGDADecayMath.time(), UFixed18.wrap(20_000_000011574074074074), "value mismatch");
        skip(86399);
        assertUFixed18Eq(VRGDADecayMath.time(), UFixed18.wrap(20_001e18), "value mismatch");
    }

    function test_exponentialDecay_fromto() external {
        skip(8640 * 2); // 0.2 days
        // timestamp = 20_000, lamba = 10, k = 100, T = 0.1 -> 0.15
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.05e18),
                UFixed18.wrap(0.1e18)
            ),
            UFixed18.wrap(289.498562046024984000e18),
            "incorrect result with from and to in past"
        );
        // timestamp = 20_000, lamba = 10, k = 100, T = 0 -> 0.1
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.1e18),
                UFixed18.wrap(0.2e18)
            ),
            UFixed18.wrap(1264.241117657115358000e18),
            "incorrect result with from in past and zero to"
        );
        // timestamp = 20_000, lamba = 10, k = 100, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.2e18),
                UFixed18.wrap(0.3e18)
            ),
            UFixed18.wrap(3436.563656918090468000e18),
            "incorrect result with zero from and to in future"
        );
        // timestamp = 20_000, lamba = 10, k = 100, T = -0.15 -> -0.1
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.3e18),
                UFixed18.wrap(0.35e18)
            ),
            UFixed18.wrap(3526.814483758039168000e18),
            "incorrect result with from and to in future"
        );
    }

    function test_exponentialDecay_decay() external view {
        // timestamp = 20_000, lamba = 1, k = 100, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(1e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(0.1e18)
            ),
            UFixed18.wrap(2103.418361512952480000e18),
            "incorrect result with lower decay"
        );
        // timestamp = 20_000, lamba = 100, k = 100, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(100e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(0.1e18)
            ),
            UFixed18.wrap(4405093.158961343292345000e18),
            "incorrect result with higher decay"
        );
    }

    function test_exponentialDecay_price() external view {
        // timestamp = 20_000, lamba = 10, k = 10, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(10e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(0.1e18)
            ),
            UFixed18.wrap(343.656365691809046800e18),
            "incorrect result with lower initial price"
        );
        // timestamp = 20_000, lamba = 10, k = 1000, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(1000e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(0.1e18)
            ),
            UFixed18.wrap(34365.636569180904680000e18),
            "incorrect result with higher initial price"
        );
    }

    // recover if so far behind that small buy would revert
    function test_exponentialDecay_behind() external {
        skip(1 days);
        // timestamp = 20_000, lamba = 10, k = 100
        // 1 day in, only sold 0.1 day worth of tokens per issuance schedule
        // cost of purchasing enough to bring us to 0.2 day worth of tokens, still behind by 0.8 day
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.1e18),
                UFixed18.wrap(0.2e18)
            ),
            UFixed18.wrap(424_105_647_631_664_000), // 0.424105647_631664000
            "incorrect result while somewhat behind"
        );

        // 4.5 days in, an attempt to buy a small amount of tokens would result in 0 price
        skip(3 days + 12 hours);
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.2e18),
                UFixed18.wrap(0.21e18)
            ),
            UFixed18.wrap(0),
            "incorrect result while really behind"
        );

        // five days in, someone purchases enough tokens to put us slightly ahead of issuance schedule
        skip(12 hours);
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecay(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.2e18),
                UFixed18.wrap(5.4e18)
            ),
            UFixed18.wrap(109196.300066288_478038000e18), // 109196.300066288_478038000
            "incorrect result after recovering"
        );
    }

    function test_exponentialDecay_fuzz(UFixed18 price, UFixed18 decay, UFixed18 from, UFixed18 to) external {
        skip(86400 * 10); // 10 days
        decay = boundUFixed18(decay, UFixed18.wrap(1e12), UFixed18.wrap(8e18));
        price = boundUFixed18(price, UFixed18.wrap(1e12), UFixed18.wrap(1e24));
        from = boundUFixed18(from, UFixed18.wrap(1e12), UFixed18.wrap(20e18));
        to = boundUFixed18(to, from, UFixed18.wrap(20e18));
        UFixed18 cost = VRGDADecayMath.exponentialDecay(UFixed18.wrap(20_000e18), price, decay, UFixed18Lib.from(200), from, to); // not revert
        if (cost < UFixed18.wrap(1e18)) return; // skip under minimum purchase amount
        UFixed18 to2 = VRGDADecayMath.exponentialDecayI(UFixed18.wrap(20_000e18), price, decay, UFixed18Lib.from(200), from, cost); // not revert
        assertApproxEqRel(UFixed18.unwrap(to), UFixed18.unwrap(to2), 1e13, "result too far off");
    }

    function test_exponentialDecayI_fromto() external {
        skip(8640 * 2); // 0.2 days
        // timestamp = 20_000, lamba = 10, k = 100, T = 0.1 -> 0.15
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.05e18),
                UFixed18.wrap(289.498562046024984000e18)
            ),
            UFixed18.wrap(0.1e18 + 1), // rounding error size (+1)
            "incorrect result with from and to in past"
        );
        // timestamp = 20_000, lamba = 10, k = 100, T = 0 -> 0.1
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.1e18),
                UFixed18.wrap(1264.241117657115358000e18)
            ),
            UFixed18.wrap(0.2e18),
            "incorrect result with from in past and zero to"
        );
        // timestamp = 20_000, lamba = 10, k = 100, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.2e18),
                UFixed18.wrap(3436.563656918090468000e18)
            ),
            UFixed18.wrap(0.3e18 - 1), // rounding error size (-1)
            "incorrect result with zero from and to in future"
        );
        // timestamp = 20_000, lamba = 10, k = 100, T = -0.15 -> -0.1
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0.3e18),
                UFixed18.wrap(3526.814483758039168000e18)
            ),
            UFixed18.wrap(0.35e18 - 1), // rounding error size (-1)
            "incorrect result with from and to in future"
        );
    }

    function test_exponentialDecayI_decay() external view {
        // timestamp = 20_000, lamba = 1, k = 100, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(1e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(2103.418361512952480000e18)
            ),
            UFixed18.wrap(0.1e18 - 11), // rounding error size (-11)
            "incorrect result with lower decay"
        );
        // timestamp = 20_000, lamba = 100, k = 100, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(100e18),
                UFixed18.wrap(100e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(4405093.158961343292345000e18)
            ),
            UFixed18.wrap(0.1e18 - 1), // rounding error size (-1)
            "incorrect result with higher decay"
        );
    }

    function test_exponentialDecayI_price() external view {
        // timestamp = 20_000, lamba = 10, k = 10, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(10e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(343.656365691809046800e18)
            ),
            UFixed18.wrap(0.1e18 - 1), // rounding error size (-1)
            "incorrect result with lower initial price"
        );
        // timestamp = 20_000, lamba = 10, k = 1000, T = -0.1 -> 0
        assertUFixed18Eq(
            VRGDADecayMath.exponentialDecayI(
                UFixed18.wrap(20_000e18),
                UFixed18.wrap(1000e18),
                UFixed18.wrap(10e18),
                UFixed18Lib.from(200),
                UFixed18.wrap(0e18),
                UFixed18.wrap(34365.636569180904680000e18)
            ),
            UFixed18.wrap(0.1e18 - 1), // rounding error size (-1)
            "incorrect result with higher initial price"
        );
    }

    function test_linearIssuance_emission() external pure {
        // emission = 100_000, auction = 2
        assertUFixed18Eq(
           VRGDAIssuanceMath.linearIssuance(
                UFixed18.wrap(100_000e18),
                UFixed18.wrap(2e18)
            ),
            UFixed18.wrap(200_000e18),
            "incorrect result with higher emission"
        );
        // emission = 1_000, auction = 2
        assertUFixed18Eq(
            VRGDAIssuanceMath.linearIssuance(
                UFixed18.wrap(1_000e18),
                UFixed18.wrap(2e18)
            ),
            UFixed18.wrap(2_000e18),
            "incorrect result with lower emission"
        );
    }

    function test_linearIssuance_auction() external pure {
        // emission = 10_000, auction = 0.2
        assertUFixed18Eq(
           VRGDAIssuanceMath.linearIssuance(
                UFixed18.wrap(10_000e18),
                UFixed18.wrap(0.2e18)
            ),
            UFixed18.wrap(2_000e18),
            "incorrect result with earlier auction time"
        );
        // emission = 10_000, auction = 20
        assertUFixed18Eq(
            VRGDAIssuanceMath.linearIssuance(
                UFixed18.wrap(10_000e18),
                UFixed18.wrap(20e18)
            ),
            UFixed18.wrap(200_000e18),
            "incorrect result with later auction time"
        );
    }

    function test_linearIssuanceI_emission() external pure {
        // emission = 1_000, issued = 20_000
        assertUFixed18Eq(
            VRGDAIssuanceMath.linearIssuanceI(
                UFixed18.wrap(1_000e18),
                UFixed18.wrap(20_000e18)
            ),
            UFixed18.wrap(20e18),
            "incorrect result with lower emission"
        );
        // emission = 100_000, issued = 20_000
        assertUFixed18Eq(
           VRGDAIssuanceMath.linearIssuanceI(
                UFixed18.wrap(100_000e18),
                UFixed18.wrap(20_000e18)
            ),
            UFixed18.wrap(0.2e18),
            "incorrect result with higher emission"
        );
    }

    function test_linearIssuanceI_issued() external pure {
        // emission = 10_000, issued = 2_000
        assertUFixed18Eq(
            VRGDAIssuanceMath.linearIssuanceI(
                UFixed18.wrap(10_000e18),
                UFixed18.wrap(2_000e18)
            ),
            UFixed18.wrap(0.2e18),
            "incorrect result with lower issued"
        );
        // emission = 10_000, issued = 200_000
        assertUFixed18Eq(
           VRGDAIssuanceMath.linearIssuanceI(
                UFixed18.wrap(10_000e18),
                UFixed18.wrap(200_000e18)
            ),
            UFixed18.wrap(20e18),
            "incorrect result with higher issued"
        );
    }
}
