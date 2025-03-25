
# HIP, HD and HG

We differentiate between **issue**, **HD** and **HIP**.

An overview of the HIPs and HDs can be found in the [OVERVIEW](https://helios-network.github.io/HIP/).

The lifecycle of a proposal should be:

1. create a [new issue](https://github.com/helios-network/HIP/issues) to register the intent to write an HD/HIP and its scope.
2. If 1. is approved (this may require some discussions), start writing an HD and create a PR for it using [this Draft](../../md-template.md).
3. The author MAY start an HIP using [this Draft](../../hip-template.md) in the same PR as the HD. However, doing so may slow down the governance approval of the HD. A preferred approach is to start with the HD, then await governance approval and only then start the HIP in a separate PR.

```mermaid
graph LR
    A[Idea: issue] --> B[Request: HD] --> C[Solution: HIP]
```

The [Glossary](https://github.com/helios-network/HIP/wiki/glossary) contains an alphabetically ordered list of terms used in this repository. 
In addition HG serves as a platform to define glossary terms, which are used in the HIPs and HDs.

> :bulb: For more information on the process in this repository, see also[HIP-0](./HIP/hip-0/README.md).

## Helios Desiderata (HD)

HDs serve to capture the **objectives** behind the **introduction** of a particular HIP. Any  

- _wish_,
- _requirement_, or
- _need_

related to HIPs should be documented as an HD and stored in the HD directory.

A **template with instructions** is provided at [hd-template](hd-template.md). See [HIP-0](./HIP/hip-0) for a definition of its functionality.

## Helios Improvement Proposal (HIP)

A **template with instructions** is provided at [hip-template](hip-template.md). See [HIP-0](./HIP/hip-0) for a definition of its functionality.

#### Deciding whether to propose

You **SHOULD** draft and submit an HIP, if any of the following are true:

- Governance for the relevant software unit or process requires an HIP.
- The proposal is complex or fundamentally alters existing software units or processes.

AND, you plan to do the work of fully specifying the proposal and shepherding it through the HIP review process.

You **SHOULD NOT** draft an HIP, if any of the following are true:

- You only intend to request a change to software units or processes without overseeing specification and review.
- The change is trivial. In the event that an HIP is required by governance, such trivial changes usually be handled as either errata or appendices of an existing HIP.

## Glossary and Helios Gloss (HG)

A template with instructions is provided at [mg-template](mg-template.md). See [HIP-15](./HIP/hip-15) for a definition of its functionality. See [HG-0](./HG/hg-0) for an example.

An alphabetically ordered list of terms is provided in the [glossary](https://github.com/helios-network/HIP/wiki/glossary).

HGs serve to capture the **definitions** of terms introduced in the HIPs and HDs. The creation of a new HG requires an HIP or HG (since new terms are introduced through the HIP or HG).

See [HG-0](./HG/hg-0) for an example to get started. A template is provided at [mg-template](mg-template.md).

## Files and numbering

An HIP/HD uses the PR number as the HIP/HD number. Note that PRs that do not introduce a new HIP/HD are also accepted. Thus, there will be gaps in the HIP/HD number sequence.

Each HIP, HD or HG is stored in a separate subdirectory with a name `mip-<number>`, `md-<number>` or `mg-<number>`. The subdirectory contains a `README.md` that describes the HIP, HD, or HG. All assets related to the HIP, HD or HG are stored in the same subdirectory.

An HIP/HD starts as **Draft**.

PRs that don't introduce a new HIP/HD are also accepted, for example HIPs/HDs can be updated. PRs that **Update** a HIP/HD should state so in the PR title, e.g. `[Update] HIP-....`.

**Parent-Child HIPs** are also supported. A child HIP is stored in a subdirectory of the parent HIP, named `mip-<number>.<index>`. The index is a number starting from 1. The child HIP should contain a `README.md` that describes the child HIP. For more information see [HIP-94](./HIP/mip-94).

## Status Terms

An HIP/HD is proposed through a PR. Each HIP/HD PR should have a status in the name in the form `[status] HIP/HD-x: ...`.

An HIP/HG should at all times have one of the following statuses:

- **Draft** - (set by author) An HIP/HD that is open for consideration. (It does not yet hold an HIP/HD number)
- **Review** - (set by author) The HIP/HD is under peer review. The HIP/HD should receive an **HIP/HD number**, according to the rules described in the [Files and numbering](#files-and-numbering) section. At this point the editor should be involved to ensure the HIP/HD adheres to the guidelines.

> :bulb: In case the editors are not available for an unacceptable long period of time, a reviewer should assume the role of the editor interim.

After acceptance the HIP/HD is merged into `main` and the branch should be deleted.

Additionally, the following statuses are used for HIPs/HDs that are not actively being worked on:

- **Stagnant** - an HIP/HD that has not been updated for 6 months. Upon this status the PR will be closed.
- **Withdrawn** - an HIP/HD that has been withdrawn.

Finally, an HIP/HD can also be updated:

- **Update** - (set by author) An HIP/HD is being updated. The title should list the HIP/HD number, e.g. `[Update] HIP-0 ...`.

## Style guide

#### Header convention

For headers it is recommended to use standard sentence structure, i.e. do not capitalize letters apart from the first word, specific terms or acronyms.

For example, use

```markdown
## This header is correct for Helios Labs' HIPs
```

Do not use

```markdown
## This Header is Incorrect for Helios Labs' HIPs
```

#### Capitalization convention

Ensure clarity and consistency in distinguishing between internal components and general roles. When referring to specific entities within our system, capitalize their names. Use lowercase when referring to general roles or concepts. For example:

- **Relayer** refers to our specific relayer, while **relayer** refers to any agent performing relaying.  
- **Validator** refers to our designated validators, while **validator** is a general term for any entity validating transactions.  

#### Note boxes

Avoid using

```markdown
> [!NOTE]
> ...
```

or

```markdown
!!! note ...
```

or

```markdown
::: note ... :::
```

These do not render correctly either in the GitHub preview or in the rendered markdown. Instead use emojis to indicate the type of note, e.g.

```markdown
\> 👀 Note, that ...
\> :warning: This is a warning ..
\> :bulb: Here is something to learn ..
```

## Governance

For more information on the role of the governance, see [HIP-0: Governance](./HIP/hip-0/README.md#governance).

Currently the governance consists of [@jguyet](https://github.com/jguyet).

## Code owners

An author commits to becoming the owner of the HIP/HD they propose. This means that for any future changes to the HIP/HD the author will be notified.

The author MUST add themselves as a code owner in [CODEWONERS](.github/CODEOWNERS).

## Copyright

Copyright and related rights waived via [CC0](LICENSE.md).
