// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Fixed6, Fixed18 } from "../number/types/Fixed6.sol";
import { UFixed6, UFixed18 } from "../number/types/UFixed6.sol";

import { console } from "../utils/console.sol";

contract ConsoleTester {

    function testSingleValues(UFixed6 uf6, UFixed18 uf18, Fixed6 f6, Fixed18 f18) external view {
        console.log(uf6);
        console.log(uf18);
        console.log(f6);
        console.log(f18);
    }

    function testLogWithInt(int256 signed) external view {
        console.log("      Signed int %s with trailing text", signed);
    }

    function testLogWithUFixed(UFixed6 decimal6, UFixed18 decimal18) external view {
        console.log("           Six decimal fixed %s (unsigned)", decimal6);
        console.log("      Eighteen decimal fixed %s (unsigned)", decimal18);
    }

    function testLogWithFixed(Fixed6 decimal6, Fixed18 decimal18) external view {
        console.log("           Six decimal fixed %s (signed)", decimal6);
        console.log("      Eighteen decimal fixed %s (signed)", decimal18);
    }

    function testLogWithTwoInts() external view {
        console.log("      Both u and u:       %s and %s", uint(23), uint(34));
        console.log("      Both u and i:       %s and %s", uint(23), int(-43));
        console.log("      Both i and u:       %s and %s", int(-32), uint(34));
        console.log("      Both i and i (neg): %s and %s", int(-32), int(-43));
        console.log("      Both i and i (pos): %s and %s", int(32), int(43));
    }
}
