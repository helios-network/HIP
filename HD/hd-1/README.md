# HD-1: Chronos Module & Precompile

## Feature Overview

Implement a native cron scheduling module (**Chronos**) along with a dedicated EVM precompile, enabling developers to schedule and automate periodic tasks directly on-chain.

## Motivation

Blockchain-based applications often require periodic execution of smart contract methods. Currently, developers depend on off-chain solutions, introducing complexity and reliability concerns. A native, blockchain-integrated cron service simplifies automation and enhances the robustness and efficiency of decentralized applications.

## Objectives

- Provide an intuitive, efficient, and secure way to schedule periodic smart contract interactions.
- Reduce the reliance on external cron services or centralized schedulers.
- Enhance developer experience through seamless integration with smart contracts.

## Key Features

- **Native Integration:** Directly integrated into Helios blockchain as a precompile.
- **Easy Scheduling:** Simple API to schedule function calls with specified frequency, expiration, gas limits, and maximum gas price.
- **Reliability:** Guaranteed execution or clear state indication of failed executions.
- **Security:** Execution isolated within blockchain's native security context.
- **Unique Cron Addresses:** Each cron job has a unique blockchain address.
- **Gas Management:** Upon cron creation, funds are deposited to cover gas consumption (100 gas per block to keep the cron active).
- **RPC Endpoints:** Multiple RPC endpoints must be created to support cron interactions and management.
- **Cron Cancellation Conditions:** Crons are automatically canceled when their balance reaches zero or an execution failure occurs. Remaining funds (if any) at cancellation are returned to the owner, and an event is emitted indicating cancellation.

## Technical Implementation

- Dedicated EVM-compatible precompile address: `0x0000000000000000000000000000000000000830`.
- ABI included for straightforward integration with front-end libraries such as Ethers.js and Web3.
- Comprehensive unit and integration testing included.

## Acceptance Criteria

- [x] Ability to schedule and reliably execute cron tasks.
- [x] Ability to update and cancel existing cron tasks.
- [x] Cron tasks have unique blockchain addresses.
- [x] Funds deposited at cron creation are properly managed and consumed at the rate of 100 gas per block.
- [x] Cron tasks are automatically canceled and cleaned up when balance reaches zero or upon execution failure.
- [x] Events (`CronCreated`, `CronModified`, `CronCancelled`) emitted accurately reflecting cron job lifecycle.
- [x] Respect of gas limits and consumption rules as defined.
- [x] Clear and complete developer documentation.

## Documentation

- Detailed developer documentation available under [Chronos](https://hub.helioschain.network/docs/innovate/advanced-use-cases/).
