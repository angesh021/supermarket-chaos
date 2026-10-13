# ADR-0068: Add a persistent retail expansion plot

- **Status:** Accepted — 2026-10-13.
- **Context:** The supermarket has movable, merchandised grocery aisles but no purchase path to expand the rear wing into another retail room.
- **Decision:** After rear-wing, warehouse and freezer ownership, allow the player to buy a fixed server-built rear room for `$900`. Keep retail layout version 6 and raise its constructed aisle cap from four to six only when the location owns the plot.
- **Consequences:** Schema v41 persists one plot-ownership flag per location and migrates v40 profiles as unowned. The server owns cost, prerequisites, bounds, collisions, aisle count and upkeep. The plot costs `$1` per completed shift in existing facility upkeep.
- **Verification:** See `docs/operations/PHASE75_RETAIL_EXPANSION_PLOT.md`; Studio purchase, migration, collision, customer routing and rejoin checks remain pending.
