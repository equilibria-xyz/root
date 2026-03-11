// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IImplementation {
    // sig: 0x149b10c8
    /// @dev Thrown when the constructor version of the implementation does not match the version of the implementation.
    error ImplementationConstructorVersionMismatch();

    // sig: 0x17e9e41b
    /// @dev Thrown when construct() is called directly on the implementation contract.
    error ImplementationAlreadyConstructedError();

    function name() external view returns (string memory);
    function version() external view returns (string memory);
    function predecessor() external view returns (string memory);
    function construct(bytes memory data) external;
}
