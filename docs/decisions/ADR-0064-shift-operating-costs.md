# ADR-0064: Derive recurring operating costs at shift close

- **Status:** Accepted — 2026-10-13.
- **Context:** The game already charges staff wages at closeout, but store facilities have no recurring operating cost. Costs should reflect a player's owned buildout without introducing another client-controlled transaction or saved ledger.
- **Decision:** Charge fixed utilities/upkeep at completed-shift close based on the active location's server-owned upgrades. Cap the schedule at `$12`; after payroll, collect no more than available nonnegative cash and forgive any unpaid remainder.
- **Consequences:** Existing profile cash is the only persisted result. Owned-upgrade flags are the source for future closeouts, and the existing `shiftClosed` guard prevents duplicate charges. No debt or new migration is introduced.
- **Verification:** See `docs/operations/PHASE68_SHIFT_OPERATING_COSTS.md`; Studio affordability, race, branch and save/rejoin checks remain pending.
