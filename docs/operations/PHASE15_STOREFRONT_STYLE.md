# Phase 15 storefront style verification

The owner or an authorized Manager can buy a storefront style for `$180` at the physical style pad after completing a shift. Phase 39 adds the selectable Coastal Market, City Grocer, and Harvest Market palettes; the original purchase flag remains in profile schema v10 and the selected preset ID is saved in v24. Previous purchases migrate to Coastal Market, while unowned profiles remain at the original palette.

This is one server-selected preset, not an editable color picker. It uses original procedural parts and no external assets. Roblox Studio appearance, purchase, and DataStore behavior have not been run locally.

## Acceptance criteria

- The pad/sign is visible in the store and its ProximityPrompt is enabled only for a completed shift when the style is not owned.
- Owner or Manager with at least `$180` may purchase once; insufficient funds, wrong stage, unauthorized role, out-of-range, or duplicate attempts do not charge or recolor.
- The server deducts exactly `$180`, updates the fascia/sign/canopy/interior header, disables the prompt, and saves the upgrade flag in the same progression path.
- Rejoining rebuilds the Coastal Market colors without another charge. Existing schema v1–v9 profiles retain the default palette and can still load.
- Restarting a shift keeps the purchased style. The style does not affect inventory, customer behavior, sale prices, shift state, or Robux commerce.
- The purchase remains server-authoritative; the client cannot request a preset, color, price, or ownership flag.

## Server/client boundary and failure handling

`Economy.buyMarketStyle` validates the completed stage, ownership state, and server balance. `ShiftService` applies the common role, proximity, save-lock, and interaction-rate checks before the transaction. `ProfileService` validates and persists one boolean in `ownedUpgrades`; older profiles normalize it to false. `WorldBuilder` changes only the listed color properties. The client receives no authority over preset or purchase. Production publishing and Robux commerce remain disabled.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`. Keep Output open.
2. Before shift completion, confirm the Coastal Market pad cannot be purchased. Complete a shift and inspect the sign and prompt.
3. With less than `$180`, attempt purchase. Confirm a clear insufficient-funds message and no balance or appearance change.
4. With at least `$180`, purchase once. Confirm exactly `$180` is deducted, the exterior fascia/sign and canopy change, the interior header changes, and the prompt disables.
5. Attempt a second purchase and try as a Stocker/Cashier helper. Confirm no second charge or world change. Confirm an authorized Manager can purchase only when the shared shift is Complete.
6. Leave and rejoin. Confirm the palette remains without another charge. Start a new shift and confirm the style persists.
7. In a test profile copy using an earlier supported schema, confirm migration defaults `marketStyle` to false and the original palette loads.
8. Record starting/final cash, save status, profile version, role, prompt state and visible changed parts. Confirm Output has no errors.

## Known limits

- Phase 39 expands the fixed style package to three presets with preview/cancel and saves the selected preset ID in profile schema v24. Custom placement and per-part editing remain unavailable.
- Visual color review and old-profile migration have not been exercised in Studio.
