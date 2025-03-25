// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/Kept/Kept_Optimism.sol";

contract MockKept_Optimism is Kept_Optimism {
    address public benefactor;

    constructor(address benefactor_) {
        benefactor = benefactor_;
    }

    /// @dev This event helps us test that `data` is being passed around correctly
    event RaiseKeeperFeeCalled(UFixed18 amount, bytes data);

    function initialize(AggregatorV3Interface ethTokenOracleFeed_, Token18 keeperToken_) external initializer(1) {
        super.__Kept__initialize(ethTokenOracleFeed_, keeperToken_);
    }

    function _raiseKeeperFee(UFixed18 amount, bytes memory data) internal override returns (UFixed18) {
        emit RaiseKeeperFeeCalled(amount, data);
        keeperToken().pull(benefactor, amount);
        return amount;
    }

    function toBeKept(
        UFixed18 multiplierBase,
        uint256 bufferBase,
        UFixed18 multiplierCalldata,
        uint256 bufferCalldata,
        bytes calldata applicableCalldata,
        uint256 value,
        bytes memory data
    )
        external
        keep(KeepConfig(multiplierBase, bufferBase, multiplierCalldata, bufferCalldata), applicableCalldata, value, data)
    { }

    /// @dev This function is used to figure out what gasUsed is. We can't hardcode this
    /// @dev in tests because it depends on whether we're running coverage or not.
    function instrumentGas() external returns (uint256) {
        uint256 startGas = gasleft();
        emptyFunc();
        return startGas - gasleft() - 24;
    }

    function emptyFunc() internal {}
}
