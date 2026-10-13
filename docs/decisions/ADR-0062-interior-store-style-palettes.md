# ADR-0062: Apply installed store palettes to the interior

- **Status:** Accepted; Studio verification tracked in docs/operations/PHASE66_INTERIOR_STYLE_PALETTES.md.
- **Context:** The existing one-time store style preview and purchase only changed exterior colors. Players could not personalize the supermarket interior, even though the stored style ID was already location-owned and server validated.
- **Decision:** Extend the existing fixed palette IDs to explicitly tagged interior surfaces. Reuse the current preview, purchase, cancellation, authorization and persistence flow; do not add client-provided colors or a separate saved style field.
- **Consequences:** Store floor, walls, shelf accents, department signs and checkout follow one allow-listed palette. Unmarked gameplay-critical visuals retain their original colors. No profile schema change.
- **Verification:** See docs/operations/PHASE66_INTERIOR_STYLE_PALETTES.md.

