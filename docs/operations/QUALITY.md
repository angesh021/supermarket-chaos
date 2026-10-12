# Quality checks and manual test plan

## Automated source checks
| Check | Command/tool | Outcome |
|---|---|---|
| Formatting | `stylua --check src` | Run for each code increment |
| Luau lint | `selene src` | Run for each code increment; API signature coverage is limited by the offline custom standard |
| Rojo mapping/build | `rojo build default.project.json -o build.rbxlx` | Run for each code increment; verifies mapping, not Studio runtime |
| GitHub Actions | `.github/workflows/phase0.yml` | Parses project JSON and checks required documentation files; does not run Luau checks |

Roblox Studio runtime and persistence cannot be exercised from the local shell. Report them as verified only after a manual Studio run.

## Phase 1 manual verification
- [x] User confirmed desktop first shift: cart, stock visuals, customer, sale, shift close, visible upgrade and HUD behavior.
- [ ] Device emulation/touch targets and mobile safe areas.
- [ ] Multiplayer behavior and security checks; Phase 3 will define helper roles.

## Phase 2 / G2 manual verification
- [ ] Use a private test experience and enable Studio API access there only.
- [ ] Start Play, confirm the HUD says `SAVE ON` rather than `SESSION ONLY`.
- [ ] Complete the first shift and buy the shelf. Stop Play and rejoin; confirm saved balance, completed shift, owned upgrade and the physical shelf load.
- [ ] Leave/rejoin midway at Cart, Stock, Checkout, CloseShift and Upgrade; confirm the current objective and balance resume without duplicate rewards.
- [ ] Use the shift board after completion; verify a repeat shift starts and saves once.
- [ ] Start the same account in another server while its profile is active; verify the second session cannot load a writable profile.
- [ ] Disable Studio API access on the private test experience; verify `SESSION ONLY`, local gameplay, and no overwrite of a stored profile.
- [ ] Stop a server and verify the final save releases the profile lease; verify a new session can load it.
- [ ] Add a second player and verify the visitor is read-only and does not change the owner's currency or shift.

Capture any exact Output errors and report the failing checklist number. G2 remains pending until these Studio checks are completed.
