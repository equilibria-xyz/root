// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/Kept.sol";

contract MockKept is Kept {
    address public benefactor;

    constructor(address benefactor_) {
        benefactor = benefactor_;
    }

    /// @dev This event helps us test that `data` is being passed around correctly
    event RaiseKeeperFeeCalled(UFixed18 amount, bytes data);

    function initialize(AggregatorV3Interface ethTokenOracleFeed_, Token18 keeperToken_) external initializer(1) {
        super.__UKept__initialize(ethTokenOracleFeed_, keeperToken_);
    }

    function _raiseKeeperFee(UFixed18 amount, bytes memory data) internal override {
        emit RaiseKeeperFeeCalled(amount, data);
        keeperToken().pull(benefactor, amount);
    }

    function toBeKept(UFixed18 multiplier, uint256 buffer, bytes memory data) keep(multiplier, buffer, data) external {}

    /// @dev This function is used to figure out what gasUsed is. We can't hardcode this
    /// @dev in tests because it depends on whether we're running coverage or not.
    function instrumentGas() external returns (uint256) {
        uint256 startGas = gasleft();
        emptyFunc();
        return startGas - gasleft() - 24;
    }

    function emptyFunc() internal {}
}
