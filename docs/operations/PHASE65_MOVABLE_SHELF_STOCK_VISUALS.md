# Phase 65 — Shelf-relative stocked product displays

## Acceptance criteria

- Stocked Citrus Pop, Berry Bites, Golden Apples and Sunrise Cereal visuals render on their matching server-built shelf model.
- Moving or rotating a core product shelf also moves and rotates its stocked product visuals, shelf labels, price tag and stock prompt as one fixture.
- Golden Apples display is centered on its produce shelf instead of appearing at a fixed unrelated world coordinate.
- Visual stock counts are derived from the existing server-owned shelf counts. This change adds no inventory, cash, pricing or profile fields.
- Empty stock clears the corresponding product visuals. Rejoin reconstructs the same layout and stock display from the saved profile.

## Server/client boundaries and failure handling

- `WorldBuilder` parents each displayed stock item under its matching shelf model and calculates its position from the current server-owned shelf transform.
- Stock count remains owned and mutated by `ShiftService`/`Economy`; the visual renderer receives only the count already accepted by server gameplay.
- The client continues to send only bounded layout ID, position and rotation through the existing layout editor. It cannot create stock visuals or change inventory.
- A missing shelf transform falls back to the existing model position; shelf movement and stock placement never change the authoritative stock quantity.

## Manual Studio checklist

1. Start a shift and stock each of the four core products. Confirm cans, Berry Bites packs, apples and cereal boxes appear on the matching product shelf; specifically confirm Golden Apples appear on the produce shelf.
2. Close the shift, open the retail layout editor, move and rotate each core shelf. Confirm its visible stock, label, price tag and prompt stay together.
3. Start another shift, sell/restock products and confirm only the server-authoritative count is shown. Empty each shelf and confirm its stocked visuals clear.
4. Rejoin after saving a non-default layout and nonzero stock. Confirm each shelf and its product display restore to the same transform and count.
5. Try layout edits as Visitor/Cashier and confirm the server still rejects unauthorized changes; confirm the stock display cannot be changed with a client-only visual edit.
6. Check narrow viewport, touch input and Roblox chat visibility while selecting shelves and using the layout editor.

## Verification status

- On 2026-10-13, StyLua 2.5.0 format and `--check src`, Selene 0.32.0 (0 errors/warnings/parse errors), Rojo 7.7.0 build to `%TEMP%\\supermarket-chaos-phase65.rbxlx`, and `git diff --check` passed.
- Roblox Studio display placement, rotation, stock depletion, save/rejoin, multiplayer and touch checks remain pending.

