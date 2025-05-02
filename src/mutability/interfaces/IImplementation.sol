// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Version } from "../types/Version.sol";

interface IImplementation {
    function nameHash() external view returns (bytes32);
    function target() external view returns (Version);
    function version() external view returns (Version);
    function construct(bytes memory data) external;
}
