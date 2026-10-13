# Documentation index

| Document | Purpose |
|---|---|
| [Product requirements](requirements/PRODUCT_REQUIREMENTS.md) | First playable scope and acceptance criteria |
| [Game design](design/GAME_DESIGN.md) | Core loop, progression, first session, systems |
| [First-session spec](design/FIRST_SESSION.md) | Onboarding beats and measurable outcomes |
| [Visual design bible](design/VISUAL_DESIGN_BIBLE.md) | Architecture, materials, color, lighting, neighborhood |
| [Architecture](architecture/ARCHITECTURE.md) | Runtime boundaries and Business Engine interfaces |
| [Threat model](security/THREAT_MODEL.md) | Trust boundaries, abuse cases, controls |
| [Traceability](requirements/TRACEABILITY.md) | Requirement to artifact and verification mapping |
| [Backlog](BACKLOG.md) | Initial sequenced work and dependencies |
| [Beginner setup](operations/BEGINNER_SETUP.md) | Studio, Rojo and local workflow |
| [Quality and CI](operations/QUALITY.md) | Checks, manual test procedures, CI status |
| [Assets and provenance](operations/ASSETS_AND_PROVENANCE.md) | Asset registry and project attribution |
| [Decision records](decisions/README.md) | Material architecture and product decisions |
| [Project status](PROJECT_STATUS.md) | Current state, risks, manual actions, G0 gate |
| [Customer queue verification](operations/PHASE8_CUSTOMERS.md) | Checkout queue acceptance and Studio procedure |
| [Chaos event verification](operations/PHASE9_CHAOS.md) | Spill event acceptance and Studio procedure |
| [Cleaner employee verification](operations/PHASE10_EMPLOYEES.md) | Persistent cleaner acceptance and Studio procedure |
| [Multi-product verification](operations/PHASE11_PRODUCTS.md) | Separate SKU stock, sales, delivery and migration checks |
| [Power outage verification](operations/PHASE12_POWER_OUTAGE.md) | Persisted outage, breaker roles, timeout and recovery checks |
| [Customer Rush verification](operations/PHASE13_CUSTOMER_RUSH.md) | Bounded bonus queue, reward, timeout and persistence checks |
| [Customer basket verification](operations/PHASE14_CUSTOMER_BASKETS.md) | Mixed and multi-item checkout, stock fallback and rejoin checks |
| [Storefront style verification](operations/PHASE15_STOREFRONT_STYLE.md) | Persistent visual upgrade, price, permissions and migration checks |
| [Customer event reaction verification](operations/PHASE16_CUSTOMER_EVENT_REACTIONS.md) | Spill, outage, rush and queue-recovery presentation checks |
| [Golden Apples verification](operations/PHASE17_GOLDEN_APPLES.md) | Produce stock, basket sales, shipment and v11 migration checks |
| [Employee automation verification](operations/PHASE18_EMPLOYEE_AUTOMATION.md) | Persistent pause/resume controls, timer cancellation, permissions and v12 migration checks |
| [Storefront preview verification](operations/PHASE19_STOREFRONT_PREVIEW.md) | Temporary palette preview, cancellation, purchase and existing profile compatibility |
| [Delivery worker verification](operations/PHASE20_DELIVERY_WORKER.md) | Persistent warehouse employee, automatic shipment receipt, controls and v13 migration |
| [Sunrise Cereal verification](operations/PHASE21_SUNRISE_CEREAL.md) | Fourth SKU, pantry stock, shipment, baskets, HUD and v14 migration |
| [Product pricing verification](operations/PHASE22_PRODUCT_PRICING.md) | Persistent shelf prices, role permissions, basket totals and v15 migration |
| [Price-sensitive basket verification](operations/PHASE23_PRICE_SENSITIVE_BASKETS.md) | Deterministic price response, quantity limits, basket totals and checkout stock changes |
| [Stocker replenishment verification](operations/PHASE24_STOCKER_REPLENISHMENT.md) | Repeat Citrus Pop restocking, SKU automation, prompt stages and stock caps |
| [Customer Assistant verification](operations/PHASE25_CUSTOMER_ASSISTANT.md) | Persistent staff hire, customer route timing, permissions and v16 migration |
| [Repeat-shift analytics verification](operations/PHASE26_REPEAT_SHIFT_ANALYTICS.md) | Development-only replay funnel, event order, privacy and failure isolation |
| [Household aisle expansion verification](operations/PHASE27_HOUSEHOLD_AISLE_EXPANSION.md) | Persistent fixed-slot store expansion, server price and schema v17 migration |
| [Shift payroll verification](operations/PHASE28_SHIFT_PAYROLL.md) | Fixed per-shift wages, one-time closeout deduction and HUD payroll display |
| [Warehouse layout editor verification](operations/PHASE29_WAREHOUSE_LAYOUT_EDITOR.md) | Persistent shelf placement, movement, rotation, collision bounds and authorization |
| [Customer preference verification](operations/PHASE30_CUSTOMER_PREFERENCES.md) | Weighted shopping profiles, deterministic reconstruction, stock fallback and checkout behavior |
| [Chaos Director verification](operations/PHASE31_CHAOS_DIRECTOR.md) | Shift-specific event schedules, event timing, recovery and rejoin reconstruction |
| [Retail layout verification](operations/PHASE32_RETAIL_LAYOUT.md) | Persistent product shelf movement, rotation, collision checks and customer routing |
| [Customer satisfaction verification](operations/PHASE33_CUSTOMER_SATISFACTION.md) | Persistent server-scored fulfillment rating, pricing impact, HUD and migration |
| [Rear floor expansion verification](operations/PHASE35_REAR_FLOOR_EXPANSION.md) | Persistent rear-wing unlock, walk-through opening and rear shelf placement |
| [Bakery department verification](operations/PHASE36_BAKERY_DEPARTMENT.md) | Bakery construction, Cinnamon Twists inventory, delivery, pricing and migration |
| [Product substitution verification](operations/PHASE37_PRODUCT_SUBSTITUTION.md) | Related SKU substitution, actual-item routing, pricing, stock and satisfaction |
| [Loyalty and patience verification](operations/PHASE38_LOYALTY_AND_PATIENCE.md) | High-satisfaction regulars and server-measured checkout patience |
| [Storefront palette choices](operations/PHASE39_STOREFRONT_PALETTE_CHOICES.md) | Three server-defined previewable and persistent exterior palettes |
| [Freezer department verification](operations/PHASE40_FREEZER_DEPARTMENT.md) | Freezer construction, SKU inventory, shipments, pricing, baskets and migration |
| [Automatic entrance door verification](operations/PHASE41_AUTOMATIC_ENTRANCE_DOORS.md) | Player/customer door triggers, tween timing and passable failure behavior |
| [Layout remote hardening verification](operations/PHASE42_LAYOUT_REMOTE_HARDENING.md) | Bounded layout payloads, malformed request throttling and valid edit behavior |
| [Self-checkout verification](operations/PHASE43_SELF_CHECKOUT.md) | Persistent second checkout, deterministic lane routing and shared sale authority |
| [Online grocery order verification](operations/PHASE44_ONLINE_GROCERY_ORDERS.md) | Warehouse packing board, deterministic orders and backstock fulfillment |
| [Delivery worker online order verification](operations/PHASE45_DELIVERY_WORKER_ONLINE_ORDERS.md) | One automated order per completed shift with shared fulfillment authority |
| [Larger customer event verification](operations/PHASE46_LARGER_CUSTOMER_EVENTS.md) | Six-shopper Customer Rush, expanded timer, stock gate and reward |
| [Corner Café verification](operations/PHASE47_CORNER_CAFE.md) | Persistent first plaza business, stock and coffee sales |
| [Market Table verification](operations/PHASE48_MARKET_TABLE_RESTAURANT.md) | Persistent restaurant, meal prep and meal sales |
| [Pixel & Plug verification](operations/PHASE49_ELECTRONICS_STORE.md) | Persistent electronics storefront, headphone stock and sales |
| [Little Sprout verification](operations/PHASE50_SPECIALTY_RETAIL.md) | Persistent specialty garden retailer, herb stock and sales |
| [Plaza customization verification](operations/PHASE51_PLAZA_CUSTOMIZATION.md) | Preview and install a persistent palette across plaza storefronts and paths |
| [Shared plaza traffic verification](operations/PHASE52_SHARED_PLAZA_TRAFFIC.md) | Bounded procedural visitors browse owned shops and exit |
| [Plaza customer sales verification](operations/PHASE53_PLAZA_CUSTOMER_SALES.md) | Visitors buy stocked items through server-owned business sales |
| [Delivery fleet verification](operations/PHASE54_DELIVERY_FLEET.md) | Persistent two-truck fleet and bounded online-order automation |
| [Distribution center verification](operations/PHASE55_DISTRIBUTION_CENTER.md) | Persistent regional facility and doubled per-SKU backstock capacity |
| [Supplier partnership verification](operations/PHASE56_SUPPLIER_PARTNERSHIP.md) | Persistent supplier agreement and discounted inbound deliveries |
| [Multi-store foundation](operations/PHASE57_MULTI_STORE_FOUNDATION.md) | Target architecture, safe profile migration and verification gate |
| [Uptown branch runtime](operations/PHASE62_UPTOWN_BRANCH_RUNTIME.md) | Server-priced branch purchase, isolated store state, shared wallet and multiplayer checks |
| [Expansion department layout](operations/PHASE63_EXPANSION_DEPARTMENT_LAYOUT.md) | Move and rotate owned bakery/freezer fixtures with server-side bounds and persistence |
| [Purchased store fixture layout](operations/PHASE64_MOVABLE_CORE_FIXTURES.md) | Move and rotate owned shelf bay/household aisle fixtures with server-side bounds and persistence |
| [Movable shelf stock visuals](operations/PHASE65_MOVABLE_SHELF_STOCK_VISUALS.md) | Keep each core product's visible stock attached to its movable shelf model |
| [Interior store palettes](operations/PHASE66_INTERIOR_STYLE_PALETTES.md) | Apply the installed server-allow-listed store style to the interior |
| [Constructed grocery aisles](operations/PHASE67_CONSTRUCTED_GROCERY_AISLES.md) | Build and persist up to four movable grocery aisles |
| [Shift operating costs](operations/PHASE68_SHIFT_OPERATING_COSTS.md) | Derive and charge bounded facility upkeep at shift close |
| [Riverside Bookshop](operations/PHASE69_RIVERSIDE_BOOKSHOP.md) | Open, stock and operate the persistent neighborhood bookshop |
| [Merchandised grocery aisles](operations/PHASE70_MERCHANDISED_GROCERY_AISLES.md) | Assign a product category to each constructed aisle and show its inventory |
| [Merchandised aisle customer routing](operations/PHASE71_MERCHANDISED_AISLE_ROUTING.md) | Route customers to a stocked constructed aisle and recover to the primary shelf |
| [Commercial district review](operations/PHASE58_COMMERCIAL_DISTRICT.md) | Connected avenue, neighborhood storefronts and Studio visual checks |

Keep this index and linked documents current as implementation changes. See [AGENTS.md](../AGENTS.md) for repository rules.
