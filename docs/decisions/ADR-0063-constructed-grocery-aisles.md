# ADR-0063: Constructed grocery aisles

- **Status:** Accepted — 2026-10-13.
- **Context:** The supermarket needs to grow beyond fixed display furniture while preserving server-authoritative ownership, collision rules and per-player/per-location persistence.
- **Decision:** After the first shelf bay is purchased, allow the Owner/Manager to build up to four `$250` procedural grocery aisles. Store only bounded GUIDs and snapped transforms in retail layout version 5. Reuse the retail editor and server placement validation; require the rear expansion for rear-wing placements.
- **Consequences:** New aisles do not add stock, SKUs, prompts or customer sales behavior. All later layout moves must preserve aisle clearance. Versions 1–4 remain loadable with an empty aisle list; no profile schema migration is needed.
- **Verification:** See `docs/operations/PHASE67_CONSTRUCTED_GROCERY_AISLES.md`; Studio placement, permission, collision, migration and save/rejoin checks remain pending.
