// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../storage/UStorage.sol";
import "../control/unstructured/UInitializable.sol";
import "./interfaces/IKept.sol";

// TODO: actually read decimals for eth oracle
// TODO: 18 or 6? token or ufixed?

abstract contract UKept is IKept, UInitializable {
    /// @dev The legacy Chainlink feed that is used to convert price ETH relative to the keeper token
    AddressStorage private constant _ethTokenOracleFeed = AddressStorage.wrap(keccak256("equilibria.root.UKept.ethTokenOracleFeed"));
    function ethTokenOracleFeed() public view returns (AggregatorV3Interface) { return AggregatorV3Interface(_ethTokenOracleFeed.read()); }

    /// @dev The token that the keeper is paid in
    Token18Storage private constant _keeperToken = Token18Storage.wrap(keccak256("equilibria.root.UKept.keeperToken"));
    function keeperToken() public view returns (Token18) { return _keeperToken.read(); }

    function __UKept__initialize(
        AggregatorV3Interface ethTokenOracleFeed_,
        Token18 keeperToken_
    ) internal onlyInitializer {
        _ethTokenOracleFeed.store(address(ethTokenOracleFeed_));
        _keeperToken.store(keeperToken_);
    }

    function _raiseKeeperFee(UFixed18 amount, bytes memory data) internal virtual { }

    modifier keep(UFixed18 multiplier, uint256 buffer, address feeReceiver, bytes memory data) {
        uint256 startGas = gasleft();

        _;

        uint256 gasUsed = startGas - gasleft();
        UFixed18 keeperFee = UFixed18Lib.from(gasUsed)
            .mul(multiplier)
            .add(UFixed18Lib.from(buffer))
            .mul(_etherPrice())
            .mul(UFixed18.wrap(block.basefee));

        _raiseKeeperFee(keeperFee, data);

        keeperToken().push(feeReceiver, keeperFee);

        emit KeeperCall(feeReceiver, gasUsed, multiplier, buffer, keeperFee);
    }

    function _etherPrice() private view returns (UFixed18) {
        (, int256 answer, , ,) = ethTokenOracleFeed().latestRoundData();
        return UFixed18Lib.from(Fixed18Lib.ratio(answer, 1e8)); // chainlink eth-usd feed uses 8 decimals
    }
}
