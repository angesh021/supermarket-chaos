# ADR-0058: Share one in-memory company wallet across location states

- **Status:** Accepted; server wallet foundation implemented, multi-location runtime pending.
- **Context:** Location snapshots must not each persist a separate balance. If multiple states keep copied cash values, a save or sale in one location can overwrite another location's newer balance.
- **Decision:** Keep balance at the owner profile root and create one server wallet table per loaded profile. `Economy.newState` may proxy its `cash` property to that wallet; profile saves persist the current root wallet value while saving each location snapshot independently.
- **Consequences:** The existing neighborhood runtime uses this wallet. Any additional runtime must use the same server reference and must still serialize profile mutation and its own location transaction. This alone does not create a branch.
- **Verification:** See `docs/operations/PHASE61_COMPANY_WALLET.md`.
