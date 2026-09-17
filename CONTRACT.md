# DashBOrg Contract

## Authority

WordPress is the durable catalog. GitHub, filesystem, container runtime, and
browser checks are evidence sources linked to catalog records; none silently
replaces another.

## Identity

Accounts are authorization surfaces, not actors. Agent records name the acting
agent, card/deck assignment, harness, and authorization edges separately.

## Lifecycle

`observed -> claimed -> verified -> accepted -> stale`

Transitions require evidence. A successful workflow is not deployment
acceptance until the target runtime and user-facing surface are checked.

## Relationship vocabulary

- `agent works_in workspace`
- `workspace checks_out repository`
- `worktree tracks branch`
- `deployment ships revision_to environment`
- `evidence verifies subject`
- `event changes subject`

Relationships must be queryable in both the browser and REST API.

## Agent/human bridge

Human pages show current state, provenance, and the next action. REST responses
use stable IDs, explicit status, timestamps, and evidence links. Hooks may
append observations and events, but cannot convert an observation into an
accepted state without the required acceptance evidence.
