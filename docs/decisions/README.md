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
