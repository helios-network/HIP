# HIP-1: Native On-chain Cron Scheduling (Chronos Module & Precompile)

- **Description**: Introduce a native cron scheduling module (**Chronos**) with a dedicated EVM precompile, allowing developers to schedule and automate periodic tasks directly on-chain within the Helios blockchain.
- **Motivation**: Decentralized applications often rely on external cron scheduling services, introducing complexity, reliability concerns, and potential security risks. A native cron scheduling system provides a decentralized, secure, and developer-friendly solution.

## Abstract

The Chronos module offers native cron job scheduling directly integrated into Helios blockchain through a dedicated EVM precompile, allowing for automated periodic execution of smart contract methods. This simplifies the creation and management of scheduled tasks, significantly enhancing decentralized application development.

## Motivation

Blockchain applications require periodic automated execution of smart contract methods. The existing external solutions are neither fully decentralized nor optimal in terms of security and efficiency. A built-in cron scheduling mechanism ensures reliability, decentralization, and seamless integration.

## Specification

### Key Features

- **Native Integration:** Implemented as an EVM-compatible precompile (`0x0000000000000000000000000000000000000830`).
- **Cron Job Management:** Includes functionalities for creating, updating, and canceling cron jobs.
- **Unique Cron Addresses:** Each cron job is assigned a unique blockchain address.
- **Gas Management:** Users deposit funds upon cron creation, covering continuous gas consumption (set at 100 gas per block) and executions costs.
- **Cron Lifecycle Events:** Emits blockchain events (`CronCreated`, `CronModified`, `CronCancelled`) for enhanced transparency.
- **Automatic Cancellation:** Cron jobs are canceled automatically when their balance reaches zero or a critical error occurs during execution.
- **Multiple RPC Endpoints:** RPC endpoints to take a look cron(s) (querying).

### Technical Implementation

- ABI provided for easy integration with popular web3 libraries such as Ethers.js.

## Acceptance Criteria

- [x] Cron tasks can be created, updated, and canceled effectively.
- [x] Each cron task has a unique blockchain address.
- [x] Funds deposited during cron creation accurately manage and consume gas (100 gas per block).
- [x] Cron jobs automatically cancel upon depletion of funds or errors.
- [x] Lifecycle events (`CronCreated`, `CronModified`, `CronCancelled`) accurately emitted.
- [x] Comprehensive unit and integration tests covering all key functionalities and edge cases.
- [x] Detailed developer documentation provided, including setup instructions, RPC endpoints, API usage, limitations, and best practices.
- [x] Successful cron task scheduling, execution, and lifecycle management.
- [x] Automatic cancellation behavior clearly defined and verifiable.
- [x] Robust documentation provided in [Chronos](https://hub.helioschain.network/docs/innovate/advanced-use-cases/).
- [x] Community feedback and peer reviews adequately addressed.

## Changelog

- 2025-04-14: Initiate the HIP-1
