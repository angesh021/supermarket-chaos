# ADR-0049 — Plaza-wide style customization

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 4 includes plaza customization. The four fixed plaza shops need a shared visual identity without accepting arbitrary client colors or model edits.
- **Decision:** After Little Sprout Garden, Owner/Manager can preview Coastal Walk, City Lights or Harvest Lane and install one palette for `$750` during a completed shift.
- **Consequences:** Profile schema v33 stores a single allow-listed palette ID. Preview is transient. Installation changes the awnings, roofs, signs and plaza paths for all built shops; no geometry or gameplay state changes.
- **Verification:** See `docs/operations/PHASE51_PLAZA_CUSTOMIZATION.md`; Studio visuals, permission, migration and save/rejoin checks remain pending.
