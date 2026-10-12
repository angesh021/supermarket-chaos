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
- Employees unlock on the `Complete` shift state. If necessary, repeat shifts until the profile has enough in-game cash for both hires ($180 total after any shelf purchase).
- Use a fresh test account for analytics if the current profile already owns the first shelf; the first-shift funnel is intentionally disabled once that upgrade is owned.
- [ ] In the private development universe `10770581249`, request store access from a second account and approve each role.
- [ ] Verify Stocker can stock only, Cashier can check out only, Maintenance can recover the cart only, and Manager can perform all shift actions.
- [ ] Verify owner can decline/remove helpers; removed members lose permissions; server rejects a fifth player from joining the store.
- [ ] Confirm helper actions update the owner's store and profile without creating a second writable profile.
- [ ] At a completed shift with enough balance, hire the cashier for $100 and stock clerk for $80. Confirm each visual, exact charge, and save/rejoin persistence.
- [ ] On the next shift, confirm the stock clerk stocks exactly once after the cart objective. Test the player stock race.
- [ ] On the next shift, confirm the cashier sells exactly once after a short delay when stocked. Test the player checkout race.
- [ ] In a non-development universe, confirm `SESSION ONLY` and that development DataStore writes are never attempted.
- [ ] Confirm a visitor without a team role does not receive the owner's cash/stock/sales values; approved helpers see the shared operational counters.
- [ ] In development Creator Dashboard analytics, confirm first-shift funnel milestones appear in order; confirm a non-development universe does not emit this funnel. Roblox attributes events to the Player supplied to AnalyticsService; the game sends no custom fields.
- [ ] Use Studio device emulation for a narrow phone and tablet: objective card starts collapsed at top center, expands/collapses, team panel fits/closes, and role controls can be tapped without covering movement/jump controls.

Capture any exact Output errors and report the failing checklist number. Phase 3/4, Phase 5 analytics and Phase 6 mobile behavior remain pending until these checks are completed.
