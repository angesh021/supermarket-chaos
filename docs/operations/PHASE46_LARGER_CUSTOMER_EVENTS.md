# Phase 46 — Larger customer events

## Acceptance criteria
- The existing server-derived Customer Rush starts only after the regular three sales and only when shelf stock can support all three bonus customers.
- A rush has six total customers, including three bonus customers; the physical customer capacity and both checkout lane queues support the full count.
- The rush has a persisted 90-second deadline. Serving all six before expiry grants exactly `$30`; expiry ends the event without that bonus and leaves the shift closable.
- Customer sales and deadline remain server-owned. Rejoin restores the remaining queue and timer without resetting or extending the event.
- Existing saved shift states remain readable; validation permits sales through six and in-progress rush sales through five without a profile schema bump.

## Server/client boundaries
- `Economy` defines event capacity, stock threshold, deadline and reward; checkout recomputes each basket and transitions to reward or close state.
- `ProfileService` validates the expanded bounded sales count and already-persisted rush deadline.
- `WorldBuilder` creates a sixth original procedural customer and a sixth staffed queue offset. When self-checkout is owned, server customer indexes distribute three customers to each lane.
- `ShiftService` reconstructs the queue from server sales/deadline and the existing checkout lane assignment. No client can trigger or extend the rush.

## Failure handling and limits
- If available shelf stock is below three units when the regular queue ends, no rush begins; the shift closes normally.
- If the timer expires, the server clears the rush deadline and grants no rush reward. Players can still close their shift.
- The event remains a bounded extension of Customer Rush; this phase does not add a new event type or seasonal schedule.

## Manual Roblox Studio verification checklist
1. On a profile with enough shelf stock, complete three regular sales. Confirm the rush starts with three more shoppers, a 90-second timer and a six-customer maximum.
2. With self-checkout, observe three customers assigned to each lane over the rush; confirm only each lane's front customer can be served.
3. Clear all three bonus customers before expiry. Confirm `$30` is credited exactly once and the shift moves to closeout.
4. Let the 90-second deadline expire. Confirm the rush closes without `$30`, the remaining queue is removed, and shift close is available.
5. Enter a rush with exactly three shelf units, then attempt sales that exhaust inventory. Confirm no negative stock, duplicate sale or stuck lane; restock through the allowed stock action if needed.
6. Rejoin mid-rush. Confirm queue count and deadline resume from saved sales and timestamp, with no timer extension or reward duplication.
7. Load an existing v28 profile with normal completed-shift state and confirm it loads unchanged. Confirm a saved in-progress rush with sales 3–5 is accepted.
8. Confirm impossible saved sales above six are rejected and malformed timer/state combinations remain rejected.
9. Repeat with self-checkout unowned and confirm all rush shoppers use the staffed lane.
10. Observe crowding at the entrance and checkout; verify customers do not block the entrance doors, warehouse, or active interaction prompts.

## Verification status
- StyLua 2.5.0 `--check src`: passed. Selene 0.32.0: 0 errors, 0 warnings, 0 parse errors. Rojo 7.7.0 build to `%TEMP%\\supermarket-chaos-phase46.rbxlx`: passed. `git diff --check`: passed with line-ending normalization warnings.
- Roblox Studio customer routes, lane behavior, event timer, payout, migration and save/rejoin: pending; no runtime success is claimed.
