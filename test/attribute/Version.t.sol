// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import { RootTest } from "test/RootTest.sol";
import { Version, VersionLib } from "src/attribute/types/Version.sol";

contract VersionTest is RootTest {
    function test_equals() public pure {
        Version memory version1 = Version(3, 2, 8);
        Version memory version2 = Version(3, 2, 8);
        bool equalsResult = version1.eq(version2);
        assertTrue(equalsResult, "Versions should be equal");
        assertEq(version1, version2, "RootTest assertEq should also work");
    }

    function test_greaterThan() public pure {
        Version memory version1 = Version(2, 5, 8);
        Version memory version2 = Version(2, 5, 7);
        assertTrue(version1.gt(version2));
        version1 = Version(2, 5, 1);
        version2 = Version(2, 4, 7);
        assertTrue(version1.gt(version2));
        version1 = Version(4, 5, 6);
        version2 = Version(3, 5, 7);
        assertTrue(version1.gt(version2));
    }

    function test_lessThan() public pure {
        Version memory version1 = Version(0, 6, 7);
        Version memory version2 = Version(0, 6, 8);
        assertTrue(version1.lt(version2));
        version1 = Version(0, 5, 9);
        version2 = Version(0, 6, 8);
        assertTrue(version1.lt(version2));
        version1 = Version(0, 7, 9);
        version2 = Version(1, 6, 8);
        assertTrue(version1.lt(version2));
    }

    function testVersionUnsignedConversion() public pure {
        Version memory origVersion = Version(3, 6, 9);
        uint96 unsignedVersion = origVersion.toUnsigned();
        Version memory fromUnsignedVersion = VersionLib.from(unsignedVersion);
        assertEq(origVersion, fromUnsignedVersion);
    }
}
