# ADR-0034: Add a persistent, fixed bakery department

- **Status:** Accepted — 2026-10-13.
- **Context:** The rear wing created store floor area without a recognisable department or another complete customer-facing product loop.
- **Decision:** Allow the Owner/Manager to buy a fixed server-built bakery for `$350` after the rear wing and warehouse. Add Cinnamon Twists as a server-priced SKU with separate saved shelf/backroom stock, the existing single-shipment delivery flow, price tiers, customer basket participation and visible procedural bakery fixtures. Keep the bakery fixture fixed and reserve its footprint in server layout validation.
- **Consequences:** Profile schema v23 stores the bakery flag, pastry stock, backstock and price; older profiles migrate with the bakery disabled. Customer preference selection and browsing include the product only for bakery owners. No external assets, production publishing or commerce are part of this decision.
- **Verification:** See `docs/operations/PHASE36_BAKERY_DEPARTMENT.md`; Studio construction, transactions, customer navigation, permissions and migration remain pending.
