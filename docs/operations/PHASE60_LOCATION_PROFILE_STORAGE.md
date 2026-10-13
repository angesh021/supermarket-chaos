# Phase 60 — Multi-location profile storage

## Acceptance criteria
- The player profile may contain the original `neighborhood` location and one server-approved additional `uptown` record; unknown IDs and extra records are rejected.
- Each location record has its own shift, upgrades, employees, warehouse, layout, prices and progression snapshot. `ProfileService.getLocation` returns a defensive copy, `getCompanyBalance` reads the shared root balance, and `saveProgress` can update only an existing known location.
- The company balance remains at the profile root. Both locations are serialized under the same player lease and the existing per-profile save lock.
- Schema v39 migrates v38 profiles without changing their neighborhood snapshot or company balance. Existing v37 profiles still migrate through the exact legacy neighborhood snapshot check.
- No branch purchase, live runtime, shared in-memory wallet, branch switching, or location-scoped helper access is claimed by this increment.

## Security and failure handling
- Location IDs are a server-side allow-list: `neighborhood` and `uptown`. The client does not choose a profile key or submit a location record.
- A caller cannot create an arbitrary location. `createLocation` only accepts `uptown`, only once, and seeds it from server defaults. Purchase cost/prerequisites are not implemented in this storage increment.
- On load, the neighborhood must match the legacy profile projection. The additional snapshot is normalized with all normal profile validators and must match the normalized result exactly; malformed, divergent, unknown, or unsupported records fail profile loading instead of being silently merged.
- Branch writes require an existing location and share the same `UpdateAsync` lease/save lock as neighborhood writes. Callers must not use a branch runtime until it supplies the synchronized company balance; that runtime is still pending.

## Manual migration checklist
Use the private development universe `10770581249` and a known v38 profile.

1. Record company balance and neighborhood shift, stock, upgrades, employees, layouts, business inventory/sales and progression.
2. Load and save under v39. Confirm there is still exactly one `locations.neighborhood` record and its contents and balance match the recorded values.
3. Rejoin and compare the same values. Confirm `getLocation("neighborhood")` is read-only by mutating a returned copy and checking the next read is unchanged.
4. In an isolated local migration harness, add an unknown location ID, malformed `uptown` record, or extra location; confirm profile normalization rejects it. Confirm two valid location records are accepted only when each is internally normalized.
5. Invoke server-side location creation concurrently twice for `uptown`. Confirm it creates one default snapshot and never resets the record after the first creation.
6. Confirm DataStore-unavailable/session-only behavior remains playable and does not claim persistence.

## Verification status
- Static checks are recorded in `docs/PROJECT_STATUS.md`.
- Roblox Studio/DataStore migration, malformed-record rejection and accessor isolation are pending. Do not test a branch runtime yet; it is not implemented.
