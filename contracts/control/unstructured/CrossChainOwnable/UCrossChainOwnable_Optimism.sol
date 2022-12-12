// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/crosschain/optimism/CrossChainEnabledOptimism.sol";
import "./UCrossChainOwnable.sol";

/**
 * @title UCrossChainOwnable_Optimism
 * @notice Library to manage the cross-chain ownership lifecycle of upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance. This contract
 *      is specific to the Optimism L2-side and should not be used on other chains.
 *
 *      See {UCrossChainOwnable} for initialization and update usage.
 */
abstract contract UCrossChainOwnable_Optimism is CrossChainEnabledOptimism, UCrossChainOwnable {
    /// @dev System address for the CrossDomainMessenger. This address is ONLY valid on the L2 side
    address public constant L2_CROSS_DOMAIN_MESSENGER_ADDRESS = address(0x4200000000000000000000000000000000000007);

    constructor() CrossChainEnabledOptimism(L2_CROSS_DOMAIN_MESSENGER_ADDRESS) {}
}
