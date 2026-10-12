# Development backlog

G0 was approved on 2026-10-12. The user authorized continued phase implementation and will provide Studio verification at phase gates.

## Phase 0 — Foundation
- [x] Requirements, design, architecture, security model, traceability, setup and backlog.
- [x] Rojo project mapping, pinned tools, repository and CI structure.

## Phase 1 — First playable
- [x] Procedural supermarket blockout, first-shift objective HUD and server-owned shift flow.
- [x] Cart event, stocking, customer interaction, checkout, shift close and visible upgrade.
- [x] User-verified desktop Play Solo flow and corrected runtime/visibility issues.
- [ ] Verify mobile/device emulation and touch targets.
- [ ] Verify multiplayer interactions after Phase 3 roles exist.

## Phase 2 — Progression and persistence (implementation in progress; G2 pending)
- [x] Decide player-owned persistence and server store ownership in ADR-0002.
- [x] Add schema-versioned per-player profiles and UpdateAsync session leases.
- [x] Persist balance, in-progress shift, sales, completed shifts and the shelf upgrade.
- [x] Resume saved shift state and start repeat shifts from the shift board.
- [ ] Verify Studio DataStore access and save/rejoin behavior in a private test experience.
- [ ] Exercise profile-lock conflict, shutdown release, retry and session-only fallback.
- [ ] Extend the upgrade catalog, product inventory and store customization after G2 test feedback.

## Phase 3 — Cooperative multiplayer
- [ ] Invite/join workflow for a player's store.
- [ ] Server-owned roles and permission checks for guests/helpers.
- [ ] Shared objectives and additional bounded chaos events.
- [ ] Multi-client Studio verification.

## Later phases
- [ ] Phase 4: employees, automation, departments and customization.
- [ ] Phase 5: security hardening, persistence recovery, fair commerce and analytics.
- [ ] Phase 6: external beta, performance/mobile review, staging and release approval.
- [ ] Phase 7: additional businesses, warehouse, delivery and retail-empire expansion.
