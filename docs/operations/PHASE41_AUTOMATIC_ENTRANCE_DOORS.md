# Phase 41 — Automatic sliding entrance doors

The entrance now has two translucent glass panels that meet across the opening while idle and slide apart when a player enters the motion sensor. Scripted customers explicitly open the doors on arrival and departure because their procedural movement uses model pivots and does not generate physical touch events. A short tween keeps motion readable; a bounded timer closes the panels after traffic clears. The glass panels remain non-collidable so a missed touch or interrupted tween cannot trap a player or customer.

## Acceptance criteria

- The entrance reads as two framed automatic glass panels under the existing canopy and track.
- A player touching the doorway sensor opens both panels smoothly; they close after the short open window.
- Customer arrival and exit open the panels without relying on physics touch events.
- Repeated traffic resets the close timer; an older timer cannot close the panels while a newer opening is active.
- Door panels never block player/NPC movement or alter store, profile, shift or economy state.
- No external assets or sound IDs are introduced.

## Boundaries and failure handling

`WorldBuilder` owns the panels, sensor and tweens. The sensor only reacts to a character model with a `Humanoid`; it accepts no remote or gameplay command. Tween targets are fixed server-authored transforms. A generation counter invalidates stale close timers. Panels stay `CanCollide = false`, so visual timing failures do not block traffic. The feature adds no profile fields or DataStore writes.

## Manual Roblox Studio verification

1. Start the private development experience `10770581249` with Rojo connected. Observe the entrance from outside: confirm the glass panels meet at the center, remain transparent, and fit inside the frame.
2. Walk through from outside to inside, then back out. Confirm both panels slide outward on approach and close after about two seconds.
3. Stand in the sensor and walk repeatedly across the threshold. Confirm overlapping triggers keep the doors open until the last open timer expires.
4. Begin a shift and watch customer arrival and exit. Confirm panels open for both scripted visits despite pivot-driven movement.
5. Reset/respawn or leave while a door tween is active. Confirm no collision trap, stuck character, Output error or change to cash, stock, sales, objective or saved profile.
6. Confirm another player crossing the doorway opens the same shared doors without gaining access to store-private state.

## Local checks and runtime status

Run pinned StyLua, Selene, Rojo build and `git diff --check`; record their results in `docs/PROJECT_STATUS.md`. Studio animation, sensor event behavior, multiplayer observation and visual fit are pending until manually observed.

## Limitations

The doors are a visual procedural approximation: no motor audio, obstruction reversal, glass collision, or client-predicted animation is included. A player who remains inside the sensor may see the fixed close timer complete; panels remain non-collidable and re-open on the next touch.
