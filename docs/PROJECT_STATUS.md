# Project status — 2026-10-12

## Summary
The user approved the G0 foundation and directed Phase 1 to begin. A first-shift playable source slice is implemented. It builds through Rojo and passes the configured StyLua and Selene checks. Studio runtime behavior and visuals have not been observed, so G1 is not passed.

## Deliverables
- Phase 0 docs: requirements, game design, onboarding, visual design bible, architecture, threat model, traceability, setup, quality plan and backlog.
- Server-owned first-shift rules, supermarket scene builder, prompt validation, checkout, shift close, rewards, and one visible shelf upgrade under `src/ServerScriptService/`.
- Client objective/economy HUD under `src/StarterPlayer/StarterPlayerScripts/`.
- Rojo 7.7.0 mapping; Selene 0.32.0 and StyLua 2.5.0 configuration; basic structure CI workflow.

## Toolchain assessment
- Detected and directly invoked: Rojo 7.7.0, Selene 0.32.0, StyLua 2.5.0, Node.js v22.18.0, Python 3.11.0.
- Added a project RoKit manifest pinning the installed tool versions. Run `rokit install` in the local project shell to set up its command shims.
- `rojo build default.project.json -o build.rbxlx`: passed.
- `stylua src` and `stylua --check src`: passed.
- `selene src`: passed with the checked-in custom offline Roblox globals standard. It checks Luau syntax and configured lints; API property validation is limited.
- Git repository initialized and `git status` works. Adding the supplied GitHub URL failed because this environment denies writing `.git/config`. No commit or push was made.
- No Luau CLI or Roblox Studio runtime was available to verify play behavior, physics, mobile UI, output logs or performance.

## Risks and open decisions
1. Fix Git HTTPS trust: `git ls-remote` currently fails with `SSL certificate problem: unable to get local issuer certificate`. Use a trusted CA bundle or proxy root certificate; keep TLS verification enabled.
2. Allow this workspace to write Git metadata under `.git` (the prior `git remote add` failed with permission denied on `.git/config`).
3. Inspect the remote branch and integrate any initial README/license commit before pushing local work; remote refs could not be read due the TLS error.
4. Run the Rojo project in Studio, inspect output/errors, and validate prompt/mobile behavior.
5. Review generated exterior/interior in gameplay camera; current geometry is procedural blockout-quality and has no custom mesh, icon, sound or animation assets.
6. Decide whether the first public session economy is shared team cash or per-player store ownership before persistence/multiplayer progression.
7. Decide persistence/session coordination and schema migration from current official DataStore guidance before Phase 2.
8. Profile actual part count, mobile frame time, memory and network traffic before setting performance budgets.

## Required manual actions
- Open Studio, use the Rojo plugin or built `build.rbxlx`, then run Play Solo.
- For live sync: start `rojo serve default.project.json`; in Studio connect the Rojo 7 plugin to `localhost:34872`.
- Walk through the cart, stocking, sale, shift close and upgrade objectives; fix any runtime/output errors and visually review the procedural scene.
- Check touch prompt behavior and HUD legibility with Studio device emulation.
- Attach GitHub remote and commit/push only after local changes are reviewable.

## Gate
**G0: approved by user on 2026-10-12. G1: pending Studio verification and visual review.** Production publishing and commerce are not configured and require later explicit approval.

## Current Phase 1 scope and limitations
The first shift runs as one cooperative, server-wide session with shared cash and one-time objectives. State resets when the server ends; no persistence or player-specific plots are implemented. The waiting customer is a static visual marker, and the cart is tweened; customer AI, audio, effects, skip/resume, repeat shifts, purchases and save data are not implemented. A Studio pass is required before calling this playable or G1 complete.
