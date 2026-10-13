# ADR-0060 — Move built expansion departments

- **Status:** Accepted — 2026-10-13.
- **Context:** Bakery and freezer fixtures were server-built and purchasable but fixed in place. The retail editor could move core shelves, while the master specification calls for department construction and repositionable objects.
- **Decision:** Add bounded bakery/freezer placements to retail layout version 3. Owner/Manager may move only a department the profile already owns, on the expanded rear floor, using the existing server-validated layout station.
- **Consequences:** Department Models carry their existing stock prompts, tags, signs and visuals as they move; route targets use the saved placement. Layout normalization migrates v1/v2 to defaults without a profile schema bump. Arbitrary client-supplied models remain disallowed.
- **Verification:** See `docs/operations/PHASE63_EXPANSION_DEPARTMENT_LAYOUT.md`. Static checks are required; Studio pivot, route, save/rejoin and permission tests remain pending.
