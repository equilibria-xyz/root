// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IAttribute } from "../attribute/interfaces/IAttribute.sol";
import { Contract } from "../mutability/Contract.sol";

/// @title Attribute
/// @notice Manages initialization lifecycle for abstract mix-ins that are optionally upgradable.
abstract contract Attribute is IAttribute, Contract {
    /// @custom:storage-location erc7201:equilibria.root.Attribute
    struct AttributeStorage {
        mapping(string attribute => bool value) attributes;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant AttributeStorageLocation = 0x429797e2de2710eed6bc286312ff2c2286e5c3e13ca14d38e450727a132bfa00;

    /// @dev The erc7201 storage of the mix-in
    function Attribute$() private pure returns (AttributeStorage storage $) {
        assembly {
            $.slot := AttributeStorageLocation
        }
    }

    /// @dev Ensure the deployable parent contract is constructing
    ///      Skip if the mix-in has already been constructed
    modifier initializer(string memory attribute) {
        if (!_constructing()) revert AttributeNotConstructing();
        if (!Attribute$().attributes[attribute]) _;
        Attribute$().attributes[attribute] = true;
    }
}