# Forge Scripts

This directory contains Forge scripts for deploying and interacting with smart contracts. Below are instructions on how to configure your environment, and run scripts

---

## Prerequisites

Before executing any scripts, ensure the following environment variables are defined in a `.env` file:

```env
# Required Environment Variables
ETH_RPC_URL=
KEYSTORE_PATH=
DEPLOYER_ADDRESS=
EXPLORER_API_KEY=
```

These values are used to authenticate transactions, specify the deployment account, and enable contract verification.

---

## Running Forge Scripts

Use the following command structure to execute a script:

```bash
forge script <script_path> \
  --rpc-url $ETH_RPC_URL \
  --keystore $KEYSTORE_PATH \
  --sender $DEPLOYER_ADDRESS \
  --broadcast \
  --verify \
  --etherscan-api-key $EXPLORER_API_KEY
```

Replace `<script_path>` with the path to the desired script.

### Flags Used
- `--sender`: Specifies the address that will send the transaction.
- `--rpc-url`: Sets the RPC URL for the target network.
- `--keystore`: Path to the keystore file used for signing transactions.
- `--broadcast`: Sends the transaction to the network.
- `--verify`: Verifies the contract on a network explorer after deployment.
- `--etherscan-api-key`: API key for contract verification on network explorer.

Reference: https://book.getfoundry.sh/guides/scripting-with-solidity

## Available Scripts:
- [Airdrop](./Airdrop.s.sol)
    ```bash
    forge script script/Airdrop.s.sol \
    --rpc-url $ETH_RPC_URL \
    --keystore $KEYSTORE_PATH \
    --sender $DEPLOYER_ADDRESS \
    --broadcast \
    --verify \
    --etherscan-api-key $EXPLORER_API_KEY
    ```