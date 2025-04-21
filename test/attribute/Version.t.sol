// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

import { RootTest } from "test/RootTest.sol";
import { Version, VersionLib } from "src/attribute/types/Version.sol";

contract VersionTest is RootTest {
    function test_equals() public pure {
        Version version1 = VersionLib.from(3, 2, 8);
        Version version2 = VersionLib.from(3, 2, 8);
        bool equalsResult = version1.eq(version2);
        assertTrue(equalsResult, "Versions should be equal");
        assertEq(version1, version2, "RootTest assertEq should also work");
    }

    function test_greaterThan() public pure {
        Version version1 = VersionLib.from(2, 5, 8);
        Version version2 = VersionLib.from(2, 5, 7);
        assertTrue(version1.gt(version2));
        version1 = VersionLib.from(2, 5, 1);
        version2 = VersionLib.from(2, 4, 7);
        assertTrue(version1.gt(version2));
        version1 = VersionLib.from(4, 5, 6);
        version2 = VersionLib.from(3, 5, 7);
        assertTrue(version1.gt(version2));
    }

    function test_lessThan() public pure {
        Version version1 = VersionLib.from(0, 6, 7);
        Version version2 = VersionLib.from(0, 6, 8);
        assertTrue(version1.lt(version2));
        version1 = VersionLib.from(0, 5, 9);
        version2 = VersionLib.from(0, 6, 8);
        assertTrue(version1.lt(version2));
        version1 = VersionLib.from(0, 7, 9);
        version2 = VersionLib.from(1, 6, 8);
        assertTrue(version1.lt(version2));
    }

    function testToComponents() public pure {
        Version version = VersionLib.from(3, 6, 9);
        (uint256 major, uint256 minor, uint256 patch) = version.toComponents();
        assertEq(major, 3, "Major version should be 3");
        assertEq(minor, 6, "Minor version should be 6");
        assertEq(patch, 9, "Patch version should be 9");
    }
}
