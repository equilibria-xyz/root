// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../Initializable.sol";
import "../interfaces/IKept.sol";
import "../../storage/Storage.sol";

/// @title Kept
/// @notice Library to manage keeper incentivization.
/// @dev Surfaces a keep() modifier that handles measuring job gas costs and paying out rewards the keeper.
abstract contract Kept is IKept, Initializable {
    /// @dev The legacy Chainlink feed that is used to convert price ETH relative to the keeper token
    AddressStorage private constant _ethTokenOracleFeed = AddressStorage.wrap(keccak256("equilibria.root.Kept.ethTokenOracleFeed"));
    function ethTokenOracleFeed() public view returns (AggregatorV3Interface) { return AggregatorV3Interface(_ethTokenOracleFeed.read()); }

    /// @dev The token that the keeper is paid in
    Token18Storage private constant _keeperToken = Token18Storage.wrap(keccak256("equilibria.root.Kept.keeperToken"));
    function keeperToken() public view returns (Token18) { return _keeperToken.read(); }

    /// @notice Initializes the contract
    /// @param ethTokenOracleFeed_ The legacy Chainlink feed that is used to convert price ETH relative to the keeper token
    /// @param keeperToken_ The token that the keeper is paid in
    function __Kept__initialize(
        AggregatorV3Interface ethTokenOracleFeed_,
        Token18 keeperToken_
    ) internal onlyInitializer {
        _ethTokenOracleFeed.store(address(ethTokenOracleFeed_));
        _keeperToken.store(keeperToken_);
    }

    /// @notice Called by the keep modifier to raise the optionally raise the keeper fee
    /// @param amount The amount of keeper fee to raise
    /// @param data Arbitrary data passed in from the keep modifier
    /// @return The amount of keeper fee that was actually raised
    function _raiseKeeperFee(UFixed18 amount, bytes memory data) internal virtual returns (UFixed18) { return amount; }

    /// @notice Computes the calldata portion of the keeper fee
    /// @dev Used for L2 implementation with significant calldata costs
    /// @param applicableCalldata The applicable calldata
    /// @param multiplierCalldata The multiplier to apply to the calldata cost
    /// @param bufferCalldata The buffer to apply to the calldata cost
    /// @return The calldata portion of the keeper fee
    function _calldataFee(
        bytes memory applicableCalldata,
        UFixed18 multiplierCalldata,
        uint256 bufferCalldata
    ) internal view virtual returns (UFixed18) { return UFixed18Lib.ZERO; }

    /// @notice Computes the base gas portion of the keeper fee
    /// @param applicableGas The applicable gas cost
    /// @param multiplierBase The multiplier to apply to the gas cost
    /// @param bufferBase The buffer to apply to the gas cost
    /// @return The gas cost portion of the keeper fee
    function _baseFee(
        uint256 applicableGas,
        UFixed18 multiplierBase,
        uint256 bufferBase
    ) internal view returns (UFixed18) {
        return _fee(applicableGas, multiplierBase, bufferBase, block.basefee);
    }

    /// @notice Computes a generic keeper fee based on parameters
    /// @dev Helper function to consolidate keeper fee computation logic
    /// @param gas The gas cost
    /// @param multiplier The multiplier to apply to the gas cost
    /// @param buffer The buffer to apply to the gas cost
    /// @return The resulting keeper fee
    function _fee(uint256 gas, UFixed18 multiplier, uint256 buffer, uint256 baseFee) internal pure returns (UFixed18) {
        return UFixed18Lib.from(gas).mul(multiplier).add(UFixed18Lib.from(buffer)).mul(UFixed18.wrap(baseFee));
    }

    /// @notice Placed on a function to incentivize keepers to call it
    /// @param config The multiplier and buffer configuration to apply
    /// @param data Arbitrary data to pass to the _raiseKeeperFee function
    /// @param applicableCalldata The applicable calldata
    /// @param applicableValue The applicable value
    /// @param data Arbitrary data to pass to the _raiseKeeperFee function
    modifier keep(
        KeepConfig memory config,
        bytes memory applicableCalldata,
        uint256 applicableValue,
        bytes memory data
    ) {
        uint256 startGas = gasleft();

        _;

        uint256 applicableGas = startGas - gasleft();

        _handleKeeperFee(config, applicableGas, applicableCalldata, applicableValue, data);
    }

    /// @notice Called by the keep modifier to handle keeper fee computation and payment
    /// @param config The multiplier and buffer configuration to apply
    /// @param applicableGas The applicable gas cost
    /// @param applicableCalldata The applicable calldata
    /// @param applicableValue The applicable value
    /// @param data Arbitrary data to pass to the _raiseKeeperFee function
    function _handleKeeperFee(
        KeepConfig memory config,
        uint256 applicableGas,
        bytes memory applicableCalldata,
        uint256 applicableValue,
        bytes memory data
    ) internal {
        (UFixed18 baseFee, UFixed18 calldataFee) = (
            _baseFee(applicableGas, config.multiplierBase, config.bufferBase),
            _calldataFee(applicableCalldata, config.multiplierCalldata, config.bufferCalldata)
        );

        UFixed18 keeperFee = UFixed18.wrap(applicableValue).add(baseFee).add(calldataFee).mul(_etherPrice());
        keeperFee = _raiseKeeperFee(keeperFee, data);
        keeperToken().push(msg.sender, keeperFee);

        emit KeeperCall(msg.sender, applicableGas, applicableValue, baseFee, calldataFee, keeperFee);
    }

    /// @notice Returns the price of ETH in terms of the keeper token
    /// @return The price of ETH in terms of the keeper token
    function _etherPrice() private view returns (UFixed18) {
        (, int256 answer, , ,) = ethTokenOracleFeed().latestRoundData();
        return UFixed18Lib.from(Fixed18Lib.ratio(answer, 1e8)); // chainlink eth-usd feed uses 8 decimals
    }
}
