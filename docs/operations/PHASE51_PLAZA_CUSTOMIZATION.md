# Phase 51 — Plaza customization

## Acceptance criteria
- After Little Sprout Garden is owned, Owner/Manager can preview and install a plaza palette for `$750` between shifts.
- Three server-allow-listed palettes are available: Coastal Walk, City Lights and Harvest Lane.
- Preview changes only the plaza's shop awnings, roofs, signs and paths. Cancel restores the existing style; leaving the completed-shift stage cancels a preview.
- Installing a style charges `$750` once, applies the same palette to every owned plaza business/path and persists the selected palette after rejoin.
- Profile schema v33 migrates earlier profiles with no plaza style. Invalid IDs and plaza style without garden ownership are rejected.

## Server/client boundaries
- `Economy` validates the selected ID, stage, prerequisite and cash before the one-time purchase.
- `ShiftService` cycles only fixed IDs and applies Owner/Manager, range, rate and profile-save checks.
- `WorldBuilder` owns the fixed palette colors and visual mapping; no client-supplied colors, parts or model paths are used.
- `ProfileService` stores only the allow-listed style ID. Preview state is server-session-only and not saved.

## Failure handling and limits
- Insufficient cash, incomplete prerequisite, invalid style or denied role leaves cash, saved style and world unchanged.
- The customization changes colors only; it does not add user-built structures, move storefronts, or alter business prices/progression.

## Manual Roblox Studio verification checklist
1. Before owning Little Sprout, confirm plaza preview/install prompts are unavailable. Complete all four business purchases.
2. Preview Coastal Walk, City Lights and Harvest Lane; confirm each updates all owned storefront awnings/roofs/signs and plaza walkways consistently.
3. Cycle past the final option to cancel; confirm the original colors return without changing cash or saved style.
4. Preview a style, leave the completed-shift stage, then return; confirm preview is reset and the original style is shown.
5. With less than `$750`, attempt installation and confirm no charge or permanent visual change.
6. Install a style with enough cash; confirm exactly `$750` is deducted and the installation prompt disables.
7. Save and rejoin; confirm the installed palette is restored across every purchased plaza store and walkway.
8. As Cashier, Stocker and Maintenance, confirm preview/install are denied; confirm Manager works.
9. Load a v32 profile; confirm it migrates with no plaza customization and preserves existing businesses.
10. Inspect Output and walk all plaza routes on desktop and mobile after each palette is applied.

## Verification status
- Pinned StyLua 2.5.0 `--check src`, Selene 0.32.0 (`0 errors, 0 warnings, 0 parse errors`), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase51.rbxlx`, and `git diff --check` passed on 2026-10-13. Git emitted only Windows line-ending normalization warnings.
- Roblox Studio preview/cancel/install, visual consistency, permissions, migration and save/rejoin: pending; no runtime success is claimed.
