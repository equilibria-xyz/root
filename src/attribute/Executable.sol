// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { IExecutable } from "./interfaces/IExecutable.sol";
import { Attribute } from "./Attribute.sol";
import { Ownable } from "./Ownable.sol";

/// @title Executable
/// @notice Allows the owner to execute calls to other contracts
abstract contract Executable is IExecutable, Attribute, Ownable {
    /// @notice Executes a call to a target contract
    /// @dev Can only be called by the owner
    /// @param target Address of the target contract
    /// @param data Calldata to be executed
    /// @return result The result of the call
    function execute(address target, bytes calldata data) public payable virtual onlyOwner returns (bytes memory) {
        return Address.functionCallWithValue(target, data, msg.value);
    }
}
