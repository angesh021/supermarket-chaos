# ADR-0032: Move checkout as one saved fixture

- **Status:** Accepted
- **Context:** Department shelves can be rearranged, but a fixed checkout prevents a player from laying out a coherent store. Moving only the counter would strand the register props, cashier, queue, and customer routes.
- **Decision:** Treat the checkout lane and its five queue positions as one server-validated layout item. Reparent checkout props under one model, derive customer queue and checkout approach positions from the model pivot, move the cashier with it, and persist `{x, z, rotation}` beside department shelf records. Allow only bounded snapped positions and 0/90-degree rotation. Reject collisions with shelves, produce, the layout station, and the store boundary.
- **Consequences:** Profile schema v21 adds the checkout transform. Existing version-1 retail layouts keep their shelf positions and migrate to the default checkout transform. The client preview is advisory; server validation remains authoritative. Studio validation is required for rotated SurfaceGui readability, physical paths, queue behavior, and persistence.
- **Verification:** See `docs/operations/PHASE34_CHECKOUT_LAYOUT.md`.
