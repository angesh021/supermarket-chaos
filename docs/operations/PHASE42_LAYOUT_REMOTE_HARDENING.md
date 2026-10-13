# Phase 42 — Layout remote flood and schema hardening

Warehouse and retail layout requests now consume a per-player cooldown before validation. Requests arriving during the cooldown are dropped without a reply, limiting server-to-client rejection amplification. Accepted request shapes are action-specific allowlists of at most five scalar fields; unknown keys, unsupported actions, oversized action/key names and malformed table payloads are rejected before role, distance or layout work. Existing coordinate, rotation, ID, collision, ownership, stage and save-lock validation remains in place.

## Acceptance criteria

- Warehouse request traffic is throttled to one attempt per player per 0.4 seconds, including malformed requests.
- Retail request traffic is throttled to one attempt per player per 0.4 seconds, including malformed requests.
- Calls during cooldown do not trigger response remotes.
- Warehouse actions accept only the fields for `PlaceShelf`, `MoveShelf` or `RemoveShelf`; retail accepts only `MoveShelf` or `MoveCheckout` fields.
- Unknown keys, invalid action types/names and payloads with more than five top-level fields are rejected without mutation.
- Valid Owner/Manager placement, movement, rotation and removal flows continue to use the existing server validators and save path.
- Per-player cooldown state is cleared when that player leaves.

## Server/client boundary and failure handling

`ShiftService` owns request throttling and exact top-level request shape. Client coordinates remain proposals and must pass the existing grid, range, collision and ownership rules. Rejection is non-mutating. The cooldown is applied before sending rejection feedback, so malformed request floods cannot cause an unbounded response stream. This increment adds no profile data, remotes or gameplay authority to clients.

## Manual Roblox Studio verification

1. In the private development experience, complete a shift, own the warehouse and approach the warehouse layout board as Owner or Manager.
2. Use the normal UI to place, move, rotate and remove a shelf. Confirm the UI still receives one result per accepted action and the existing balance/layout persistence behavior remains intact.
3. In a local Studio-only diagnostic session, send malformed warehouse and retail payloads (non-table values, unsupported actions, unknown keys, and tables with more than five keys) rapidly. Confirm at most one rejection response per 0.4 seconds per remote, and no cash, layout or saved-state mutation.
4. From an unauthorized role or outside prompt range, submit otherwise valid requests. Confirm the request is rejected without mutation.
5. Rejoin or move the test client to confirm cooldowns are per active player session and do not prevent normal interaction after leaving/rejoining.
6. Confirm another player can still use the board normally and that visitor snapshots reveal no private warehouse/economic state.

## Local checks and runtime status

Run pinned StyLua, Selene, Rojo build and `git diff --check`; record exact results in `docs/PROJECT_STATUS.md`. Remote flood behavior and real client/server replication remain unverified until Studio is run.

## Limitations

The cooldown is in-memory and per remote/player. It does not replace Roblox's platform-level network limits, broader game-wide abuse monitoring or Studio adversarial verification.
