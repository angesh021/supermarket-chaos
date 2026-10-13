# Phase 58 — Commercial district streetscape

## Acceptance criteria
- The ground plane covers the whole existing plaza route through the garden shop and distribution center.
- A delivery avenue connects visually to the existing front street; a marked crossing and sidewalk support the pedestrian approach.
- Five original streetlights and two decorative shop shells give the neighborhood surrounding-business context.
- All new content is a server-created environmental projection inside the location model. It has no prompts, persistence, cash, inventory, ownership or sales behavior.
- No external assets, Toolbox items or third-party scripts are introduced.

## Boundaries and failure handling
- The server builds the parts and parent models. The client has no remote or action that can create, move or recolor them.
- These neighboring shops are scenery only. The future commercial plot purchase and multi-store runtime remain separate work.
- Lamp lights are static and non-shadow-casting; every lamp and decoration is anchored/non-interactive so a lighting issue cannot block customer or player actions.

## Manual Roblox Studio visual checklist
Open the private development experience, sync current `main` with Rojo, and check Output while using Play Solo.

1. Walk from the parking area toward the supermarket. Confirm the crosswalk meets the avenue without crossing the front entrance path or blocking the cart return.
2. Walk the plaza path to Little Sprout Garden and the distribution center. Confirm the extended ground has no visible gap or floating walkway.
3. Inspect both neighboring storefront shells. Confirm signs face the avenue, glass is visible, no parts intrude into paths or the distribution facility, and they read as decorative neighboring shops.
4. Walk and jump near all five streetlights and along the sidewalk. Confirm lamps do not block movement or customer routes and do not create noticeable lighting/performance problems.
5. Check the same approach in narrow mobile device emulation and inspect the exterior camera sightline. Record any collisions, unreadable signs, seams or Studio Output errors.
6. Confirm there are no purchase prompts, stock counts, balance changes or save changes caused by the neighboring shells.

## Verification status and limits
- StyLua, Selene, Rojo build and `git diff --check` results are recorded in `docs/PROJECT_STATUS.md` after they run.
- Roblox Studio appearance, movement clearance, mobile camera and lighting remain pending; no runtime visual result is claimed here.
- The two neighboring buildings are nonfunctional. Owned branch plots and multiple independently managed stores remain pending Phase 57 runtime work.
