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
            price: UFixed18Lib.from(100),
            decay: UFixed18Lib.from(10),
            emission: UFixed18Lib.from(200) // 200 tokens per day
        });
    }

    function test_costDecreasesWhenBehind() public {
        // initial cost to purchase 1 token quite high
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(1)), UFixed18.wrap(2_258_380.699395315_467606000e18));
        // cost to move ahead of issuance schedule is higher
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(6_493_230_238.583922606_977324000e18));

        // after 1 day with nothing sold, cost to purchase 100 tokens is reasonable, and purchase is made
        skip(1 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(294_792.196763352_842122000e18));
        issued = UFixed18Lib.from(100);
        // price increases as a result, but we're still behind
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(43_751_041.200437552_931130000e18));

        // after half a day, price becomes reasonable again, and continues to decrease
        skip(12 hours);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(294_792.196763352_842122000e18));
        skip(12 hours);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(1_986.294197535_445834000e18));
    }

    function test_amountIncreasesWhenBehind() public {
        // after 1 day, 200 tokens have been purchased, even with issuance schedule
        skip(1 days);
        issued = UFixed18Lib.from(200);
        // a 5k purchase buys tokens
        assertUFixed18Eq(vrgda.toAmount(issued, UFixed18Lib.from(5_000)), UFixed18.wrap(0.002270130_392229200e18));

        // 8 hours later we would be behind issuance schedule, and should be able to purchase more tokens
        skip(8 hours);
        assertUFixed18Eq(vrgda.toAmount(issued, UFixed18Lib.from(5_000)), UFixed18.wrap(0.063538021_305059800e18));

        // after 4 days, should be able to purchase considerably more
        skip(3 days + 16 hours);
        assertUFixed18Eq(vrgda.toAmount(issued, UFixed18Lib.from(5_000)), UFixed18.wrap(618.328129452_298664400e18));
    }

    function test_amountDecreasesWhenAhead() public {
        // after 1 day, 200 tokens have been purchased, even with issuance schedule
        skip(1 days);
        issued = UFixed18Lib.from(200);
        // a 50k purchase buys tokens
        assertUFixed18Eq(vrgda.toAmount(issued, UFixed18Lib.from(50_000)), UFixed18.wrap(0.022689716_894178400e18));

        // if someone purchases 100 tokens, the same 50k purchase would buy us almost nothing
        issued = issued + UFixed18Lib.from(100);
        assertUFixed18Eq(vrgda.toAmount(issued, UFixed18Lib.from(50_000)), UFixed18.wrap(0.000152968_278971800e18));

        // if even more overbought, the amount we can purchase becomes infinitesimal
        issued = issued + UFixed18Lib.from(200);
        assertUFixed18Eq(vrgda.toAmount(issued, UFixed18Lib.from(50_000)), UFixed18.wrap(0.000000006_944775400e18));
    }

    function test_costIncreasesWhenAhead() public {
        // after 1 day, 200 tokens have been purchased, even with issuance schedule
        skip(1 days);
        issued = UFixed18Lib.from(200);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(1)), UFixed18.wrap(2_258_380.699395315_467606000e18));
        // price to purchase ahead of issuance schedule is higher
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(6_493_230_238.583922606_977324000e18));

        // after 3 days, expected issuance is 600 tokens, and we've sold 650, slightly ahead of schedule
        issued = issued + UFixed18Lib.from(450);
        skip(2 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(79_103_738_167.005811034_830508000e18));

        // a day later we're now at 900, when 800 was expected; cost continues to increase
        issued = issued + UFixed18Lib.from(250);
        skip(1 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(963_680_812_488.617142664_229476000e18));
    }

    function test_toCostEquivalentWithToAmount() public {
        // equivalent when behind
        skip(4 days);
        issued = UFixed18Lib.from(700);
        UFixed18 amount = UFixed18Lib.from(100);
        UFixed18 cost = vrgda.toCost(issued, amount);
        assertApproxEqAbs(UFixed18.unwrap(vrgda.toAmount(issued, cost)), UFixed18.unwrap(amount), 200);

        // equivalent when ahead
        issued = UFixed18Lib.from(900);
        cost = vrgda.toCost(issued, UFixed18Lib.from(100));
        assertApproxEqAbs(UFixed18.unwrap(vrgda.toAmount(issued, cost)), UFixed18.unwrap(amount), 200);
    }

    function test_recoversAfterPurchaseAtZeroPrice() public {
        // we're 3 days into the auction, and have only sold 50 tokens; cost to purchase 100 tokens is quite low
        skip(3 days);
        issued = UFixed18Lib.from(50);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(0.007402229_571928000e18));

        // another day passes, and price for 100 tokens hits zero, but 500 tokens has some cost
        skip(3 days);
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(100)), UFixed18.wrap(0));
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(500)), UFixed18.wrap(338340422000));
        // user grabs 100 tokens for free
        issued = issued + UFixed18Lib.from(100);

        // we're 6 days in, and should have sold 1200 tokens; price recovers upon doing so
        assertUFixed18Eq(vrgda.toCost(issued, UFixed18Lib.from(1050)), UFixed18.wrap(44_047_833.165732819_694038000e18));
    }

    /// @dev Ensures that users may not use split purchases into smaller batches to reduce cost
    /// @param daysIn The number of days to skip ahead
    /// @param alreadyIssued Determines if we are ahead or behind the issuance schedule
    /// @param tokensToPurchase The number of tokens in each of the small purchases
    function test_doesNotUnderchargeForSmallPurchases(
        uint256 daysIn,
        uint256 alreadyIssued,
        uint256 tokensToPurchase
    ) public {
        daysIn = bound(daysIn, 0, 7);                                          // start-of-auction to a week out
        alreadyIssued = bound(alreadyIssued, 0, daysIn * 300);                 // bound issuance from 0 to 1.5x expected
        uint256 numPurchases = 1_000;                                          // gas and memory limited, max ~80k
        tokensToPurchase = bound(tokensToPurchase, 1e10, 1e18 / numPurchases); // in each purchase, max 1 whole token

        // set up initial state to be ahead or behind the issuance schedule, even with only 1k purchases
        skip(daysIn * 3600 * 24);
        issued = UFixed18Lib.from(alreadyIssued);

        // record cost to purchase tokens
        UFixed18 singlePurchase = vrgda.toCost(issued, UFixed18.wrap(tokensToPurchase * numPurchases));

        // make multiple purchases
        UFixed18 multiplePurchases = UFixed18Lib.ZERO;
        for (uint256 i = 0; i < numPurchases; i++) {
            issued = issued + UFixed18.wrap(tokensToPurchase);
            multiplePurchases = multiplePurchases + vrgda.toCost(issued, UFixed18.wrap(tokensToPurchase));
        }
        assertEq(UFixed18.unwrap(issued), (alreadyIssued * 1e18) + (tokensToPurchase * numPurchases), "total issued mismatch");
        int256 difference = int256(UFixed18.unwrap(singlePurchase)) - int256(UFixed18.unwrap(multiplePurchases));
        assertTrue(singlePurchase <= multiplePurchases || difference < 1e18, "undercharges for small purchase");
    }
}
