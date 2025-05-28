# HIP-4: External Data Call Support via Hyperions

## Feature Overview

This HIP introduces the capability for smart contracts on the Helios blockchain to initiate and receive data from external blockchains, such as Ethereum, using the Hyperion module and relayer infrastructure. The new system enables secure, verifiable, and programmable cross-chain calls with callback support, forming the foundation for decentralized oracle operations and cross-chain composability.

## Motivation

Helios aims to position itself as a highly interoperable blockchain platform. Enabling smart contracts to fetch and verify data from other blockchains significantly expands their utility and paves the way for cross-chain DeFi, external oracle integrations, and decentralized automation.

This proposal introduces a full lifecycle of external data requests, including:

* A precompile interface callable from smart contracts
* Transaction creation and management through the Hyperion module
* Execution, validation, and attestation through orchestrators
* Callback and refund mechanisms

## Objectives

* Allow smart contracts to request external blockchain calls with callback execution
* Provide secure and auditable data fetching infrastructure with validator attestation
* Support gas fees and refunds to incentivize fair relay and execution
* Make the system configurable through governance for gas pricing and resource limits

## Key Features

### Precompile: `requestData`

A Solidity-accessible function defined at a fixed precompile address (e.g., `0x000...0900`) exposes the `requestData` function:

```solidity
function requestData(
    uint64 chainId,
    address contractAddress,
    bytes calldata abiCall,
    string calldata callbackSelector,
    uint256 maxGasPrice,
    uint256 gasLimit
) external payable returns (uint256 taskId);
```

This call:

* Validates parameters and user balance
* Reserves execution fee via `SendCoinsFromAccountToModule`
* Schedules a Chronos job for callback
* Constructs and stores an `OutgoingExternalDataTx` in the Hyperion module

### External Call Lifecycle

1. **Request Submitted:** The smart contract calls `requestData`.
2. **Cron Job Scheduled:** Chronos schedules a callback to the contract.
3. **Relayer Fetches:** A registered Hyperion relayer fetches the external call data.
4. **Validator Attestation:** Validators vote on the result.
5. **Threshold Reached:** Upon reaching quorum, data is finalized and callback triggered.
6. **Callback Execution:** The smart contract's `callBack(bytes data, bytes err)` function is invoked.
7. **Reward Distribution:** Orchestrators are rewarded from the initial fee.
8. **Refund:** Expired or invalid transactions are refunded.

### Governance Parameters

* `MinCallExternalDataGas`: Minimum required gas limit for a valid external data call
* `HyperionFeePercentage`: Portion of fee to reward orchestrators
* `MaxCallbackDelay`: Max block delay before automatic refund

## Technical Implementation

* **New Module Code:** `external_data.go` manages transaction creation, storage, refund, reward, and deletion.
* **EndBlock Hook:** `executeAllExternalDataTxs()` is called to check for quorum and execute validated calls.
* **Relayer Integration:** Added logic in Hyperion Program to fetch results and submit claims.
* **Chronos Integration:** Callback logic with storage of result and error in `CronCallBackData`.
* **Contract Verification:** Ensures ABI callback exists before transaction is accepted.

## Acceptance Criteria

* Smart contracts can successfully initiate and receive data from external blockchains via the precompile.
* A quorum of validators finalizes the call after attesting to the result.
* The requested callback is executed in Chronos only after validation.
* Callback errors and results are correctly routed and stored.
* Relayers are able to fetch and submit data in a timely and secure manner.
* The system auto-refunds expired or invalid calls.

## Example

A smart contract requests ETH/USD price data from Ethereum and updates its state:

```solidity
function fetchETHPrice() external {
    address source = 0x...;
    bytes memory encodedData = abi.encodeWithSignature("last_price(uint256)", 0);
    string memory callback = "callBack";
    uint256 maxGasPrice = 10 gwei;
    uint256 gasLimit = 20_000_000 wei;

    uint256 taskId = HyperionRequestor.requestData(
        11155111, // Ethereum Sepolia
        source,
        encodedData,
        callback,
        maxGasPrice,
        gasLimit
    );
}

function callBack(bytes memory data, bytes memory err) public {
    require(err.length == 0);
    uint256 price = abi.decode(data, (uint256));
    updatePrice(price);
}
```

## Documentation

Full documentation will be published under `docs/` and include:

* Precompile interface and ABI specs
* Supported chain configurations
* Chronos and Hyperion params
* Relayer setup guide
* Security model for quorum-based validation
* Fee calculations and governance toggles

## Governance Proposal

Title: Enable External Data Call Infrastructure
Summary: Enable support for cross-chain external data calls with Hyperion module, relayer, and callback support.
Initial Parameters:

* `MinCallExternalDataGas`: 2,000,000
* `HyperionFeePercentage`: 50%
* `MaxCallbackDelay`: 100 blocks

## Status

* Draft

## Authors

* Helios Core Dev Team

---

HIP-4 lays the foundation for oracle operations and programmable cross-chain logic. By establishing a reliable, auditable, and contract-accessible interface for external data calls, Helios expands the scope of smart contracts to include real-world and interchain data in a decentralized manner.
