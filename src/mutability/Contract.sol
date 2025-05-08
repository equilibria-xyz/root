// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

/// @title Contract
/// @notice Base contract that provides the scaffolding for all deployable contracts.
abstract contract Contract {
    /// @dev Hook to define when the contract is constructing based on implementation.
    function _constructing() internal virtual view returns (bool);

    /// @dev Hook to define the deployer of the contract.
    function _deployer() internal virtual view returns (address);
}