// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { StorageSlot } from "@openzeppelin/contracts/utils/StorageSlot.sol";

import { IInstance } from "./interfaces/IInstance.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { Attribute } from "../mutability/Attribute.sol";

/// @title Instance
/// @notice An abstract contract that is created and managed by a factory
abstract contract Instance is IInstance, Attribute {
    /// @dev The slot of the factory address
    bytes32 private constant FACTORY_SLOT = keccak256("equilibria.root.Instance.factory");

    /// @notice Initializes the contract setting `msg.sender` as the factory
    function __Instance__constructor() initializer("Instance") internal {
        StorageSlot.getAddressSlot(FACTORY_SLOT).value = msg.sender;
    }

    /// @dev The factory that created this instance
    function factory() public view returns (IFactory) {
        return IFactory(StorageSlot.getAddressSlot(FACTORY_SLOT).value);
    }

    /// @notice Only allow the owner defined by the factory to call the function
    modifier onlyOwner {
        if (msg.sender != factory().owner()) revert InstanceNotOwnerError(msg.sender);
        _;
    }

    /// @notice Only allow the factory to call the function
    modifier onlyFactory {
        if (msg.sender != address(factory())) revert InstanceNotFactoryError(msg.sender);
        _;
    }

    /// @notice Only allow the function to be called when the factory is not paused
    modifier whenNotPaused {
        if (factory().paused()) revert InstancePausedError();
        _;
    }
}
