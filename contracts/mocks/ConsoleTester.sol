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

    function testLogWithTwoInts(uint256 val1, uint256 val2) external view {
        console.log("      Both unsigned and unsigned: %s and %s", uint(val1), uint(val2));
        console.log("      Both unsigned and signed:   %s and %s", uint(val1), int(val2)*-1);
        console.log("      Both signed and unsigned:   %s and %s", int(val1)*-1, uint(val2));
        console.log("      Both signed (negative):     %s and %s", int(val1)*-1, int(val2)*-1);
        console.log("      Both signed (positive):     %s and %s", int(val1), int(val2));
    }

    function testLogWithTwoFixedValues(UFixed6 uf6, UFixed18 uf18, Fixed6 f6, Fixed18 f18) external view {
        console.log("      UFixed6 %s and UFixed6 %s", uf6, uf6);
        console.log("      UFixed18 %s and UFixed18 %s", uf18, uf18);
        console.log("      Fixed6 %s and Fixed6 %s", f6, f6);
        console.log("      Fixed18 %s and Fixed18 %s", f18, f18);
        console.log("      UFixed6 %s and UFixed18 %s", uf6, uf18);
        console.log("      Fixed6 %s and Fixed18 %s", f6, f18);
        console.log("      UFixed6 %s and Fixed18 %s", uf6, f18);
        console.log("      Fixed6 %s and UFixed18 %s", f6, uf18);
        console.log("      UFixed6 %s and Fixed6 %s", uf6, f6);
        console.log("      UFixed18 %s and Fixed18 %s", uf18, f18);
        console.log("      Fixed6 %s and UFixed6 %s", f6, uf6);
        console.log("      Fixed18 %s and UFixed18 %s", f18, uf18);
    }

    function testLogWithTwoValues(uint256 u, int256 i, UFixed6 uf6, UFixed18 uf18, Fixed6 f6, Fixed18 f18, address a) external view {
        console.log("      uint256 %s and int256 %s", u, i);
        console.log("      uint256 %s and UFixed6 %s", u, uf6);
        console.log("      uint256 %s and UFixed18 %s", u, uf18);
        console.log("      uint256 %s and Fixed6 %s", u, f6);
        console.log("      uint256 %s and Fixed18 %s", u, f18);
        console.log("      int256 %s and UFixed6 %s", i, uf6);
        console.log("      int256 %s and UFixed18 %s", i, uf18);
        console.log("      int256 %s and Fixed6 %s", i, f6);
        console.log("      int256 %s and Fixed18 %s", i, f18);
        console.log("      UFixed6 %s and UFixed18 %s", uf6, uf18);
        console.log("      UFixed6 %s and Fixed6 %s", uf6, f6);
        console.log("      UFixed6 %s and Fixed18 %s", uf6, f18);
        console.log("      UFixed18 %s and Fixed6 %s", uf18, f6);
        console.log("      UFixed18 %s and Fixed18 %s", uf18, f18);
        console.log("      Fixed6 %s and Fixed18 %s", f6, f18);
        console.log("      uint256 %s and uint256 %s", u, u);
        console.log("      int256 %s and int256 %s", i, i);
        console.log("      UFixed6 %s and UFixed6 %s", uf6, uf6);
        console.log("      UFixed18 %s and UFixed18 %s", uf18, uf18);
        console.log("      Fixed6 %s and Fixed6 %s", f6, f6);
        console.log("      Fixed18 %s and Fixed18 %s", f18, f18);
        console.log("      uint256 %s and Fixed6 %s", u, f6);
        console.log("      uint256 %s and Fixed18 %s", u, f18);
        console.log("      int256 %s and Fixed6 %s", i, f6);
        console.log("      int256 %s and Fixed18 %s", i, f18);
        console.log("      Fixed6 %s and UFixed6 %s", f6, uf6);
        console.log("      Fixed18 %s and UFixed18 %s", f18, uf18);
        console.log("      Fixed6 %s and UFixed18 %s", f6, uf18);
        console.log("      Fixed18 %s and UFixed6 %s", f18, uf6);
        console.log("      uint256 %s and address %s", u, a);
        console.log("      int256 %s and address %s", i, a);
        console.log("      UFixed6 %s and address %s", uf6, a);
        console.log("      UFixed18 %s and address %s", uf18, a);
        console.log("      Fixed6 %s and address %s", f6, a);
        console.log("      Fixed18 %s and address %s", f18, a);
        console.log("      address %s and uint256 %s", a, u);
        console.log("      address %s and int256 %s", a, i);
        console.log("      address %s and UFixed6 %s", a, uf6);
        console.log("      address %s and UFixed18 %s", a, uf18);
        console.log("      address %s and Fixed6 %s", a, f6);
        console.log("      address %s and Fixed18 %s", a, f18);
    }

    /*function testLogWithThreeValues(uint256 u, int256 i, UFixed6 uf6, UFixed18 uf18, Fixed6 f6, Fixed18 f18) external view {
        console.log("      uint256 %s, int256 %s, UFixed6 %s", u, i, uf6);
        console.log("      uint256 %s, int256 %s, UFixed18 %s", u, i, uf18);
        console.log("      uint256 %s, int256 %s, Fixed6 %s", u, i, f6);
        console.log("      uint256 %s, int256 %s, Fixed18 %s", u, i, f18);
        console.log("      uint256 %s, UFixed6 %s, UFixed18 %s", u, uf6, uf18);
        console.log("      uint256 %s, UFixed6 %s, Fixed6 %s", u, uf6, f6);
        console.log("      uint256 %s, UFixed6 %s, Fixed18 %s", u, uf6, f18);
        console.log("      uint256 %s, UFixed18 %s, Fixed6 %s", u, uf18, f6);
        console.log("      uint256 %s, UFixed18 %s, Fixed18 %s", u, uf18, f18);
        console.log("      uint256 %s, Fixed6 %s, Fixed18 %s", u, f6, f18);
        console.log("      int256 %s, UFixed6 %s, UFixed18 %s", i, uf6, uf18);
        console.log("      int256 %s, UFixed6 %s, Fixed6 %s", i, uf6, f6);
        console.log("      int256 %s, UFixed6 %s, Fixed18 %s", i, uf6, f18);
        console.log("      int256 %s, UFixed18 %s, Fixed6 %s", i, uf18, f6);
        console.log("      int256 %s, UFixed18 %s, Fixed18 %s", i, uf18, f18);
        console.log("      int256 %s, Fixed6 %s, Fixed18 %s", i, f6, f18);
        console.log("      UFixed6 %s, UFixed18 %s, Fixed6 %s", uf6, uf18, f6);
        console.log("      UFixed6 %s, UFixed18 %s, Fixed18 %s", uf6, uf18, f18);
        console.log("      UFixed6 %s, Fixed6 %s, Fixed18 %s", uf6, f6, f18);
        console.log("      UFixed18 %s, Fixed6 %s, Fixed18 %s", uf18, f6, f18);
        console.log("      Fixed6 %s, Fixed18 %s, UFixed6 %s", f6, f18, uf6);
        console.log("      Fixed6 %s, Fixed18 %s, UFixed18 %s", f6, f18, uf18);
        console.log("      uint256 %s, uint256 %s, uint256 %s", u, u, u);
        console.log("      int256 %s, int256 %s, int256 %s", i, i, i);
        console.log("      UFixed6 %s, UFixed6 %s, UFixed6 %s", uf6, uf6, uf6);
        console.log("      UFixed18 %s, UFixed18 %s, UFixed18 %s", uf18, uf18, uf18);
        console.log("      Fixed6 %s, Fixed6 %s, Fixed6 %s", f6, f6, f6);
        console.log("      Fixed18 %s, Fixed18 %s, Fixed18 %s", f18, f18, f18);
        console.log("      uint256 %s, int256 %s, Fixed6 %s", u, i, f6);
        console.log("      uint256 %s, int256 %s, Fixed18 %s", u, i, f18);
        console.log("      uint256 %s, UFixed6 %s, Fixed6 %s", u, uf6, f6);
        console.log("      uint256 %s, UFixed18 %s, Fixed18 %s", u, uf18, f18);
        console.log("      int256 %s, UFixed6 %s, Fixed6 %s", i, uf6, f6);
        console.log("      int256 %s, UFixed18 %s, Fixed18 %s", i, uf18, f18);
        console.log("      UFixed6 %s, UFixed18 %s, Fixed6 %s", uf6, uf18, f6);
        console.log("      UFixed6 %s, UFixed18 %s, Fixed18 %s", uf6, uf18, f18);
        console.log("      Fixed6 %s, Fixed18 %s, UFixed6 %s", f6, f18, uf6);
        console.log("      Fixed6 %s, Fixed18 %s, UFixed18 %s", f6, f18, uf18);
    }*/
}
