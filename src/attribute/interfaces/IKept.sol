// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../interfaces/IInitializable.sol";
import "../../number/types/UFixed18.sol";
import "../../token/types/Token18.sol";

interface IKept is IInitializable {
    struct KeepConfig {
        UFixed18 multiplierBase;
        uint256 bufferBase;
        UFixed18 multiplierCalldata;
        uint256 bufferCalldata;
    }

    event KeeperCall(address indexed sender, uint256 applicableGas, uint256 applicableValue, UFixed18 baseFee, UFixed18 calldataFee, UFixed18 keeperFee);

    function ethTokenOracleFeed() external view returns (AggregatorV3Interface);
    function keeperToken() external view returns (Token18);
}
