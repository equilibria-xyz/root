// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Version } from "../types/Version.sol";

interface IImplementation {
    // sig: 0x149b10c8
    /// @dev Thrown when the constructor version of the implementation does not match the version of the implementation.
    error ImplementationConstructorVersionMismatch();

    function name() external view returns (string memory);
    function version() external view returns (Version);
    function predecessor() external view returns (Version);
    function construct(bytes memory data) external;
}
