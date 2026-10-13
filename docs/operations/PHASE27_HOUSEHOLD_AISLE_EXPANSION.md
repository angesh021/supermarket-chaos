# Phase 27 household aisle expansion

After the first `$45` shelf-bay upgrade, an Owner or Manager can spend `$220` at the same marked upgrade pad to add a second fixed household-goods gondola inside the existing store footprint. The new fixture and department sign are generated on the server and persist in the player's profile (schema v17). The server uses one allow-listed slot; clients cannot submit coordinates, rotations, models, or prices. This increment provides a measurable store-growth purchase while laying a safe foundation for future placement tools.

## Acceptance criteria

- The original first-shift shelf upgrade remains unchanged and still costs `$45`.
- The household aisle prompt appears only after the first shelf bay is owned and a shift is complete.
- A valid purchase costs exactly `$220` once, creates a visible `HOME & EVERYDAY` aisle, and saves ownership.
- The aisle is reconstructed after profile load and cannot be purchased twice.
- Existing v1–v16 profiles normalize with the new upgrade disabled. Malformed flag types and an aisle flag without the prerequisite shelf bay fail profile validation.
- The purchase is owner/Manager-only, distance-checked and rate-limited by the existing server prompt binding. The server uses a fixed pre-reviewed slot and accepts no client placement data.
- Insufficient funds, wrong shift stage, missing prerequisite and repeat purchase do not charge or alter the world.

## Boundaries and failure handling

`Economy.buyAisleExpansion` validates stage, prerequisite, duplicate ownership and available server cash before changing state. `ProfileService` validates and persists the allow-listed boolean through schema v17 migration. `ShiftService` binds the physical prompt to existing owner/Manager permission and server distance checks. `WorldBuilder` creates one fixed shelf at `(16, -8)` only after a successful server transaction. This phase does not add free placement, arbitrary rotation, client previews, or new inventory authority.

If persistence fails, the existing save-status guard blocks subsequent interactions while pending/lock-lost state is handled by the profile service. Failed purchase validation leaves cash and the world unchanged.

## Manual Studio checklist

1. Start with a v16/older profile. Confirm it loads with no household aisle and the original `$45` first upgrade remains available at its existing milestone.
2. Complete a shift, buy the first shelf bay, finish/restart and complete a later shift with at least `$220`.
3. Confirm the same gold pad changes to `HOUSEHOLD AISLE $220`; buy it and verify cash falls by exactly `$220` and a household gondola/sign appear in the right-hand aisle without blocking the checkout or customer route.
4. Rejoin and confirm the aisle remains, the purchase prompt is unavailable, and the profile still loads.
5. Repeat with less than `$220`; confirm a clear insufficient-funds message and no deduction/fixture.
6. In a two-client test, confirm a visitor cannot activate the prompt and an authorized Manager can; verify distant prompt activation is rejected.
7. Confirm a profile with `aisleExpansion=true` and `shelfBay=false` is rejected as malformed during a disposable migration test.
8. Confirm current default shelf bay, warehouse, price, employee, shift and delivery state remains intact for pre-v17 profiles.

## Limitations

- Construction currently offers one fixed, server-approved slot in one shared server store. It is not a plot system or free-form furniture editor, and the household fixture is decorative rather than a stocked SKU.
- Roblox Studio collision, sightline, purchase, multiplayer, migration and DataStore rejoin behavior have not been run locally. Use the checks above before treating this milestone as verified.
