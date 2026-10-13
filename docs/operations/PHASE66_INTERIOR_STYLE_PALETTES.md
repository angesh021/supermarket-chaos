# Phase 66 — Extend store styles into the supermarket interior

## Acceptance criteria

- Previewing Coastal Market, City Grocer or Harvest Market recolors the supermarket floor, walls, wainscot, core gondola bodies/trim, department signs, checkout and exterior as one coherent style.
- Canceling preview restores the currently installed palette, or the original palette if none is installed. Leaving the completed-shift stage still cancels a preview.
- Installing a style keeps the existing one-time purchase, owner/manager checks, price and saved style ID. The installed choice is restored after rejoin.
- Department signage, product packs, price text, prompt text and checkout displays remain legible. Palette changes are decorative and do not alter stock, prices, customer routing, collisions or economy.
- A purchased rear wing receives the same style on first construction and after profile restoration; later-built shelf fixtures use the active style.

## Server/client boundaries and persistence

- ShiftService continues to cycle only fixed style IDs. The client cannot send colors, materials or Instances.
- WorldBuilder owns the palette mapping and applies it only to parts marked with a fixed palette role. Unmarked product, UI and interaction parts keep their gameplay colors.
- Preview is session-only. Economy validates and charges the current one-time style purchase; ProfileService persists the existing allow-listed style ID. No new profile fields or client visual state are introduced.
- Reset uses the original palette for each role. Invalid style IDs resolve to that reset behavior.

## Manual Studio checklist

1. Before buying a style, preview Coastal Market, City Grocer and Harvest Market. Inspect the floor, visible walls, shelf backs/rails, department signs, checkout and exterior from both entry and aisle views.
2. Confirm produce/products, prices, labels, checkout screen and ProximityPrompt text retain readable contrast for every palette.
3. Cycle past the last style to cancel. Confirm original colors return and cash/profile state remain unchanged.
4. Preview a style, leave the completed-shift stage and return. Confirm preview resets and no style is saved.
5. Install one style. Confirm the existing exact $180 charge occurs once, then rejoin and confirm interior and exterior restore.
6. With the style installed, buy the shelf bay, household aisle and rear department wing. Confirm new fixtures/floor/walls use the active palette.
7. Try preview/install with Visitor, Cashier, Stocker and Maintenance; confirm server authorization still limits editing to Owner/Manager.
8. Inspect Output and test desktop and touch views with Roblox chat open.

## Verification status

- On 2026-10-13, StyLua 2.5.0 `--check src`, Selene 0.32.0 (0 errors/warnings/parse errors), Rojo 7.7.0 build to `%TEMP%\\supermarket-chaos-phase66.rbxlx`, and `git diff --check` passed.
- Roblox Studio palette readability, preview reset, purchase, migration and save/rejoin remain unverified.

