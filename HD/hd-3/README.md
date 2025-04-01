**HD-3: Smart Contract Creator Incentives**

---

### **Feature Overview**

Introduce a configurable fee-sharing mechanism that allocates a portion of transaction fees to smart contract creators whose contracts are actively used during block execution. By default, creators receive **10% of transaction fees**, but this percentage can be adjusted via governance. The system can also be toggled on or off through governance without affecting the underlying metadata about contract usage.

---

### **Motivation**

Smart contract developers are at the heart of innovation in decentralized ecosystems. Despite this, current gas fee structures (such as EIP-1559) offer no direct compensation to creators for the usage of their contracts. This discourages long-term protocol development and innovation.

The proposed incentive model creates a built-in, protocol-level mechanism to reward creators based on actual usage of their deployed contracts, fostering developer engagement, ecosystem health, and network utility.

---

### **Objectives**

- Provide a native, transparent way to reward smart contract creators for active on-chain usage.
- Align developer incentives with protocol growth.
- Reduce reliance on external funding, grants, or off-chain monetization.
- Allow governance to manage:
    - The incentive percentage.
    - The enable/disable state of the distribution logic.
- Ensure toggling the feature off preserves all historical creator and usage data for potential re-enablement.

---

### **Key Features**

- **Usage-Based Rewards:** Smart contracts involved in transaction execution result in a reward share to their original deployers.
- **Governance-Controlled Percentage:** Default set to 10%, modifiable by governance through parameter updates.
- **Governance Toggle:** Feature can be enabled or disabled at the protocol level without deleting creator records.
- **Non-Destructive Disablement:** Turning off the incentive mechanism stops revenue distribution but retains all contract metadata.
---

### **Technical Implementation**

- Identification of smart contracts executed per transaction (via internal EVM call tracing).
- Attribution of executed contracts to their original `msg.sender` at deployment (`CREATE`, `CREATE2`).
- Post-processing logic to redirect a configurable portion of transaction fees to the creator address.
- Parameter module integration for:
    - `enable_revenue` (bool)
    - `developer_shares` (in decimal basis points, e.g. 0.100000000000 for 10%)
- Logic hook  integrated at the fee accounting level (post-EVM execution, pre-burn).
- Contracts with unknown or nonstandard deployment origins are excluded from attribution.

---

### **Acceptance Criteria**

- [x] Contract creators receive 10% of fees by default for executed contracts.
    
- [x] Percentage is adjustable via governance.
    
- [x] Incentive feature can be toggled on/off via governance.
    
- [x] Creator attribution works reliably for standard contract deployments.
    
- [x] Non-destructive toggling preserves creator metadata.
    
- [x] No impact on contracts not used during transaction execution.
    
- [x] Events emitted when incentive payments are made (`types.EventTypeDistributeDevRevenue` ).
    
- [x] Unit tests covering key flows: execution tracking, attribution, payout, governance updates.
    
- [x] Integration tests simulating real-world transactions and fee splitting.
    
- [x] Complete developer documentation on deployment patterns, fee accounting, and governance control.
    
---

### **Documentation**

- Full developer documentation to be published under
    
    [Smart Contract Creator Incentives](https://hub.helioschain.network/docs/innovate/advanced-use-cases/)
    
    with examples, API behavior, governance guide, and integration best practices.
    