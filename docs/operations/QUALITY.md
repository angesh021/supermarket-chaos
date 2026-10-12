# Quality checks and manual test plan

## Current checks
| Check | Command/tool | Status |
|---|---|---|
| Git status | `git status --short --branch` | Passed after initializing the workspace repository; no commit created |
| Rojo version/build | `rojo --version`; `rojo build default.project.json -o build.rbxlx` | Rojo 7.7.0; build passed |
| Luau lint | `selene src` | Selene 0.32.0; passed with local Roblox globals standard. API/property checks use generic globals and are limited. |
| Formatting | `stylua src`; `stylua --check src` | StyLua 2.5.0; passed |
| Studio runtime | Roblox Studio Play Solo/Start Server | Not available through current shell; manual Studio work required |

The initial `.github/workflows/phase0.yml` checks the Rojo JSON structure and required documentation paths. It does not lint Luau or exercise gameplay. CI has not run remotely.

`roblox_custom.yml` is an offline Selene standard: Luau syntax and generic Roblox globals are recognized, while detailed Roblox API signatures/properties are not checked. The project uses it because Selene's generated Roblox API standard attempted a network API-dump fetch that was unavailable in this environment.

Rojo build confirms source mapping, not script runtime correctness. Selene and StyLua checks passed. No Luau runtime or Studio integration tests are available in this environment; manual Studio procedures below remain unchecked.

## Manual Studio checklist for Phase 1
- [ ] First join, objective guidance, skip/resume and reward idempotency.
- [ ] Character movement and all interaction prompt/control paths.
- [ ] Stock, customer route, queue and checkout sale.
- [ ] Shift start, event warning/recovery, summary and end state.
- [ ] Upgrade affordability, ownership, visible change and duplicate requests.
- [ ] Start Server with multiple clients; verify assist permissions and isolation.
- [ ] Device emulation/touch hit targets, text scaling and safe-area layout.
- [ ] Save/reload and simulated persistence failures when persistence arrives.
- [ ] Performance profiling and memory/network observation on desktop and mobile hardware.
- [ ] Capture dated screenshots/video and record actual Studio/plugin/platform versions.
