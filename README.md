# Edgeless Contracts

## Getting Started

```sh
npm i --force
forge test
```
## Overview

### Background

#### User Deposit Flow
We need to be able to mint USDLR on Edgeless with USDC on any chain. The user deposit flow is as follows:

On Base
1. User onboards USDC via ZKP2P
2. User receives USDC in a 4337 wallet
3. 4337 wallet approves USDC to BaseReceiver
4. 4337 wallet calls BaseReceiver.forward()
5. BaseReceiver first receives USDC, then sends it to Stable.
6. BaseReceiver emits Forward(...) event
7. Off-chain, Stable listens for Forward and records the address and amount

On Edgeless
1. Stable's minter wallet mints amount to itself
2. Stable's minter wallet approves EdgelessMinter to spend amount
3. Stable's minter wallet calls EdgelessMinter.mint(to, amount) where metadata is from the Forward event
4. EdgelessMinter transfers USDLR from Stable's minter wallet to EdgelessMinter
5. EdgelessMinter sends USDLR from itself to the address

#### User Withdrawal Flow

On Edgeless:
1. User approves usdlr to EdgelessReceiver
2. User calls EdgelessReceiver.forward()
3. EdgelessReceiver receives USDLR, then sends it to Stable.
4. EdgelessReceiver emits Forward(...) event
5. Off-chain, Stable listens for Forward and records the address and amount

On Ethereum:
1. Stable's USDC custodian wallet approves EthereumMinter to spend amount
2. Stable's USDC custodian wallet calls EthereumMinter.mint(to, amount) where to and amount are from the Forward event.
3. EthereumMinter transfers USDC from Stable's USDC custodian wallet to EthereumMinter
4. EthereumMinter sends USDC from itself to `to`

# Contract Design

## Invariants

The following invariants should always be maintained within the contract:

- The amount of USDC received MUST EQUAL the amount of USDC sent in a single contract interaction
- The amount of USDLR received MUST EQUAL the amount of USDC sent in a single contract interaction
- The BaseReceiver and EdgelessMinter contracts SHOULD NOT HAVE ANY USDC or USDLR between transactions

## Usage

This is a list of the most frequently needed commands.

### Compile

Compile the contracts:

```sh
$ forge build
```

### Test

Run the tests:

```sh
$ forge test
```

### Deploy
1. Create a `.env` file according to `.env.example`
2. Modify the `namedAccounts` in `hardhat.config.ts`
3. Deploy to baseSepolia
`npx hardhat deploy --network baseSepolia`
4. Deploy to edgelessSepoliaTestnet
`npx hardhat deploy --network edgelessSepoliaTestnet`
