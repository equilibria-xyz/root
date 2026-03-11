// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { ShortString, ShortStrings } from "@openzeppelin/contracts/utils/ShortStrings.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { IImplementation } from "./interfaces/IImplementation.sol";
import { IMutator } from "./interfaces/IMutator.sol";
import { Contract } from "./Contract.sol";

/// @title Implementation
/// @notice Implementation of Contract for upgradeable contracts.
abstract contract Implementation is IImplementation, Contract {
    /// @custom:storage-location erc7201:equilibria.root.Implementation
    struct ImplementationStorage {
        bool constructing;
        bool constructed;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant ImplementationStorageLocation = 0x3c57b102c533ff058ebe9a7c745178ce4174563553bb3edde7874874c532c200;

    /// @dev The erc7201 storage of the mix-in
    function Implementation$() private pure returns (ImplementationStorage storage $) {
        assembly {
            $.slot := ImplementationStorageLocation
        }
    }

    /// @dev The version of this implementation.
    ShortString private immutable _version;

    /// @dev The version of the predecessor implementation.
    ShortString private immutable _predecessor;

    /// @dev Constructor for the implementation.
    constructor(string memory version_, string memory predecessor_) {
        _version = ShortStrings.toShortString(version_);
        _predecessor = ShortStrings.toShortString(predecessor_);
        _disableInitializers();
    }

    /// @dev The name of the implementation.
    function name() external view virtual returns (string memory);

    /// @dev The version of this implementation.
    function version() public view virtual returns (string memory) {
        return ShortStrings.toString(_version);
    }

    /// @dev The version of the predecessor implementation.
    function predecessor() external view virtual returns (string memory) {
        return ShortStrings.toString(_predecessor);
    }

    /// @dev Called at upgrade time to initialize the contract with `data`.
    function construct(bytes memory data) external {
        if (Implementation$().constructed) revert ImplementationAlreadyConstructedError();
        Implementation$().constructing = true;

        string memory constructorVersion = __constructor(data);
        if (!Strings.equal(constructorVersion, version())) revert ImplementationConstructorVersionMismatch();

        Implementation$().constructing = false;
    }

    /// @dev Whether the contract is initializing.
    function _constructing() internal view override returns (bool) {
        return Implementation$().constructing;
    }

    /// @dev The deployer of the contract.
    function _deployer() internal view override returns (address) {
        return IMutator(msg.sender).owner();
    }

    /// @dev Locks the contract, preventing any future reinitialization. Called in the constructor to
    ///      prevent the implementation contract from being used directly.
    /// @custom:oz-ref https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/utils/Initializable.sol#L192C14-L192C34
    function _disableInitializers() internal virtual {
        if (Implementation$().constructing) revert ImplementationAlreadyConstructedError();
        Implementation$().constructed = true;
    }

    /// @dev Hook for inheriting contracts to construct the contract.
    function __constructor(bytes memory data) internal virtual returns (string memory);
}
