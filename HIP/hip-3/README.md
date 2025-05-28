# HIP-3: Smart Contract Creator Incentives

---

## Feature Overview

Introduce a protocol-level incentive mechanism that rewards smart contract creators with a configurable share of transaction fees when their contracts are executed during block processing. The system defaults to allocating **10%** of the transaction fee to the creator, with governance-enabled control to modify or disable the distribution logic without affecting historical metadata or creator attribution.

---

## Motivation

The success of Helios depends on the active participation of smart contract developers. Under the current fee structure, developers do not receive any share of the fees generated when their contracts are used — despite driving value and activity on the network. This HIP proposes a protocol-native way to compensate creators for their contributions in proportion to actual on-chain usage.

Such a system aligns economic incentives, promotes long-term developer commitment, and encourages the deployment of more robust and innovative smart contracts directly on Helios.

---

## Objectives

- Implement an automated, usage-based revenue-sharing mechanism for smart contract creators.
- Allow governance to manage:
    - The incentive percentage (default 10%).
    - The on/off state of the feature.
- Ensure toggling the system off **does not erase** on-chain tracking of creator metadata or usage history.
- Promote sustainability and self-incentivized developer participation.

---

## Key Features

- **Dynamic Fee Sharing:** A fixed share of transaction fees is routed to the original deployer (creator) of a smart contract if it is invoked during execution.
- **Governance Parameter Control:**
    - `enable_revenue` (bool): Enables or disables fee routing.
    - `developer_shares` (math.LegacyDec, e.g., 0.100000000000 = 10%): Defines fee share percentage in basis points.
- **Secure Attribution:** Uses the original `msg.sender` during contract deployment to identify the creator.
- **Non-Destructive Disabling:** When turned off, no further revenue is routed, but historical data and attribution remain intact for future potential reactivation.
- **Upgradeable Architecture:** Easily extensible for future enhancements like usage-based weighting or team-level revenue sharing.

---

## Technical Implementation

- **Execution Tracing:** The block processing engine traces all contracts invoked in a transaction’s execution path.
- **Creator Lookup:** The system maps each contract’s address to the original deployer address stored at deployment time.
- **Fee Redirection:** Before burning or redistribution, 10% of the transaction fee is routed to the contract creator.
- **Governance Configuration:**
    - Incentive parameters are stored and updated through the parameter module.
    - Governance proposals can update the parameters or disable the feature entirely.
- **Module Integration:** Likely implemented as part of the fee handling logic or a new standalone incentives module.

---

## Acceptance Criteria

- [x]  Smart contract creators receive 10% of transaction fees by default when their contracts are executed.
- [x]  Governance can modify the reward percentage (in basis points).
- [x]  Governance can enable or disable the incentive logic.
- [x]  Attribution mechanism reliably identifies creators of contracts deployed via `CREATE` and `CREATE2`.
- [x]  Revenue routing occurs only when a contract is actively used in a transaction.
- [x]  System emits `types.EventTypeDistributeDevRevenue` events with attributes including sender address, contract address, withdrawer address, and fee amount for transparency.
- [x]  When disabled, metadata about contract creators is retained.
- [x]  Thorough unit and integration testing validate the entire flow.
- [x]  Full documentation describing incentive logic, governance control, edge cases, and integration best practices.

---

## Documentation

- Detailed developer documentation will be published under
    
    [Smart Contract Creator Incentives](https://hub.helioschain.network/docs/innovate/advanced-use-cases/)
    
    and will include:
    
    - Governance configuration guide.
    - Developer expectations and earnings logic.
    - Creator tracking methodology and known limitations.
    - Examples and RPC endpoints to query incentive-related data.