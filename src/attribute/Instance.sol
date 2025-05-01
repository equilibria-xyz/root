// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IInstance } from "./interfaces/IInstance.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { Attribute } from "../mutability/Attribute.sol";

/// @title Instance
/// @notice An abstract contract that is created and managed by a factory
abstract contract Instance is IInstance, Attribute {
    /// @custom:storage-location erc7201:equilibria.root.Instance
    struct InstanceStorage {
        IFactory factory;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant InstanceStorageLocation = 0xbf37ca0c6353d07d4968ca5873c5b82ea2e21a06e612b4d4a1c55285b8166200;

    /// @dev The erc7201 storage of the mix-in
    function Instance$() private pure returns (InstanceStorage storage $) {
        assembly {
            $.slot := InstanceStorageLocation
        }
    }

    /// @notice Initializes the contract setting `msg.sender` as the factory
    function __Instance__constructor() initializer("Instance") internal {
        Instance$().factory = IFactory(msg.sender);
    }

    /// @dev The factory that created this instance
    function factory() public view returns (IFactory) {
        return Instance$().factory;
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
