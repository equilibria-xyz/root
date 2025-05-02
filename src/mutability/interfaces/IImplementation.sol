// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IImplementation {
    // sig: 0xf25316d9
    error ImplementationVersionAlreadyInitialized();

    event Initialized(uint256 version);

    function construct(bytes memory data) external;
}
