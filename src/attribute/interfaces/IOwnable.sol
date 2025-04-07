// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IInitializable } from "src/attribute/interfaces/IInitializable.sol";

interface IOwnable is IInitializable {
    event OwnerUpdated(address indexed newOwner);
    event PendingOwnerUpdated(address indexed newPendingOwner);

    // sig: 0x99bf6359
    /// @custom:error Caller is not the owner
    error OwnableNotOwnerError(address sender);
    // sig: 0xd0d5e1b0
    /// @custom:error Caller is not the pending owner
    error OwnableNotPendingOwnerError(address sender);
    // sig: 0xe43bdd4e
    /// @custom:error Contract is already initialized
    error OwnableAlreadyInitializedError();

    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function updatePendingOwner(address newPendingOwner) external;
    function acceptOwner() external;
}
