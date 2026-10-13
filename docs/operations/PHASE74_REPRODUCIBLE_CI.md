# Phase 74 — Reproducible static CI

Run the project-pinned Luau formatter, linter, Rojo project build, project JSON check and documentation target check on pushes and pull requests. The workflow installs tools declared in `rokit.toml`; the Rokit setup action is pinned to a commit SHA. This is a source-validation job and does not contact Roblox publishing, DataStore, analytics, or commerce services.

## Acceptance criteria

- Pushes and pull requests run the same pinned StyLua, Selene and Rojo checks used by the repository.
- Formatting drift, lint errors, an invalid Rojo build, malformed project JSON or missing required documentation fails the job.
- The workflow has read-only repository permissions and has no publish/deploy steps or Roblox secrets.
- Rojo output goes to the runner temporary directory and is not committed or uploaded as a release artifact.
- No Studio runtime or DataStore behavior is reported as verified by this workflow.

## Security and failure handling

Workflow permissions are restricted to `contents: read`. `setup-rokit` is pinned to the published v3 commit and installs exact tool versions from `rokit.toml`. The action receives only the workflow's read-scoped GitHub token for tool downloads. Tool or build failures stop the job before documentation structure checks can produce a green result. There are no Roblox credentials, account secrets, publishing commands, paid products or deployment jobs.

## Verification

1. After pushing this phase, inspect GitHub Actions and confirm the `Project validation` workflow is scheduled and reports its individual tool/setup, format, lint, build, JSON, and documentation steps.
2. Review the job definition and confirm it requests `contents: read` only and contains no Roblox publish, upload, commerce or deployment step.
3. For later workflow changes, verify the runner uses `rokit.toml` and that the Rojo build output remains under `$RUNNER_TEMP`.

Local checks for this change are recorded in `docs/PROJECT_STATUS.md`. A completed local run does not prove GitHub hosted-runner success; that requires an observed Actions run.

## Observed result

The `Project validation` run [#38376711286](https://github.com/angesh021/supermarket-chaos/actions/runs/38376711286) completed successfully for commit `3e504742b6c8006adcfaefc987092b1936c36245` on 2026-10-13. This confirms the hosted runner installed the pinned toolchain and completed the configured workflow. Future workflow changes still require their own run.
