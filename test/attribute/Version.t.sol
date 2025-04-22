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
}
