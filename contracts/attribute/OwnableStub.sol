// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Ownable } from "./Ownable.sol";

/**
 * @title OwnableStub
 * @notice A simple stub contract that can accept ownership but cannot do anything else.
 * @dev This contract is used to relinquish ownership of a contract by transferring ownership to this stub.
 */
contract OwnableStub {
    /**
     * @notice Accepts ownership of the contract
     * @dev Can only be called by the pending owner to ensure correctness.
     */
    function acceptOwner(address ownable) external {
        Ownable(ownable).acceptOwner();
    }
}
