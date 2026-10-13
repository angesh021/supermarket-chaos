# ADR-0033: Persist a fixed rear store expansion

- **Status:** Accepted
- **Context:** The main-floor shelves and checkout can be repositioned, but the supermarket footprint remains fixed. Building the next department space needs a clear prerequisite, a visible structure, and a server-owned persistent purchase.
- **Decision:** After the household aisle expansion, allow the Owner/Manager to spend `$500` once for an allow-listed rear wing. Remove the center portion of the back wall to form a wide opening, build a tiled enclosed extension with simple lighting and signage, and permit the four existing shelves to be moved into a bounded rear zone. Customer movement enters and exits that zone through a center waypoint. Profile schema v22 stores ownership; the server checks ownership for all rear-zone shelf placements.
- **Consequences:** Legacy profiles migrate with the wing unowned and retain existing shelf coordinates. No new product inventory or client-selected building parts are introduced. Studio review is needed for construction visuals, navigation, migration and touch layout.
- **Verification:** See `docs/operations/PHASE35_REAR_FLOOR_EXPANSION.md`.
