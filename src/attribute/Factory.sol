// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import { IFactory } from "./interfaces/IFactory.sol";
import { IInstance } from "./interfaces/IInstance.sol";
import { Pausable } from "./Pausable.sol";
import { Ownable } from "./Ownable.sol";

/// @title Factory
/// @notice An abstract factory that manages creates and manages instances
/// @dev Ownable and Pausable, and satisfies the IBeacon interface by default.
abstract contract Factory is IFactory, Ownable, Pausable {
    /// @custom:storage-location erc7201:equilibria.root.Factory
    struct FactoryStorage {
        mapping(IInstance instance => bool registered) instances;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant FactoryStorageLocation = 0x2068933510e31bb02be4765cf6d0b2c054190db3eddefe11ffed0ca32b7e6f00;

    /// @dev The erc7201 storage of the mix-in
    function Factory$() private pure returns (FactoryStorage storage $) {
        assembly {
            $.slot := FactoryStorageLocation
        }
    }

    /// @notice The instance implementation address
    address public immutable implementation;

    /// @notice Constructs the contract
    /// @param implementation_ The instance implementation address
    constructor(address implementation_) { implementation = implementation_; }

    /// @notice Initializes the contract state
    function __Factory__initialize() internal onlyInitializer {
        __Ownable__initialize();
    }

    /// @notice Returns whether the instance is valid
    /// @param instance The instance to check
    /// @return Whether the instance is valid
    function instances(IInstance instance) public view returns (bool) {
        return Factory$().instances[instance];
    }

    /// @notice Creates a new instance
    /// @dev Deploys a BeaconProxy with the this contract as the beacon
    /// @param data The initialization data
    /// @return newInstance The new instance
    function _create(bytes memory data) internal returns (IInstance newInstance) {
        newInstance = IInstance(address(new BeaconProxy(address(this), data)));
        _register(newInstance);
    }
    /// @notice Creates a new instance at a deterministic address
    /// @dev Deploys a BeaconProxy with the this contract as the beacon
    /// @param data The initialization data
    /// @param salt Used along with initialization data to determine a unique BeaconProxy address
    /// @return newInstance The new instance
    function _create2(bytes memory data, bytes32 salt) internal returns (IInstance newInstance) {
        newInstance = IInstance(address(new BeaconProxy{salt: salt}(address(this), data)));
        _register(newInstance);
    }

    // @notice Calculates the address at which the instance will be deployed
    // @dev Passes the proxy's creation code along with this factory's address
    // @param data The same initialization data used in the _create2 call
    // @param salt Used along with initialization data to determine a unique BeaconProxy address
    function _computeCreate2Address(bytes memory data, bytes32 salt) internal view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(BeaconProxy).creationCode,
            abi.encode(address(this), data)
        );
        return Create2.computeAddress(salt, keccak256(bytecode));
    }

    /// @notice Registers a new instance
    /// @dev Called by _create automatically, or can be called manually in an extending implementation
    /// @param newInstance The new instance
    function _register(IInstance newInstance) internal {
        Factory$().instances[newInstance] = true;
        emit InstanceRegistered(newInstance);
    }

    /// @notice Only allow the function by a valid instance
    modifier onlyInstance {
        if (!instances(IInstance(msg.sender))) revert FactoryNotInstanceError();
        _;
    }
}
