// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import {Ownable} from "./Ownable.sol";

/**
 * @title OwnerExecutable
 * @notice Allows the owner to execute calls to other contracts
 */
abstract contract OwnerExecutable is Ownable {
    error OwnableExecuteCallFailed();

    /**
     * @notice Executes a call to a target contract
     * @dev Can only be called by the owner
     * @param target Address of the target contract
     * @param data Calldata to be executed
     * @return result The result of the call
     */
    function execute(address target, bytes calldata data) public payable virtual onlyOwner returns (bytes memory result) {
        (bool success, bytes memory response) = target.call{value: msg.value}(data);
        if (!success) {
            revert OwnableExecuteCallFailed();
        }
        return response;
    }
}
