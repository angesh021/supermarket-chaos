# Phase 72 — Supermarket aisle wayfinding

Give every generated retail gondola a readable overhead department header, supported above its existing shelf-edge department sign. The header is part of the same server-created shelf Model, so it follows the shelf through saved layout movement and rotation. Constructed grocery aisles and warehouse shelves use their existing server-selected department text; no client text, assets, remotes, economy values, or profile fields were added.

## Acceptance criteria

- Each core grocery department has a legible overhead sign visible from the store entrance and central floor.
- A purchased/constructed aisle shows the department string selected and validated by the server.
- Moving or rotating a shelf carries the header, supports, existing stock and prompts with the fixture.
- The warehouse editor can rebuild storage shelves without changing inventory or adding retail interactions.
- The sign uses the same department-sign palette role as existing store signage.

## Ownership and failure handling

`WorldBuilder.createShelf` creates the header and support parts as descendants of the fixture Model. Layout validation and ownership remain unchanged in `RetailLayoutService` and `ShiftService`; a display failure cannot grant stock, change a price, or affect a transaction. No external assets are used.

## Manual Studio verification

1. Open the starter store from the entrance and check the Citrus Pop, Berry Bites, Golden Apples, and Sunrise Cereal overhead labels are readable and do not block player movement or the ceiling lights.
2. Move and rotate a core shelf in the retail editor. Confirm its header/supports move and rotate with its shelf-edge label, product display, price tag, prompt, and customer route.
3. Purchase and build a grocery aisle assigned to a different product. Confirm the overhead header shows that product and stays with the aisle after moving it.
4. Open the warehouse layout editor. Confirm storage shelves show STORAGE and can still be selected/moved without changing backstock.
5. Preview each market palette. Confirm overhead department signs recolor with existing department signage and remain readable.

Static formatting, lint, Rojo build and diff checks are recorded in `docs/PROJECT_STATUS.md`. Roblox Studio visuals, pivots, collision and palette application have not been run by Codex.
