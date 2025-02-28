# HIP-0: Formalize Helios proposals

- **Description**: A process through which Helios Improvement Proposals standardize and formalize specifications for Helios Chain technologies.
- **Authors**: [Jeremy Guyet](mailto:jguyet@helioschainlabs.org)
- **Desiderata**: [MD-0](../../HD/hd-0)

## Abstract

This document formalizes the process through which Helios Improvement Proposals standardize and formalize specifications for Helios technologies, through HIPs (Helios Improvement Proposals), HDs (Helios Desiderata), and issues.

## Motivation

Helios Chain technologies continually evolve, and there's a need to ensure that the process of proposing and adopting changes is both organized and standardized. By establishing HIPs, we aim to facilitate the introduction of new features or improvements, making sure they are well-vetted, discussed, and documented. This ensures the integrity of Helios Chain technologies, making it easier for third parties to adopt and adapt to these changes.

## Specification

_The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174._

### Extensions to this HIP

We treat the following documents as extensions to this HIP:

- [root README](../../README.md)
- [HD template](../../hd-template.md)
- [HIP template](../../hip-template.md)
- [HG template](../../hg-template.md)

### High-level lifecycle

The lifecycle of a proposal should be

1. create a [new issue](https://github.com/helios-network/HIP/issues) to register the intent to write an HD/HIP and its scope.
2. If 1. is approved by governance (this may require some discussions), start writing an HD and create a PR for it using [this Draft](../../hd-template.md).
3. The author MAY start an HIP using [this Draft](../../hip-template.md) in the same PR as the HD. However, doing so may slow down the governance approval of the HD. A preferred approach is to start with the HD, then await governance approval and only then start the HIP in a separate PR.

#### Status terms

An HIP/HD is proposed through a PR. Each HIP/HD PR should have a status. For additional specification, see the [root README](../../README.md#status-terms).

### Roles

#### Governance

A governance body is responsible for overseeing the Helios Improvement Proposal process. This body is responsible for approving or rejecting proposals, and for ensuring that the process is followed correctly. The governance body is also responsible for maintaining the Helios Improvement Proposal repository, and for ensuring that the proposals are kept up-to-date.

#### Editor

The motivation for the role of the editor is to ensure the readability, layout correctness, and easy access of content. The editor is responsible for the final review of the HIPs. The editor is responsible for the following:

- Ensures a high quality of the HIPs/HDs, e.g. checking language while reviewing.
- Removes content from the HIPs/HDs that is commented out. (e.g. content within <!- -> brackets)
- Ensures the HIP/HD numbering is correct.
- Ensures the HIP/HD is in the correct status.
- Ensures the authors have added themselves to [CODEOWNERS](./.github/CODEOWNERS), see [Code owners](#code-owners).

The editor is NOT responsible for the content.

**Conflict resolution**: In the unlikely case, where an editor requests a change from an author that the author does not agree with and communication does not resolve the situation

- the editor can mandate that the author implements the changes by getting 2 upvotes from reviewers on their discussion comment mentioning the changes.
- Otherwise the author can merge without the editor requested change.

#### Code owners

An author commits to becoming the owner of the HIP/HD they propose. This means that for any future changes to the HIP/HD the author will be notified.

The author MUST add themselves as a code owner in [CODEWONERS](.github/CODEOWNERS).

### Proposal stages

The Helios Improvement Proposal process is divided into three stages: Issue, HD, and HIP.

#### Stage issue

Issues are used to propose trivial changes or improvements to Helios Chain technologies. They are used to discuss and document the rationale behind a proposed change, and to gather feedback from the community. Issues are not formalized and do not require a specific structure. They are used to gauge interest and to start discussions.

#### Stage HD

Helios Desiderate (HDs) are used to request new features, highlight new requirements, or propose new ideas. HDs are formalized and require a specific structure. They are used to provide a standardized means for requesting changes to Helios Chain technologies, and to guide in written structure and by facilitating engagement.

We provide a [template](../../md-template.md) for HDs, which should be used for specifying complex changes to Helios Chain technologies.

**Lifecycle**: An HD starts as a draft, after which it undergoes discussions and revisions. Once agreed upon, it moves to a 'published' status. An HD can also be deprecated if it becomes obsolete. The available statuses are listed in the [root README](../../README.md).

**Storage**: HDs should be stored in the [HDs directory](../../HD/). For each HD a separate directory should be created, containing the HD in markdown format, and any additional files required for the HD.

**Structure**: Each HD must adhere to [this template](../../md-template.md), which requires details like title, description, author, status, and more. An HD also includes sections like Overview, Desiderata and Changelog.

#### Stage HIP

Helios Improvement Proposals (HIPs) serve as a mechanism to propose, discuss, and adopt changes or enhancements to Helios Chain technologies. By providing a standardized and formalized structure for these proposals, HIPs ensure that proposed improvements are well-defined, transparent, and accessible to the wider community.

A Helios Improvement Proposal (HIP) is a design document that provides information to the Helios community, describing a new feature or improvement for Helios Chain technologies.

**Lifecycle**: An HIP starts as a draft, after which it undergoes discussions and revisions. Once agreed upon, it moves to a 'published' status. An HIP can also be deprecated if it becomes obsolete. The available statuses are listed in the [root README](../../README.md).

**Storage**: HIPs should be stored in the [HIPs directory](../). For each HIP a separate directory should be created, containing the HIP in markdown format, and any additional files required for the HIP.
  
**Structure**: Each HIP must adhere to [this template](../../hip-template.md), which requires details like title, description, author, status, and more. A HIP also includes sections like Abstract, Motivation, Specification, Reference Implementation, Verification, Changelog, and Appendix, see next.

**Section reference implementation**: A reference implementation or a sample HIP following the HIP template can be provided to guide potential proposers. This HIP (HIP-0) serves as a practical example, aiding in understanding the format and expectations.
  
**(Optional) section definitions**: Provide definitions that you think will empower the reader to quickly dive into the topic.

**Section verification**:

1. Correctness: Each HIP must convincingly demonstrate its correctness.

This HIP is correct insofar as it uses a structure established by Ethereum and Movement (fork) for Improvement Proposals which has hitherto been successful.

2. Security Implications: Each HIP should be evaluated for any potential security risks it might introduce to Helios technologies.

The primary security concern associated with this HIP is the exposure of proprietary technologies or information via the ill-advised formation of an HIP which the HIP process might encourage.

3. Performance Impacts: The implications of the proposal on system performance should be analyzed.

The primary performance concern associated with this HIP is its potential for overuse. Only specifications that are non-trivial and very high-quality should be composed as HIPs.

4. Procedures: To the extent possible, formal, analytical, or machined-aided validation of the above should be pursued.

I'm using spellcheck while writing this HIP. You can verify that I am using valid grammar by pasting this sentence into Google Docs.

5. Peer Review and Community Feedback: A section should be included that captures significant feedback from the community, which may influence the final specifications of the HIP.

The Helios Labs team is currently reviewing and assessing this process.

**Section Appendix**: The Appendix should contain references and notes related to the MIP.

**Section Changelog**: Post-publication changes, if any, to the HIP should be documented in this section. This ensures transparency and provides readers with accurate and up-to-date information.

## Changelog

- 2025-02-28: Add information about the process and structure of HDs.
