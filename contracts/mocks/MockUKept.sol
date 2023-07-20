// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../control/unstructured/UOwnable.sol";
import "../keeper/UKept.sol";

contract MockUKept is UKept, UOwnable {
    /// @dev This event helps us test that `data` is being passed around correctly
    event RaiseKeeperFeeCalled(UFixed18 amount, bytes data);

    function initialize(AggregatorV3Interface ethTokenOracleFeed_, Token18 keeperToken_) external initializer(1) {
        super.__UKept__initialize(ethTokenOracleFeed_, keeperToken_);
        super.__UOwnable__initialize();
    }

    function _raiseKeeperFee(UFixed18 amount, bytes memory data) internal override {
        emit RaiseKeeperFeeCalled(amount, data);
        keeperToken().pull(owner(), amount);
    }

    // UFixed18 multiplier, uint256 buffer, address feeReceiver, bytes memory data
    function toBeKept(UFixed18 multiplier, uint256 buffer, address feeReceiver, bytes memory data) keep(multiplier, buffer, feeReceiver, data) external {}
}
