# ADR-0057: Store bounded location snapshots under one profile lease

- **Status:** Accepted; schema/storage foundation implemented, branch runtime pending.
- **Context:** Phase 57 established a single `locations.neighborhood` snapshot, but profile loading and copying discarded every non-neighborhood location and `getLocation` could only read that one ID.
- **Decision:** Allow exactly two server-known IDs (`neighborhood`, `uptown`). Keep the company balance and session lease at profile root; store location-owned operations in normalized snapshots. Serialize all writes through the same profile `UpdateAsync` lock.
- **Consequences:** Schema v39 preserves the v38 neighborhood record and validates any `uptown` record against existing profile normalization. This API alone does not make a second branch playable; purchase, synchronized company wallet, runtime, switching and location-scoped roles remain required.
- **Verification:** See `docs/operations/PHASE60_LOCATION_PROFILE_STORAGE.md`.
