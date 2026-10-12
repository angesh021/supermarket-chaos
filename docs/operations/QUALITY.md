# Quality checks and manual test plan

## Automated source checks
| Check | Command/tool | Outcome |
|---|---|---|
| Formatting | `stylua --check src` | Not run in this turn: executable returned `ERROR home directory not found` |
| Luau lint | `selene src` | Not run in this turn: executable returned `ERROR home directory not found`; API signature coverage is limited by the offline custom standard |
| Rojo mapping/build | `rojo build default.project.json -o build.rbxlx` | Not run in this turn: executable returned `ERROR home directory not found`; verifies mapping, not Studio runtime |
| GitHub Actions | `.github/workflows/phase0.yml` | Parses project JSON and checks required documentation files; does not run Luau checks |

Roblox Studio runtime and persistence cannot be exercised from the local shell. Report them as verified only after a manual Studio run.

## Phase 1 manual verification
- [x] User confirmed desktop first shift: cart, stock visuals, customer, sale, shift close, visible upgrade and HUD behavior.
- [ ] Device emulation/touch targets and mobile safe areas.
- [ ] Multiplayer behavior and security checks; Phase 3 will define helper roles.

## Phase 2 / G2 manual verification
- [x] User reported all requested Phase 2 tests passed.
- [ ] Preserve any deeper multi-server conflict/shutdown testing not covered by the user's confirmed checklist as future persistence hardening.

## Phase 3/4 manual verification gate
- [ ] In the private development universe `10770581249`, request store access from a second account and approve each role.
- [ ] Verify Stocker can stock only, Cashier can check out only, Maintenance can recover the cart only, and Manager can perform all shift actions.
- [ ] Verify owner can decline/remove helpers; removed members lose permissions; server rejects a fifth player from joining the store.
- [ ] Confirm helper actions update the owner's store and profile without creating a second writable profile.
- [ ] Earn $100, hire the cashier, and verify visual appearance, cost, and save/rejoin persistence.
- [ ] Earn $80, hire the stock clerk, and verify visual appearance, cost, and save/rejoin persistence.
- [ ] On the next shift, confirm the stock clerk stocks exactly once after the cart objective. Test the player stock race.
- [ ] On the next shift, confirm the cashier sells exactly once after a short delay when stocked. Test the player checkout race.
- [ ] In a non-development universe, confirm `SESSION ONLY` and that development DataStore writes are never attempted.
- [ ] Confirm a visitor without a team role does not receive the owner's cash/stock/sales values; approved helpers see the shared operational counters.

Capture any exact Output errors and report the failing checklist number. G3/G4 remain pending until these Studio checks are completed.
