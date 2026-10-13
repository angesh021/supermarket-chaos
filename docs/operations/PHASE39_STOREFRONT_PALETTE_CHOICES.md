# Phase 39 — Storefront palette choices

The existing `$180` storefront refresh now has three fixed, original procedural palettes: Coastal Market, City Grocer, and Harvest Market. At the completed-shift style pad, Preview Next Style cycles through the presets; a fourth interaction cancels and restores the current default/saved appearance. The refresh pad installs the currently previewed choice. If no preview is active, it installs Coastal Market. Profile schema v24 persists the selected allow-listed palette ID. Profiles with the old `marketStyle=true` flag and no ID migrate to Coastal Market.

## Acceptance criteria

- Only the three server-defined IDs are accepted; clients cannot submit a palette, color, cost, or ownership value.
- Each preview changes the fascia, sign, canopy, valance, interior header and style sign without charging or saving.
- Cancel restores the default appearance. Leaving the completed-shift state also cancels the preview.
- Purchase requires a completed shift, Owner/Manager permission, interaction distance, rate limit, save readiness and `$180`; it charges once and persists the selected ID.
- Rejoin restores the selected palette. Legacy `marketStyle=true` profiles load as Coastal Market; older profiles with no purchase remain at the default appearance.
- Storefront style affects no inventory, sales, staffing, rewards, role permissions or Robux commerce.

## Server/client boundary and failure handling

`ShiftService` cycles a fixed server-side palette list from a physical ProximityPrompt. `Economy.buyMarketStyle` verifies the ID against its preset allowlist and handles stage, ownership and balance. `ProfileService` validates and stores the ID with schema v24. `WorldBuilder` maps each ID to fixed colors. There is no client palette remote. Invalid or duplicate purchases leave cash and appearance unchanged.

## Manual Studio checklist

1. In the private development universe `10770581249`, reach a completed shift and inspect the refresh and preview pads.
2. Cycle through Coastal Market, City Grocer and Harvest Market. Confirm the exterior fascia/sign/canopy/valance, entry header and preview sign visibly change for each; confirm cash is unchanged.
3. Press the preview pad once more. Confirm the default appearance returns and cash remains unchanged. Start another shift while previewing and confirm preview is cleared.
4. Preview City Grocer, then install it. Confirm exactly `$180` is deducted, the preview is retained, the pad disables, and a duplicate prompt cannot charge again.
5. Leave and rejoin. Confirm City Grocer is restored. Repeat with Harvest Market if desired.
6. Using a disposable old profile, confirm an existing `marketStyle=true` flag without a palette ID migrates to Coastal Market; an unowned legacy profile remains on default.
7. Try with insufficient funds, wrong roles, visitors, out-of-range prompts and profile save lock. Confirm no purchase or saved change occurs.
8. Check Studio Output and record role, starting/final cash, selected palette, save status and profile version. Roblox Studio and DataStore behavior have not been run locally.

## Limitations

- Palettes recolor a fixed set of procedural exterior/interior accents; custom colors, logos, signs, floor/wall materials and per-player previews remain future work.
- The palette is server-wide because the current server hosts one shared store.
