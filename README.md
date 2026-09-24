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

### Local LeagueOS WSL launcher

The local stack runs only through the native `LeagueOS` WSL Docker runtime.
Do not use Docker Desktop or the retired KPFM distro. The launcher requires a
native WSL worktree, a unique Compose project name, and an explicit port; it
rejects the reserved LeagueOS ports `8207` through `8210` and refuses a port
that is already listening.

Copy `.env.example` to an untracked `.env` in the native WSL worktree for
disposable local fixtures. The database and WordPress passwords in that file
are fixture values only. Staging and production must inject real credentials
through their approved secret/environment paths; this Compose stack is not a
deployment path and must never receive production secrets.

The launcher is invoked from PowerShell with the native WSL worktree path:

```powershell
.\scripts\bootstrap-local.ps1 `
  -ProjectName dashborg-galileo-local `
  -Port 18210 `
  -WslWorktree /var/lib/leagueos/candidate
```
