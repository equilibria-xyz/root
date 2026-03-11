// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IImplementation {
    // sig: 0x149b10c8
    /// @dev Thrown when the constructor version of the implementation does not match the version of the implementation.
    error ImplementationConstructorVersionMismatch();

    // sig: 0xadde52c4
    /// @dev Thrown when the implementation is called directly rather than through a proxy.
    error ImplementationDeniedDirectAccess();

    function name() external view returns (string memory);
    function version() external view returns (string memory);
    function predecessor() external view returns (string memory);
    function construct(bytes memory data) external;
}
