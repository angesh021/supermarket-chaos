# ADR-0061: Move purchased core store fixtures

- **Status:** Accepted; implementation and Studio verification status tracked in `docs/operations/PHASE64_MOVABLE_CORE_FIXTURES.md`.
- **Context:** The retail layout editor already repositions merchandise departments and checkout. The purchased shelf bay and household aisle remain fixed, so expansion purchases do not support a consistent store-planning workflow.
- **Decision:** Persist the two allow-listed fixture transforms in retail layout version 4. Only the Owner or Manager may move owned fixtures through server validation. The server pivots its own Models and parented signs.
- **Consequences:** Existing layout versions normalize with fixture defaults without changing profile schema. Placement checks must include owned fixtures when moving merchandise shelves, checkout, bakery/freezer departments, or another fixture. Studio migration and multiplayer checks remain a release gate.
- **Verification:** See `docs/operations/PHASE64_MOVABLE_CORE_FIXTURES.md`.

