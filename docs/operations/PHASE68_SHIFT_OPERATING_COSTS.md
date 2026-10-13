# Phase 68 — Shift operating costs

## Goal and acceptance criteria

Add a predictable operating-cost schedule to the existing shift closeout, so store growth has a modest recurring cost alongside staff payroll. The server derives costs from already-persisted upgrades in the active location; there is no client-settable price and no profile schema change.

- The first shelf bay adds `$2` utilities per completed shift.
- A warehouse adds `$2`; a rear floor wing adds `$1`; each owned bakery/freezer adds `$1`; self-checkout adds `$1`; each constructed grocery aisle adds `$1` (at most four).
- Only owned assets incur their costs. The total is bounded at `$12` per shift and is shown to authorized store participants with payroll in the existing HUD/objective.
- Closeout applies the `$20` shift bonus, staff payroll, then operating costs in one server transition. It charges at most the nonnegative cash available after payroll; any shortfall is reported and does not become debt.
- A duplicate/stale closeout cannot charge twice. Only the resulting cash uses existing profile persistence; costs are re-derived from owned assets on the next shift.

## Server/client boundary and failure handling

`Economy.getShiftOperatingCosts` reads only the active server state and fixed server constants. `Economy.closeShift` checks its existing close-stage/idempotency guard and applies bonus, payroll and affordable upkeep before returning. `ShiftService` sends the derived total only to store members; the client presents the value and cannot submit or alter a charge. `ProfileService.saveProgress` persists the resulting balance through the existing serialized owner-profile write. No added expense can push cash below the value left by payroll; insufficient upkeep is reported as paid/total and forgiven rather than carried as debt.

## Manual Roblox Studio checklist — pending

Use the development experience and start with a profile whose balance/upgrades you can record.

1. Complete the first shift before buying the shelf bay. Confirm no operating cost is charged and the existing `$20` gross shift reward is unchanged.
2. Buy the shelf bay and complete a new shift with no staff. Confirm `$2` upkeep is charged and the HUD reports `$0 payroll + $2 upkeep`.
3. Add warehouse, rear wing, bakery, freezer, self-checkout, and one constructed aisle one at a time; close a shift after each purchase and confirm the exact marginal cost: `$2`, `$1`, `$1`, `$1`, `$1`, and `$1` respectively.
4. Build four aisles and verify the maximum operating cost is `$12` before payroll. Confirm unowned upgrades do not add costs.
5. Hire staff and verify wages are charged once in addition to upkeep; pause automation and verify the hired employee's wages remain.
6. Exercise an affordable closeout and compare starting cash, sales/rewards, payroll and upkeep with the final balance and the closeout message.
7. Use a low-cash profile with several employees/upgrades to exercise partial upkeep payment. Confirm paid/total is reported, balance is not reduced below the post-payroll amount by upkeep, and no unpaid debt appears next shift.
8. Attempt duplicate/stale close actions from two authorized players; only one closeout may charge. Confirm visitors cannot see payroll or operating-cost data.
9. Leave and rejoin after closeout, then complete the next shift. Confirm cash persists and the same ownership-derived cost applies exactly once per shift.
10. Repeat on the Uptown branch and verify its active location's assets determine its charge while company cash remains shared.

## Verification status

Static formatting, lint, Rojo mapping and whitespace checks are recorded after implementation in `docs/PROJECT_STATUS.md`. Studio closeout, concurrent requests, cash-boundary behavior and save/rejoin have not been run locally.
