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

Keep this index and linked documents current as implementation changes. See [AGENTS.md](../AGENTS.md) for repository rules.
