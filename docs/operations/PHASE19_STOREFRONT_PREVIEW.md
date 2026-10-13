# Phase 19 storefront style preview

The owner or Manager can preview the existing Coastal Market storefront refresh on a separate preview pad, then install it from the purchase pad for `$180`. Preview changes the current server's world presentation only; it is not written to the profile. Canceling the preview or leaving the completed-shift state restores the saved/default palette. Purchasing installs the same fixed server-defined palette through the existing economy and profile path.

No profile migration is needed. The existing schema v10 `ownedUpgrades.marketStyle` flag remains the only persisted customization. No external assets are used.

## Acceptance criteria

- At shift completion, an owner/Manager can preview the Coastal Market palette before purchasing it.
- The preview visibly recolors the storefront fascia, sign, canopy, entrance header, and style signage without charging cash or changing saved ownership.
- A second interaction cancels the preview and restores the saved/default palette. Starting another shift also clears an unpurchased preview.
- The separate purchase pad still charges exactly `$180` once, persists the purchase, and applies the same palette after rejoin.
- Unauthorized roles, visitors, out-of-range interactions, rapid repeats, insufficient funds, and profile lock failures cannot preview globally or buy the style.
- Existing profiles and the original default palette remain compatible; no profile schema version is added.

## Server/client boundary and failure handling

`ShiftService` uses separate fixed ProximityPrompt action IDs and the common Owner/Manager, distance, cooldown, owner readiness, and profile lock checks. Preview state is transient server state and cannot be selected through client arguments. `WorldBuilder` applies only the fixed palette and resets preview when leaving the completed-shift state or installing the saved upgrade. `Economy.buyMarketStyle` remains authoritative for stage, price, balance, and ownership; only its successful result reaches `ProfileService`.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`. Keep Output visible.
2. Reach a completed shift without buying the style. Confirm the preview and purchase pads are both visible and accessible.
3. As Owner, activate **Preview Coastal Style**. Confirm the store exterior and interior header recolor, the preview sign updates, and cash/save status do not change.
4. Activate **Cancel Preview**. Confirm the original palette returns and no charge occurs.
5. Preview again, then start a new shift. Confirm the unpurchased preview resets to the original palette and remains unowned after rejoin.
6. On a completed shift with at least `$180`, preview then purchase. Confirm exactly `$180` is deducted, the palette remains installed, and the preview action is disabled.
7. Leave and rejoin. Confirm the installed style is restored without a second charge. Confirm an older profile without `marketStyle` remains on the original palette.
8. Try preview and purchase as Cashier, Stocker, Maintenance, visitor, Manager, and Owner; test out-of-range, insufficient funds, duplicate prompts, and save-lock behavior.
9. Confirm no Output errors. Record before/after cash, palette, role and saved ownership.

## Known limits

- This increment previews one fixed palette. Multiple owned palettes, interior floor/wall/material controls, logos, seasonal decor, and per-player isolated previews are future work.
- Roblox Studio multiplayer visibility, purchase, and persistence have not been run locally.
