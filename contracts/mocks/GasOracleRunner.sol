// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../gas/GasOracle.sol";

contract GasOracleRunner {
    IGasOracle public gasOracle;

    /// @dev Return result via event so that we can call `cost` without callstatic
    event Cost(UFixed18 cost);

    constructor(IGasOracle gasOracle_) {
        gasOracle = gasOracle_;
    }

    /// @dev Non-view wrapper around `cost`, so that tests will use a non-zero base fee
    function cost(uint256 value) external {
        emit Cost(gasOracle.cost(value));
    }
}
