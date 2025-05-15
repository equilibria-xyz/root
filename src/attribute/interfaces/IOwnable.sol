// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IAttribute } from "../../mutability/interfaces/IAttribute.sol";

interface IOwnable is IAttribute {
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

    /// @dev The owner address
    function owner() external view returns (address);
    /// @dev The pending owner address
    function pendingOwner() external view returns (address);
    function updatePendingOwner(address newPendingOwner) external;
    function acceptOwner() external;
}
