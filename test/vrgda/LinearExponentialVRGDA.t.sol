// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { UFixed18, UFixed18Lib } from "../../src/number/types/UFixed18.sol";
import { LinearExponentialVRGDA } from "../../src/vrgda/types/LinearExponentialVRGDA.sol";
import { RootTest } from "../RootTest.sol";

contract LinearExponentialVRGDATest is RootTest {
    LinearExponentialVRGDA vrgda;
    UFixed18 issued;

    function setUp() public {
        vrgda = LinearExponentialVRGDA({
            timestamp: UFixed18Lib.from(block.timestamp),
            price: UFixed18.wrap(100e18),
            decay: UFixed18.wrap(10e18),
            emission: UFixed18.wrap(200) // 200 tokens per day
        });
    }

    function test_costDecreasesWhenBehind() public {
        // initial cost to purchase 1 token quite high
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(1)), UFixed18.wrap(11_291.903496976_577338030e18));
        // cost to move ahead of issuance schedule is higher
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(32_466_151.192919613_034886620e18));

        // after 1 day with nothing sold, cost to purchase 100 tokens is reasonable, and purchase is made
        skip(1 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(1_473.960983816_764210610e18));
        issued = UFixed18.wrap(100);
        // price increases as a result, but we're still behind
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(218_755.206002187_764655650e18));

        // after half a day, price becomes reasonable again, and continues to decrease
        skip(12 hours);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(1_473.960983816_764210610e18));
        skip(12 hours);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(9.931470987_677229170e18));
    }

    function test_costIncreasesWhenAhead() public {
        // after 1 day, 200 tokens have been purchased, even with issuance schedule
        skip(1 days);
        issued = UFixed18.wrap(200);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(1)), UFixed18.wrap(11_291.903496976_577338030e18));
        // price to purchase ahead of issuance schedule is higher
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(32_466_151.192919613_034886620e18));

        // after 3 days, expected issuance is 600 tokens, and we've sold 650, slightly ahead of schedule
        issued = issued + UFixed18.wrap(450);
        skip(2 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(395_518_690.835029055_174152540e18));

        // a day later we're now at 900, when 800 was expected; cost continues to increase
        issued = issued + UFixed18.wrap(250);
        skip(1 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(4_818_404_062.443085713_321147380e18));
    }

    function test_recoversAfterPurchaseAtZeroPrice() public {
        // we're 3 days into the auction, and have only sold 50 tokens; cost to purchase 100 tokens is quite low
        skip(3 days);
        issued = UFixed18.wrap(50);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(0.000037011_147859640e18));

        // another day passes, and price for 100 tokens hits zero, but 500 tokens has some cost
        skip(3 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(100)), UFixed18.wrap(0));
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(500)), UFixed18.wrap(1_691702110));
        // user grabs 100 tokens for free
        issued = issued + UFixed18.wrap(100);

        // we're 6 days in, and should have sold 1200 tokens; price recovers upon doing so
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18.wrap(1050)), UFixed18.wrap(220_239.165828664_098470190e18));
    }

    function test_doesNotUnderchargeForSmallPurchasesBehind() public {
        // setup is 2 days in, and 300 tokens sold; so somewhat behind scheduled 400
        skip(2 days);
        issued = UFixed18.wrap(300);

        // record cost to purchase 100 tokens
        UFixed18 singlePurchase = vrgda.toCost(issued, UFixed18.wrap(100));

        // make ten purchases of 10 tokens
        UFixed18 multiplePurchases = UFixed18.wrap(0);
        for (uint256 i = 0; i < 10; i++) {
            issued = issued + UFixed18.wrap(10);
            multiplePurchases = multiplePurchases + vrgda.toCost(issued, UFixed18.wrap(10));
        }
        assertUFixed18Eq(issued, UFixed18.wrap(400));

        // FIXME: compare costs: 218_755 < 360_666
        assertTrue(singlePurchase >= multiplePurchases);
    }

    function test_doesNotUnderchargeForSmallPurchasesAhead() public {
        // setup is 2 days in, and 500 tokens sold; so somewhat ahead scheduled 400
        skip(2 days);
        issued = UFixed18.wrap(500);

        // record cost to purchase 100 tokens
        UFixed18 singlePurchase = vrgda.toCost(issued, UFixed18.wrap(100));

        // make ten purchases of 10 tokens
        UFixed18 multiplePurchases = UFixed18.wrap(0);
        for (uint256 i = 0; i < 10; i++) {
            issued = issued + UFixed18.wrap(10);
            multiplePurchases = multiplePurchases + vrgda.toCost(issued, UFixed18.wrap(10));
        }
        assertUFixed18Eq(issued, UFixed18.wrap(600));

        // FIXME: compare costs: 4_818_404_062 < 7_944_205_268
        assertTrue(singlePurchase >= multiplePurchases);
    }
}
