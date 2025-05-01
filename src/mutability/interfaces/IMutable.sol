// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IMutable {
    // sig: 0xf74492ff
    error MutableVersionAlreadyInitialized();

    event Initialized(uint256 version);

    function construct(bytes memory data) external;
}
