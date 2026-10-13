# Requirements traceability

| ID | Requirement | Design artifact | Verification | State |
|---|---|---|---|---|
| FR-01 | First-session cart interaction and immediate reward | `design/FIRST_SESSION.md` | Solo Studio test; duplicate reward and skip/resume cases | Implemented; Studio pending |
| FR-02 | Stock fictional product and serve customer | `design/GAME_DESIGN.md` | Stock/serve loop test with feedback | Implemented; Studio pending |
| FR-03 | Complete checkout sale | `architecture/ARCHITECTURE.md` | Server transaction and client feedback test | Implemented; Studio pending |
| FR-04 | Complete one shift and chaos event | `design/GAME_DESIGN.md` | Start/event/summary/end state test | Implemented; Studio pending |
| FR-05 | Buy visible first upgrade | `requirements/PRODUCT_REQUIREMENTS.md` | Eligibility, balance, replay and world-change test | Implemented; Studio pending |
| FR-06 | Server authority and request validation | `security/THREAT_MODEL.md` | Forgery, ownership, flood, replay tests | Planned |
| NFR-01 | Usable desktop and touch UI | `design/VISUAL_DESIGN_BIBLE.md` | Studio device emulation/manual mobile test | HUD/prompt scaffold; Studio pending |
| NFR-02 | Cohesive, readable small supermarket | `design/VISUAL_DESIGN_BIBLE.md` | Art gate in gameplay camera/screenshots | Procedural blockout; visual gate pending |
| NFR-03 | Recoverable versioned progression | `architecture/ARCHITECTURE.md` | Failure, migration, save/reload tests | Planned |
| FR-07 | Per-player profile, saved shift and owned upgrade recovery | `decisions/ADR-0002-player-owned-store-profiles.md`, `architecture/ARCHITECTURE.md` | Save/rejoin, two-server lease conflict, failure fallback, shutdown | Implemented; Studio DataStore verification pending |
| STORE-EXP-002 | Persistent warehouse backstock, priced delivery order and exactly-once receipt | `decisions/ADR-0005-warehouse-delivery-loop.md`, `architecture/ARCHITECTURE.md` | `operations/PHASE7_DELIVERY.md` | Implemented; Studio verification pending |
| CUSTOMER-OPS-001 | Three-customer bounded checkout queue with server-priced sales and saved shift reconstruction | `decisions/README.md`, `architecture/ARCHITECTURE.md` | `operations/PHASE8_CUSTOMERS.md` | Implemented; Studio verification pending |
| OPS-01 | Reproducible local setup and quality checks | `operations/BEGINNER_SETUP.md`, `operations/QUALITY.md` | Fresh setup and CI run | In progress |

No requirement is marked verified until the documented check is actually run and its evidence is recorded.
