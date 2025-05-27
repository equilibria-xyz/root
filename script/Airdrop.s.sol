// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { Airdrop } from "../src/distribution/Airdrop.sol";

// Command to deploy the airdrop contract:
// forge script script/Airdrop.s.sol --rpc-url $ETH_RPC_URL --sender $DEPLOY_ADDRESS --keystore $KEYSTORE_PATH --broadcast --verify -vvvv
contract AirdropScript is Script {
    function run() public {
        vm.startBroadcast();
        Airdrop airdrop = new Airdrop();
        vm.stopBroadcast();

        console.log("Airdrop deployed at", address(airdrop));
    }
}