# ADR-0005: Server-owned warehouse deliveries

- **Status:** Accepted for the first Phase 7 delivery increment; Studio verification pending.
- **Date:** 2026-10-12

## Context

The warehouse purchase created a physical annex but no supply loop. Store shelves currently stock one product, and repeated shifts need inventory that remains meaningful across sessions. A delivery must not permit client-controlled quantity, cost, early receipt or duplicate receipt.

## Decision

Persist a backroom Citrus Pop count and at most one pending shipment in the player-owned profile. The server charges $60 for 24 cans, marks a server timestamp 15 seconds in the future, and adds the shipment to backstock only when the owner or Manager receives an arrived crate. Each shelf stock action consumes three cans. Backstock is capped at 500.

Legacy profiles without warehouse inventory migrate to 12 cans and no pending shipment. The order can be placed at any shift stage after warehouse ownership, so low stock cannot make a shift impossible to complete. Only Owner and Manager roles can order or receive deliveries.

## Alternatives considered

- Free restock: rejected because it removes the inventory decision and has no visible cost.
- Client-timed arrival or client-supplied quantity: rejected because those values affect currency and persistent inventory.
- Multiple products and general catalog now: deferred until the single-product transaction and persistence path is verified.

## Consequences and verification

- Profile schema advances to v4 and validates bounded inventory, shipment quantity and timestamp.
- A saved timestamp reconstructs arrival after a rejoin; an elapsed timestamp is immediately ready.
- A failed save follows existing profile save-status behavior. Studio checks must verify pending/rejoin behavior and ensure no duplicate charge or receipt.
- This does not enable Robux commerce, supplier purchases, production settings or a production DataStore.
- See [Phase 7 delivery verification](../operations/PHASE7_DELIVERY.md).
