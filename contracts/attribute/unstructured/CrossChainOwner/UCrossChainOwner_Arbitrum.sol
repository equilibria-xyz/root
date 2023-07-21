// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CrossChainOwnable/UCrossChainOwnable_Arbitrum.sol";
import "./UCrossChainOwner.sol";

/**
 * @title UCrossChainOwner_Arbitrum
 * @notice Contract to act as an owner of other contracts
 * @dev This contract is designed to act as an owner of any Ownable contract, allowing
 *      Cross Chain Ownership without modification to the underlying ownable contract. This contract
 *      is specific to the Arbitrum L2-side and should not be used on other chains.
 *
 *      See {UCrossChainOwner} for initialization and usage.
 */
contract UCrossChainOwner_Arbitrum is UCrossChainOwner, UCrossChainOwnable_Arbitrum { }
