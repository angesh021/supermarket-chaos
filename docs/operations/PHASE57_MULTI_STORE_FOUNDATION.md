# Phase 57 — Multi-store foundation

## Current status
Architecture decisions, schema v37-to-v39 profile foundations, and unique world-container support are implemented. `WorldBuilder.build(locationId, origin)` validates the server-supplied ID, uses a location-specific world model and can position it independently. The profile preserves the v36 flat state as `locations.neighborhood` and now allows one optional, validated `locations.uptown` record under the same owner lease. The current `ShiftService` still starts only one state/world/owner for the server; no second branch is playable yet.

## Target acceptance criteria
- One player can own at least two independently managed store locations under the same account and company balance.
- Each location has separate shift progress, shelf/backstock, upgrades, employees, warehouse and business stock/sales. Changing location never copies or resets either location's state.
- Each location has an isolated world, customers, prompts and status snapshots. Activity in one does not mutate the other location's stock, shift, or local sales counters.
- Helpers request and receive access for a specific location; a Manager at one branch gains no authority at another branch without a separate grant.
- Existing profile state migrates once into the stable `neighborhood` location ID without changing the cash balance, stock, pending shipment, active shift, upgrades or progression counters.
- Profile writes from two location runtimes remain serialized under one player lease. Rejoin restores both locations; a second server cannot take the same profile lease.

## Remaining implementation increments
1. Add the server-priced branch purchase and fixed uptown plot, using the Phase 61 synchronized company wallet.
2. Extract one location runtime from the singleton `ShiftService`, and scope action authorization and client snapshots to that runtime.
3. Add per-location membership grants and test same-owner writes, branch switching, rejoin and unauthorized cross-branch actions.

## Security and persistence boundaries
- The client may request an action within a visible store, but cannot create location IDs, choose another owner's profile, or supply the location's stock, cash or upgrade state.
- Server-owned runtime lookup must resolve the location before checking its Owner/Manager/Cashier/Stocker permissions, current prompt, distance and cooldown.
- The DataStore key and session lease remain per player. A single serialized profile writer prevents two branches from overwriting one another.
- Schema v39 allows exactly two known location IDs, keeps balance at the company profile root and validates the optional second snapshot through normal profile normalization. See `operations/PHASE60_LOCATION_PROFILE_STORAGE.md` for migration and malformed-record checks.
- Migration preserves a recovery path until v36-to-v39 data is validated in a private development experience. Production publishing and Robux commerce remain disabled.

## Manual verification gate
No branch purchase checklist can be run yet. Once the implementation steps above are complete, verify in the private development universe:
1. Migrate a v36 profile and compare before/after balance, all six SKU stocks, pending shipment, shift stage/sales, owned upgrades, employees and plaza business state.
2. Open the second branch. Change its stock, cash through valid sales, and shift state; confirm the original branch remains unchanged.
3. Run two branch actions close together and verify both save without lost updates. Leave/rejoin and compare both locations.
4. Grant a helper Manager access to one branch only. Verify they can manage it and cannot use another branch's prompts/remotes.
5. Start a second server for the same player and confirm the existing per-profile lease rejects conflicting ownership or writes.

### Legacy location migration check
1. Load a known v36 profile and record balance, shift stage/sales, all SKU inventory and shipment, upgrades, employees, layouts, business stock/sales and progression counters.
2. Let the profile save through the development DataStore. Confirm the profile reports schema v39 and contains exactly one `locations.neighborhood` record until a branch is purchased.
3. Rejoin and compare the recorded values. Balance and location state must be unchanged; the snapshot must agree with the legacy fields used by the current runtime.
4. Confirm a fresh/session-only profile also has the default neighborhood record and remains playable when DataStore access is unavailable.
5. In an isolated local migration harness, add an unknown ID, a third location, a malformed `uptown` record, or a `neighborhood` value divergent from the flat profile. Confirm normalization rejects it without silently selecting or merging a location.

No Studio result is claimed until these steps are observed and recorded.
