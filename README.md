# DashBOrg LeagueOS

WordPress-based human and agent control plane for shared project work.

This repository claims the concrete `dashborg-of/LeagueOS` namespace. The
abstract contract remains `dashborg-of/dashborg-of`; this project is its
WordPress implementation.

## Design contract

DashBOrg must expose the same project truth to two audiences:

- humans through a normal WordPress browser surface;
- agents through authenticated REST endpoints and machine-readable hooks.

The browser is not a decorative build artifact, and an agent hook is not a
separate source of truth. Both read the same WordPress objects and evidence
records.

## First-class nouns

The initial plugin maps these nouns to WordPress custom post types:

`agent`, `harness`, `workspace`, `repository`, `worktree`, `branch`,
`environment`, `deployment`, `issue`, `pull_request`, `evidence`, and `event`.

Every record carries an explicit status and provenance fields. A claim is not
accepted merely because a branch name, lease file, or generated artifact says
it exists.

## Critique of the earlier DashBOrg sketch

The earlier DashBOrg viewer was useful as a visual telemetry sketch, but it
conflated exported state with live state, treated leases as proof of running
processes, and lacked a durable WordPress data model. It also had no explicit
relationship between source revision, worktree, container mount, deployment,
and rendered validation. This implementation keeps the useful browser/agent
duality while moving authority into inspectable WordPress records.

## Development

Install the plugin from `wp-content/plugins/dashborg-leagueos/` in a disposable
WordPress instance. Activate it, then inspect `/wp-json/dashborg/v1/health`
and `/wp-json/dashborg/v1/catalog`.
