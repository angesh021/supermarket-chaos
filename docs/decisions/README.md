# Architecture decision records

Record decisions that change product scope, trust boundaries, persistence, dependencies, deployment, or data contracts. Each record includes context, decision, alternatives, consequences, verification needs and date. Keep unresolved items open until evidence supports a choice.

## ADR-0001 — Keep Phase 0 limited to the foundation
- **Status:** Accepted — 2026-10-12
- **Context:** The master brief defines G0 as architecture/foundation approval and requires stopping before Phase 1.
- **Decision:** Establish the documentation and project scaffold, assess local tooling, and stop for G0 review. Do not add gameplay implementation in this milestone.
- **Consequences:** Runtime assumptions remain proposed; Phase 1 may revise them after Studio/toolchain validation.

## ADR-0002 — Player-owned store profiles
- **Status:** Accepted — 2026-10-12; see [ADR-0002](ADR-0002-player-owned-store-profiles.md).
- **Decision:** Persistent progression belongs to an individual Roblox player. The first player in a server owns that server's one store; multiplayer helpers and role permissions are a Phase 3 feature.

## ADR-0003 — Persistent warehouse expansion
- **Status:** Accepted — 2026-10-12; see [ADR-0003](ADR-0003-persistent-warehouse-expansion.md).
- **Decision:** Add a server-validated $200 warehouse annex as the first Phase 7 increment; persist ownership per player and rebuild its procedural world model on load.

## ADR-0004 — Serialize profile saves
- **Status:** Accepted — 2026-10-12; see [ADR-0004](ADR-0004-serialize-profile-saves.md).
- **Decision:** Serialize DataStore writes for each player profile so gameplay, autosave and release writes cannot overlap for the same in-memory entry.

## ADR-0005 — Keep warehouse deliveries server-authoritative
- **Status:** Accepted — 2026-10-12; see [ADR-0005](ADR-0005-warehouse-delivery-loop.md).
- **Decision:** Persist backstock and one pending shipment; the server charges, times, validates and receives the shipment.

## ADR-0006 — Keep customer traffic bounded and server-owned
- **Status:** Accepted — 2026-10-12.
- **Context:** The first shift had one static customer and one sale, which did not establish a customer operations loop.
- **Decision:** Each shift serves at most three customers using a server-scripted entrance, browse, queue, checkout and exit route. The server's existing sale transition owns stock and revenue; the persisted sales count reconstructs remaining customer traffic.
- **Consequences:** No customer persistence fields, PathfindingService loops or client remotes are needed. Fixed routes are bounded and have a 12-second queue-position recovery. Product choice, baskets and larger traffic events remain later increments.
- **Verification:** See `docs/operations/PHASE8_CUSTOMERS.md`; Roblox Studio runtime checks remain pending.

## ADR-0007 — Persist chaos interruptions in the shift stage
- **Status:** Accepted — 2026-10-12.
- **Context:** A temporary event must survive player rejoin without trusting client event state or adding unnecessary event records.
- **Decision:** The checkout spill is represented by the versioned `Spill` shift stage. The server owns eligibility, role authorization, cleanup reward and resume transition. Profile schema v5 admits this stage; older profile shapes migrate through the existing normalizer.
- **Consequences:** The event has no client remote, deadline or destructive failure state. If cleanup is delayed, the queue waits safely until an authorized player resumes it. Customer Rush and Power Outage require separate eligibility and recovery rules before implementation.
- **Verification:** See `docs/operations/PHASE9_CHAOS.md`; persistence and Studio runtime checks remain pending.
