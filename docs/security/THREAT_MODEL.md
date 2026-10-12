# Threat model — initial Phase 0

## Assets and trust boundaries
Protected assets: currency, inventory, store/build ownership, upgrade state, shift rewards, persistent profile, purchase fulfillment, moderation and service availability. Clients and all client-originated values are untrusted. Roblox platform services and server code are trusted within their documented behavior. External assets/packages are untrusted until provenance and code review are complete.

## Abuse cases and controls
| Threat | Example | Required control |
|---|---|---|
| Currency manipulation | Forged sale/reward or client-supplied price | Server calculates from catalog and valid state; atomic transaction |
| Remote abuse | Invalid types, huge payloads, floods | Strict schemas/size caps, per-player rate limits, bounded work and safe failure |
| Ownership bypass | Build/checkout against another store | Resolve owner and role server-side on every action |
| Inventory duplication | Replayed stock/checkout request | State transition checks and idempotency/transaction IDs |
| Purchase replay | Repeated receipt callback | Server-side receipt verification and durable idempotent fulfillment |
| Persistence corruption | Old/concurrent write overwrites new data | Versioned schema, serialized/session-coordinated updates, backups/recovery procedure |
| Permission escalation | Client selects manager role | Server-owned role assignment and explicit allowlist |
| Resource exhaustion | Spawn/pathfinding/event spam | Server caps, cooldowns, bounded NPC populations and task queues |
| Unsafe admin tooling | Exposed command or debug remote | No public admin remote; restricted, audited development-only tools |
| Malicious dependency/asset | Toolbox script exfiltration/backdoor | Original or reviewed assets only; provenance and source review |

## Remote validation checklist
Validate type, finite numeric values, bounds, identifier allowlist, serialized size, ownership, permission, distance where relevant, current state, cooldown, and duplicate/replay status on server. Never accept client authority for cost, reward, entitlement, target owner, or transaction outcome. Rejection is cheap, non-mutating, and does not leak sensitive data.

## Release-blocking security tests
Forged requests, malformed and out-of-range values, cross-player ownership, duplicate/replay transactions, request floods, concurrent operations, persistence failure/recovery, and purchase reconciliation. Any defect affecting currency, ownership, purchases, or persistent progress blocks release.

## Phase 0 limits
This is a design threat model, not a security audit. No runtime code or adversarial tests exist yet. Reassess when remotes, persistence, co-op roles and commerce are designed; verify current Roblox security and commerce documentation then.
# Phase 3/4 additions
- Join requests are rate-limited by the server. Only the current store owner can assign roles or remove a player; role names are allow-listed and target users must be in the same server.
- Every ProximityPrompt remains a client-controlled signal. The server rechecks membership, role/action permission, owner profile lock, world ancestry, character distance, player membership and interaction rate before changing shared state.
- Member lists are generated on the server from current Players and safe display fields. Clients never submit a balance, profile, stage, inventory count or saved employee value.
- A cashier purchase is checked and charged by the server. Automatic checkout uses the existing economy transition and is delayed, bounded to the Checkout stage, and rechecked against owner/save state.
- Persistent profile access is allow-listed to the user-provided development universe ID. Other universes run session-only; production is not configured.
- Profile schema versions are checked as finite, bounded integers. Read-only visitors receive zeroed economic counters in replicated state; only store owner and approved helpers receive the shared operational totals.
- Funnel telemetry is development-universe-only and wrapped so AnalyticsService failure cannot block gameplay. Roblox associates events with its required Player argument; the game adds no custom fields or identifiers. The temporary funnel-session GUID stays in server memory and is not stored in the player profile.
