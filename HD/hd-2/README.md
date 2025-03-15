# HD-2: Delegation Boost for Enhanced Staking

## Feature Overview
A new **Delegation Boost** mechanism has been introduced in the staking module, allowing delegators to deposit additional tokens (in a specialized "boosted" pool) that increase their rewards proportionally. This addition brings several novel concepts, parameters, and message types to the Cosmos-based network.

## Motivation
Standard delegation involves delegators bonding tokens directly to validators, but previously had no way to “boost” or multiply their stake without simply adding more tokens in the same manner. **Delegation Boost** introduces a secondary stake pool that augments the staking power of a validator and potentially increases the delegator’s reward payout. This fosters deeper collaboration between delegators and validators and opens up new economic incentives in the network.

## Objectives
- **Provide Flexible Staking Options:** Enable a dedicated method to “boost” stake in addition to normal delegation, with potential for higher rewards.
- **Enforce Minimum Boost Requirements:** Allow validators to specify a `min_delegation` as a threshold for boosted delegation.
- **Enable Enhanced Reward Calculations:** Incorporate boosted delegations into reward distribution using a flexible multiplier defined by a network parameter (`BoostPercentage`).
- **Streamline Staking Flows:** Maintain a clear distinction between regular staked tokens and boosted tokens, with dedicated messages for deposit and withdrawal.

## Key Features

1. **Boosted Pool Account**  
   - A new module account (`boosted_tokens_pool`) holds tokens delegated as a boost.
   - Ensures clear tracking and isolation of boosted tokens from regular staked tokens.

2. **Boost Ratio & Rewards Multiplier**  
   - The distribution module calculates a “boost ratio” for a validator by comparing its total boosted stake to its overall staked amount.
   - A configurable `BoostPercentage` parameter governs how much of a multiplier this ratio adds to the rewards.

3. **Validator-Based Settings**  
   - **`min_delegation`**: A validator can specify the minimum boost required for delegators.
   - **`delegate_authorization`**: Determines whether anyone other than the validator can add a boosted delegation.

4. **New Message Types**  
   - **`DelegateBoost(...)`**: Delegates tokens to the boosted pool, tracked separately from normal staking.
   - **`UnDelegateBoost(...)`**: Withdraws boosted tokens, reducing the delegation’s effective multiplier.

5. **Enhanced Store and Queries**  
   - New keys and indexing in the staking keeper track total boosts for each validator and each (delegator, validator) pair.
   - Functions like `GetTotalBoostedDelegation` and `GetValidatorDelegationsBoost` enable easier lookups of boosted stakes.

6. **Genesis & Parameter Integration**  
   - The chain’s genesis process now initializes the `boosted_tokens_pool` and parameters such as `BoostPercentage`.
   - Operators can manage `BoostPercentage`, `min_delegation`, and `delegate_authorization` via governance or direct configuration.

## Technical Implementation

- **Extended Staking Keeper Methods:**  
  - `DelegateBoost`, `UnDelegateBoost`, `SetDelegationBoost`, and `GetDelegationBoost` orchestrate storing boosted tokens and updating delegated amounts.
  - The keeper enforces `min_delegation` and `delegate_authorization` when delegations occur.

- **Modified Reward Distribution Logic:**  
  - Updated distribution code fetches a validator’s `boostedTotal` tokens, calculates a `boostRatio`, and multiplies the base rewards by `1 + (BoostPercentage * boostRatio)` (capped at a maximum of 1:1 ratio for the boost portion).

- **New Proto Definitions:**  
  - `MsgCreateValidator` and `MsgEditValidator` now include `min_delegation` and `delegate_authorization`.
  - Messages for delegating/undelegating boosts are defined and handle moving tokens to and from `boosted_tokens_pool`.

- **Module Accounts & Balances:**  
  - All boosted tokens are transferred to the `boosted_tokens_pool` account via the Cosmos SDK’s Bank module.
  - On undelegation, tokens are properly returned to delegators.

## Acceptance Criteria
- [x] **Boosted Delegations:** Delegators can deposit additional tokens and have them reflected in higher potential rewards.  
- [x] **Minimal Impact on Existing Delegations:** Regular staking remains unaffected; boosted delegation is purely additive.  
- [x] **Validator Constraints:** Validators can enforce a minimum boost requirement, and can restrict who is allowed to boost.  
- [x] **Reward Calculation Updates:** The distribution module correctly calculates rewards with a `boostRatio` multiplier, respecting the `BoostPercentage` parameter.  
- [x] **Secure Fund Handling:** Tokens are transferred securely to the `boosted_tokens_pool` and only returned on undelegation.  
- [ ] **Documentation & User Guide:** Provide detailed instructions for validators and delegators on enabling, delegating, and withdrawing boosts.

## Documentation
- **Developer References:** Covers all new messages (`DelegateBoost`, `UnDelegateBoost`), relevant keeper methods, and store keys.  
- **Validator Setup:** Explains configuring `min_delegation` and `delegate_authorization`.  
- **Reward Mechanics:** Describes the boost ratio calculation, capped multiplier, and the distribution flow for boosted rewards.  
- **Governance:** Outlines how parameters like `BoostPercentage` may be updated through governance proposals.  

By integrating **Delegation Boost**, Helios enhances the overall staking experience, introducing novel opportunities for delegators and validators alike to optimize their on-chain economic strategies while maintaining network security and stability.
