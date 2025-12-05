// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";

import { Airdrop } from "../src/distribution/Airdrop.sol";
import { PROTOCOL_MULTISIG_ADDRESS } from "./Constants.sol";

// Command to deploy the airdrop contract:
// forge script script/Airdrop.s.sol --rpc-url $ETH_RPC_URL --sender $DEPLOY_ADDRESS --keystore $KEYSTORE_PATH
// --broadcast --verify --etherscan-api-key $EXPLORER_API_KEY -vvv
contract AirdropScript is Script, Test {
    function run() public {
        vm.startBroadcast();

        // deploy airdrop contract
        // Note: Deployer address will become the owner of the contract
        Airdrop airdrop = new Airdrop();

        // set pending owner to protocol multisig
        airdrop.updatePendingOwner(PROTOCOL_MULTISIG_ADDRESS);

        vm.stopBroadcast();

        // check owner is the deployer address
        assertEq(airdrop.owner(), msg.sender, "Owner should be the deployer address");

        // check pending owner is the protocol multisig
        assertEq(airdrop.pendingOwner(), PROTOCOL_MULTISIG_ADDRESS, "Pending owner should be the protocol multisig");

        // ensure no distributions are added
        assertEq(airdrop.merkleRoots().length, 0, "Merkle roots should be empty");

        console.log("Airdrop deployed at", address(airdrop));
    }
}