// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./Initializable.sol";
import "./interfaces/IKept.sol";
import "../storage/Storage.sol";

/// @title Kept
/// @notice Library to manage keeper incentivization.
/// @dev Surfaces a keep() modifier that handles measuring job gas costs and paying out rewards the keeper.
abstract contract Kept is IKept, Initializable {
    /// @dev The legacy Chainlink feed that is used to convert price ETH relative to the keeper token
    AddressStorage private constant _ethTokenOracleFeed = AddressStorage.wrap(keccak256("equilibria.root.UKept.ethTokenOracleFeed"));
    function ethTokenOracleFeed() public view returns (AggregatorV3Interface) { return AggregatorV3Interface(_ethTokenOracleFeed.read()); }

    /// @dev The token that the keeper is paid in
    Token18Storage private constant _keeperToken = Token18Storage.wrap(keccak256("equilibria.root.UKept.keeperToken"));
    function keeperToken() public view returns (Token18) { return _keeperToken.read(); }

    /// @notice Initializes the contract
    /// @param ethTokenOracleFeed_ The legacy Chainlink feed that is used to convert price ETH relative to the keeper token
    /// @param keeperToken_ The token that the keeper is paid in
    function __UKept__initialize(
        AggregatorV3Interface ethTokenOracleFeed_,
        Token18 keeperToken_
    ) internal onlyInitializer {
        _ethTokenOracleFeed.store(address(ethTokenOracleFeed_));
        _keeperToken.store(keeperToken_);
    }

    /// @notice Called by the keep modifier to raise the optionally raise the keeper fee
    /// @param amount The amount of keeper fee to raise
    /// @param data Arbitrary data passed in from the keep modifier
    function _raiseKeeperFee(UFixed18 amount, bytes memory data) internal virtual { }

    /// @notice Placed on a functon to incentivize keepers to call it
    /// @param multiplier The multiplier to apply to the gas used
    /// @param buffer The fixed gas amount to add to the gas used
    /// @param data Arbitrary data to pass to the _raiseKeeperFee function
    modifier keep(UFixed18 multiplier, uint256 buffer, bytes memory data) {
        uint256 startGas = gasleft();

        _;

        uint256 gasUsed = startGas - gasleft();
        UFixed18 keeperFee = UFixed18Lib.from(gasUsed)
            .mul(multiplier)
            .add(UFixed18Lib.from(buffer))
            .mul(_etherPrice())
            .mul(UFixed18.wrap(block.basefee));

        _raiseKeeperFee(keeperFee, data);

        keeperToken().push(msg.sender, keeperFee);

        emit KeeperCall(msg.sender, gasUsed, multiplier, buffer, keeperFee);
    }

    /// @notice Returns the price of ETH in terms of the keeper token
    /// @return The price of ETH in terms of the keeper token
    function _etherPrice() private view returns (UFixed18) {
        (, int256 answer, , ,) = ethTokenOracleFeed().latestRoundData();
        return UFixed18Lib.from(Fixed18Lib.ratio(answer, 1e8)); // chainlink eth-usd feed uses 8 decimals
    }
}
