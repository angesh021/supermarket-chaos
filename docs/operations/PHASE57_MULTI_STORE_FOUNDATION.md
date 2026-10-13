# Phase 57 — Multi-store foundation

## Current status
Architecture decision recorded; no multi-store runtime or profile migration is claimed as implemented. The current `ShiftService` has one state/world/owner for the server. The current profile schema v36 contains one flat location's stock, shift, upgrades and business inventory.

## Target acceptance criteria
- One player can own at least two independently managed store locations under the same account and company balance.
- Each location has separate shift progress, shelf/backstock, upgrades, employees, warehouse and business stock/sales. Changing location never copies or resets either location's state.
- Each location has an isolated world, customers, prompts and status snapshots. Activity in one does not mutate the other location's stock, shift, or local sales counters.
- Helpers request and receive access for a specific location; a Manager at one branch gains no authority at another branch without a separate grant.
- Existing profile state migrates once into the stable `neighborhood` location ID without changing the cash balance, stock, pending shipment, active shift, upgrades or progression counters.
- Profile writes from two location runtimes remain serialized under one player lease. Rejoin restores both locations; a second server cannot take the same profile lease.

## Planned implementation increments
1. Introduce a normalized location record and v37 migration from the existing flat profile to `locations.neighborhood`, with duplicate/unknown ID rejection and bounded location count. Do not add a purchasable branch in this migration step.
2. Extract one location runtime from the singleton `ShiftService`, parameterize `WorldBuilder` with a unique container/location ID, and scope action authorization and client snapshots to that runtime.
3. Add a server-priced branch purchase and a second fixed plot. Reuse the same profile save lock, but persist the branch's state independently.
4. Add per-location membership grants and test same-owner writes, branch switching, rejoin and unauthorized cross-branch actions.

## Security and persistence boundaries
- The client may request an action within a visible store, but cannot create location IDs, choose another owner's profile, or supply the location's stock, cash or upgrade state.
- Server-owned runtime lookup must resolve the location before checking its Owner/Manager/Cashier/Stocker permissions, current prompt, distance and cooldown.
- The DataStore key and session lease remain per player. A single serialized profile writer prevents two branches from overwriting one another.
- Migration preserves a backup/recovery path until v36-to-v37 data is validated in a private development experience. Production publishing and Robux commerce remain disabled.

## Manual verification gate
No branch purchase checklist can be run yet. Once the implementation steps above are complete, verify in the private development universe:
1. Migrate a v36 profile and compare before/after balance, all six SKU stocks, pending shipment, shift stage/sales, owned upgrades, employees and plaza business state.
2. Open the second branch. Change its stock, cash through valid sales, and shift state; confirm the original branch remains unchanged.
3. Run two branch actions close together and verify both save without lost updates. Leave/rejoin and compare both locations.
4. Grant a helper Manager access to one branch only. Verify they can manage it and cannot use another branch's prompts/remotes.
5. Start a second server for the same player and confirm the existing per-profile lease rejects conflicting ownership or writes.

No Studio result is claimed until these steps are observed and recorded.
