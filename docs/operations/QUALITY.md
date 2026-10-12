# Quality checks and manual test plan

## Automated source checks
| Check | Command/tool | Outcome |
|---|---|---|
| Formatting | `stylua --check src` | Not run in this turn: executable returned `ERROR home directory not found` |
| Luau lint | `selene src` | Not run in this turn: executable returned `ERROR home directory not found`; API signature coverage is limited by the offline custom standard |
| Rojo mapping/build | `rojo build default.project.json -o build.rbxlx` | Not run in this turn: executable returned `ERROR home directory not found`; verifies mapping, not Studio runtime |
| GitHub Actions | `.github/workflows/phase0.yml` | Parses project JSON and checks required documentation files; does not run Luau checks |

Roblox Studio runtime and persistence cannot be exercised from the local shell. Report them as verified only after a manual Studio run.

## How to run the Studio checklist later
1. Pull the latest source from `main` with `git pull origin main`.
2. Open PowerShell in the repository folder and run `rojo serve default.project.json`. Leave that terminal open.
3. In Roblox Studio, open the private development experience in universe `10770581249`, then choose **Plugins → Rojo → Connect** and enter host `localhost`, port `34872`.
4. Use **Test → Start** for multi-client checks; use one player for solo progression and touch device emulation for phone/tablet checks. Keep Studio's **Output** window visible.
5. Enable **Studio Access to API Services** only in the private development experience when doing persistence checks. Never use production data for these tests. The future production universe ID has not been supplied.
6. For profile tests, disable Studio API access or run in an unpublished/local universe to check the `SESSION ONLY` fallback. Record the checklist item number and exact Output errors for any failure.

The alternative is to build `rojo build default.project.json -o build.rbxlx`, open that file in Studio, and press **Play**. Live sync is preferable when testing changes from this repository.

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

## Phase 7 warehouse manual verification
- [ ] Reach `Complete` with the first shelf upgrade owned and at least $200 remaining.
- [ ] Attempt the warehouse pad with less than $200; confirm the balance and world stay unchanged and the HUD explains the shortfall.
- [ ] As owner or Manager, buy the warehouse once; confirm exactly $200 is deducted, the annex appears on the reserved plot, and the prompt disables.
- [ ] Re-trigger/race the prompt and try the action as a Cashier, Stocker, Maintenance member and unapproved visitor; confirm no second charge or unauthorized purchase.
- [ ] Leave and rejoin the same private development test universe; confirm the annex returns and no additional charge occurs.
- [ ] In a non-development universe, confirm session-only messaging and no writes to the development profile.

Capture exact Output errors and report the failing checklist number. Phases 3/4, Phase 5 analytics, Phase 6 mobile behavior and Phase 7 warehouse behavior remain pending until these checks are completed.
