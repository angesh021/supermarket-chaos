# SUPERMARKET CHAOS: RETAIL EMPIRE
# COMPLETE MASTER DEVELOPMENT SPECIFICATION
## Version 2.0 — Game Design, Visual Excellence, Engineering, Security, Documentation and Release

---

# 1. YOUR ROLE AND MISSION

Act as the principal Roblox game developer, technical architect, gameplay designer, 3D environment designer, UI/UX designer, security engineer, QA engineer, DevOps engineer, and technical documentation lead for a new Roblox experience.

The project is titled:

**Supermarket Chaos: Retail Empire**

**Tagline:** Start Small. Build Big. Survive the Chaos.

The objective is to create a beautiful, polished, secure, expandable, multiplayer Roblox game that combines supermarket management, business simulation, physical store expansion, dynamic events, and long-term retail empire progression.

This is a serious commercial game development project, not a throwaway prototype.

The long-term business objective is to develop a sustainable Roblox experience capable of potentially generating US$1,000–$5,000 in monthly revenue. Revenue is not guaranteed and must be evaluated through actual engagement, retention, monetization, and operating-cost data.

The project must be:

- Visually beautiful and distinctive.
- Enjoyable from the first seconds.
- Easy for new players to understand.
- Satisfying to play repeatedly.
- Designed for solo and cooperative multiplayer.
- Secure by design.
- Optimized for desktop and mobile.
- Built using modular, maintainable Luau code.
- Professionally documented.
- Reproducible and version-controlled.
- Extensible into multiple business types.
- Ready for disciplined testing, deployment, and long-term maintenance.

Use Roblox Studio, Luau, Codex, Git, GitHub, Rojo, and compatible engineering tools.

Verify platform-specific APIs, tooling, policies, and technical assumptions against current official documentation when access is available.

Never claim an action, test, build, deployment, or verification succeeded unless it actually occurred.

---

# 2. NON-NEGOTIABLE DEVELOPMENT PRINCIPLES

Follow these principles throughout the project.

1. Gameplay quality takes priority over feature quantity.
2. Visual quality is a core product requirement.
3. Security is designed into every authoritative system.
4. The server controls all authoritative gameplay and economy state.
5. Documentation is maintained alongside implementation.
6. The codebase remains modular, readable, and testable.
7. Every significant feature has measurable acceptance criteria.
8. Mobile performance is considered from the beginning.
9. Player progression is persistent and recoverable within platform limitations.
10. Monetization must be fair and transparent.
11. No production deployment occurs without explicit approval.
12. No unnecessary third-party dependencies.
13. No unverified assets or scripts from Roblox Toolbox.
14. No fabricated test results or misleading documentation.
15. No unnecessary architectural complexity.
16. Development proceeds through small, complete, playable milestones.
17. Future business types reuse established systems where appropriate.
18. The project maintains accurate records of important decisions and dependencies.
19. All implementation limitations must be disclosed.
20. The game must feel intentionally designed, not assembled from unrelated assets.

---

# PART I — GAME VISION AND PLAYER EXPERIENCE

# 3. CORE GAME CONCEPT

Supermarket Chaos: Retail Empire is a cooperative retail management game in which players begin with a small convenience store and gradually build a diversified business empire.

Players actively participate in operating their businesses.

Activities include:

- Stocking shelves.
- Scanning products at checkout.
- Managing customer queues.
- Cleaning spills.
- Receiving deliveries.
- Managing inventory.
- Hiring and supervising employees.
- Expanding store buildings.
- Designing store interiors.
- Unlocking departments.
- Managing operational expenses.
- Responding to unpredictable chaos events.
- Collaborating with friends.
- Opening additional businesses.
- Developing supply chains.
- Expanding into new commercial locations.

The experience should balance three elements:

**Management:** Meaningful business decisions.

**Interaction:** Satisfying hands-on gameplay.

**Chaos:** Funny, unexpected situations that create memorable moments.

Do not create a game that is merely a collection of buttons generating passive income.

# 4. CORE PLAYER FANTASY

The player should feel that they are building something valuable.

At the beginning, they personally manage a small supermarket.

As the business grows, they gradually become a store manager, business owner, and eventually the operator of a larger retail empire.

Progression must be visible in the physical world.

A successful store should look more developed, attractive, organized, and sophisticated than a beginner store.

The environment must reflect the player's accomplishments.

# 5. LONG-TERM PROGRESSION

## Stage 1 — Convenience Store

Features:

- Small storefront.
- Limited inventory.
- Basic shelves.
- One checkout.
- Simple customers.
- First upgrades.
- Introductory chaos events.

## Stage 2 — Neighborhood Supermarket

Features:

- Larger floor space.
- Additional checkout stations.
- Produce section.
- Bakery.
- Freezers.
- Employees.
- More advanced inventory management.
- Store customization.

## Stage 3 — Mega Supermarket

Features:

- Warehouse storage.
- Self-checkout.
- Multiple departments.
- Advanced employee roles.
- Online grocery orders.
- Delivery preparation.
- Larger customer events.

## Stage 4 — Shopping Plaza

Features:

- Café.
- Restaurant.
- Electronics store.
- Specialty retail businesses.
- Shared customer traffic.
- Plaza customization.
- Business-specific gameplay.

## Stage 5 — Retail Empire

Features:

- Multiple stores.
- Delivery fleets.
- Warehouses.
- Distribution centers.
- Regional expansion.
- Business partnerships.
- Advanced logistics.
- Commercial district development.

Only the first stage is required for the initial playable milestone.

Future stages must be documented and supported by sensible extension points, not implemented prematurely.

---

# PART II — FIRST-SESSION EXPERIENCE

# 6. THE FIRST 30 SECONDS

The first impression must be memorable.

Do not start players in an empty environment with a long tutorial.

Introduce the game through an interactive situation called:

**First Shift: Welcome to Chaos**

The player arrives at a small, attractive supermarket during a busy moment.

The store is colorful, well-lit, and visually appealing, but the staff is overwhelmed.

A shopping cart begins rolling out of control.

Customers react.

A store employee asks the player for help.

The player receives a simple interactive objective.

The objective must be understandable without reading lengthy instructions.

After completing the interaction, the player receives an immediate reward.

The sequence should establish:

- The game's humor.
- Its visual identity.
- Its interaction system.
- Its responsive controls.
- Its reward feedback.
- Its welcoming atmosphere.

The opening should be playable rather than dependent on a long cinematic.

Provide a skip option where appropriate.

# 7. FIRST 15 MINUTES

Design a structured first-session experience.

Suggested sequence:

**0:00–0:30 — Chaotic Arrival**

The player completes a short interactive challenge.

**0:30–2:00 — First Customer**

The player stocks a product and completes a checkout transaction.

**2:00–4:00 — First Upgrade**

The player purchases a meaningful store improvement.

**4:00–7:00 — Customer Rush**

The player experiences the first operational challenge.

**7:00–10:00 — Chaos Event**

A manageable event creates a memorable moment.

**10:00–12:00 — Visible Expansion**

The store gains a new section, checkout, or department.

**12:00–15:00 — Future Empire Preview**

The player discovers neighboring land and future business opportunities.

These are design targets, not mandatory timers.

Allow skilled players to progress naturally.

Avoid forced waiting and artificial delays.

# 8. PLAYER EXPERIENCE PRINCIPLES

Every meaningful interaction should provide:

- Immediate response.
- Appropriate animation.
- Clear sound feedback.
- Visual confirmation.
- Understandable success or failure states.
- Minimal unnecessary waiting.
- Consistent controls.
- Appropriate reward feedback.

Do not overwhelm players with multiple systems immediately.

Introduce features progressively.

The interface should highlight the next meaningful action.

All tutorial objectives must be completable solo.

Friends should be able to join and assist without bypassing permissions.

# 9. PLAYER RETENTION

Create reasons to return based on enjoyable gameplay rather than coercive mechanics.

Potential systems include:

- New store departments.
- Cosmetic customization.
- Meaningful business upgrades.
- New customer types.
- Chaos event variations.
- Cooperative objectives.
- Weekly challenges.
- New business opportunities.
- Neighborhood development.

Avoid manipulative countdowns, excessive daily obligations, and pay-to-win progression.

Create analytics events to measure the onboarding funnel and repeat engagement.

---

# PART III — VISUAL EXCELLENCE AND ART DIRECTION

# 10. VISUAL QUALITY IS A PRIMARY REQUIREMENT

The game must look beautiful.

Do not use the default appearance of a basic Roblox tycoon as the final visual standard.

The environment must have intentional architecture, cohesive materials, attractive lighting, detailed interiors, appealing landscaping, and consistent proportions.

The visual identity should be:

**Modern, colorful, welcoming, polished, expressive, and slightly stylized.**

Aim for the appeal of a high-quality stylized 3D management game while remaining original and performant within Roblox.

Do not copy the distinctive visual identity of an existing commercial game.

Use visual references for general quality, composition, lighting, and atmosphere rather than imitation.

# 11. ART DIRECTION

Use a consistent art direction based on:

- Stylized realism.
- Clean architectural forms.
- Soft edges.
- Attractive proportions.
- Rich but controlled colors.
- High-quality materials.
- Warm and inviting lighting.
- Readable environmental details.
- Expressive animations.
- Carefully composed interiors.

Avoid:

- Flat, unfinished buildings.
- Random colors.
- Oversized generic objects.
- Empty rooms.
- Repetitive low-detail shelves.
- Inconsistent asset styles.
- Excessive bloom.
- Harsh lighting.
- Overly reflective surfaces.
- Clutter that obstructs gameplay.
- Poorly aligned models.
- Placeholder geometry in final releases.

The game should look appealing in screenshots without requiring exaggerated visual effects.

# 12. COLOR PALETTE

Establish a documented design system.

Suggested direction:

Primary colors:

- Deep teal.
- Warm cream.
- Fresh green.
- Soft coral.
- Muted gold.

Supporting colors:

- Natural wood.
- Warm white.
- Soft gray.
- Light blue.
- Subtle neutral materials.

Use accent colors to identify departments, interactions, and gameplay states.

Do not use arbitrary colors for every new feature.

Document the palette, semantic color roles, typography, material conventions, and accessibility requirements.

# 13. SUPERMARKET EXTERIOR DESIGN

The supermarket exterior must feel like a real, carefully designed commercial building.

Include:

- Attractive architectural façade.
- Large glass storefront windows.
- Clearly designed entrance.
- Professional store signage.
- Decorative exterior lighting.
- Landscaping.
- Planters.
- Trees.
- Sidewalks.
- Parking spaces where appropriate.
- Shopping cart storage.
- Delivery access.
- Window displays.
- Attractive roofline and trim.
- Environmental details that establish scale.

The initial store must be small but beautiful.

It should look like a charming neighborhood business rather than an empty box.

Expansion must preserve visual cohesion.

The store should grow into a larger commercial building through logical architectural additions.

# 14. SUPERMARKET INTERIOR DESIGN

The interior must be visually rich, organized, and attractive.

Create a coherent store layout with:

- Welcoming entrance.
- Checkout zone.
- Grocery aisles.
- Product shelving.
- Refrigerated displays.
- Produce displays.
- Bakery area when unlocked.
- Storage access.
- Department signage.
- Ceiling lights.
- Decorative fixtures.
- Floor materials.
- Wall treatments.
- Shopping baskets and carts.
- Promotional displays.
- Employee work areas.
- Customer navigation space.

Avoid making every aisle look identical.

Use visual variety while maintaining a consistent style.

Shelves should contain recognizable, original fictional products with appealing packaging.

Products should be easy to distinguish during gameplay.

Use fictional store and product brands rather than unauthorized real-world trademarks.

# 15. ENVIRONMENTAL DETAIL

Add small details that make the world feel alive.

Examples:

- Customers browsing shelves.
- Employees walking between tasks.
- Sliding entrance doors.
- Checkout display animations.
- Refrigeration equipment.
- Subtle signage animations.
- Delivery vehicles.
- Moving shopping carts.
- Exterior pedestrians.
- Trees and landscaping.
- Appropriate ambient sound.

These details must support the experience without causing unnecessary performance costs.

Use client-side presentation where appropriate.

# 16. LIGHTING AND ATMOSPHERE

Create a professional lighting strategy.

Use supported Roblox lighting technologies and settings appropriate to current platform capabilities.

Target:

- Bright, welcoming interiors.
- Soft, natural-looking shadows.
- Controlled highlights.
- Warm accent lighting.
- Readable checkout areas.
- Balanced indoor and outdoor exposure.
- Attractive day and evening conditions.

Avoid:

- Excessive bloom.
- Washed-out surfaces.
- Overly dark interiors.
- Distracting reflections.
- Harsh contrast.
- Heavy post-processing that harms mobile performance.

Document lighting settings and performance tradeoffs.

Provide lower-cost quality configurations where appropriate.

# 17. MATERIALS AND TEXTURES

Use a consistent material library.

Potential materials:

- Painted plaster.
- Ceramic tile.
- Polished concrete.
- Brushed metal.
- Natural wood.
- Frosted glass.
- Clear storefront glass.
- Plastic fixtures.
- Fabric accents.

Prefer clean, stylized materials.

Use textures and surface detail selectively.

Avoid unnecessary high-resolution textures and excessive mesh complexity.

Maintain an asset performance budget.

# 18. STORE PERSONALIZATION

Allow players to make their stores visually distinctive.

Future customization may include:

- Exterior color themes.
- Interior wall colors.
- Floor styles.
- Shelf designs.
- Checkout designs.
- Lighting fixtures.
- Signs.
- Decorative plants.
- Furniture.
- Seasonal decorations.
- Employee uniforms.
- Store logos using approved in-game elements.

Customization must preserve gameplay readability.

Validate all placements on the server.

Provide a preview before confirming changes.

# 19. NEIGHBORHOOD DESIGN

The world outside the supermarket must be attractive and coherent.

Create a stylized commercial neighborhood with:

- Streets.
- Sidewalks.
- Streetlights.
- Trees.
- Small surrounding buildings.
- Parking.
- Delivery roads.
- Commercial plots.
- Public spaces.
- Decorative environmental storytelling.

The neighborhood should visually evolve as players expand.

Future expansion may introduce:

- Cafés.
- Restaurants.
- Shopping plazas.
- Warehouses.
- Distribution centers.
- Larger roads.
- Commercial districts.

Do not create a massive empty city before core gameplay is complete.

Build a small, polished neighborhood first.

# 20. CHARACTER DESIGN AND ANIMATION

Characters must fit the game's visual style.

NPC customers should have:

- Varied outfits.
- Recognizable silhouettes.
- Readable emotions.
- Natural movement.
- Shopping animations.
- Checkout reactions.
- Chaos event reactions.

Employees should have recognizable uniforms and roles.

Use expressive but performance-conscious animation.

Avoid identical customer appearance where practical.

Do not make animation complexity interfere with navigation or responsiveness.

# 21. VISUAL EFFECTS

Use visual effects selectively.

Examples:

- Checkout scanning feedback.
- Reward particles.
- Construction completion.
- Upgrade confirmation.
- Chaos event warnings.
- Product restocking feedback.
- Customer satisfaction reactions.

Effects should be polished and brief.

Provide options to reduce visual intensity.

Avoid excessive flashing or screen obstruction.

# 22. AUDIO DESIGN

Establish a consistent audio identity.

Include:

- Ambient supermarket sounds.
- Checkout scanner beeps.
- Cash register feedback.
- Footsteps.
- Shopping cart movement.
- Customer reactions.
- Construction sounds.
- Upgrade confirmations.
- Chaos event cues.
- Subtle background music.

Audio should enhance gameplay without becoming repetitive or overwhelming.

Provide independent sound and music volume controls.

Ensure essential information is also communicated visually.

# 23. VISUAL QUALITY GATES

A visual feature is complete only when:

- It follows the documented art direction.
- Materials are consistent.
- Lighting is appropriate.
- Proportions are coherent.
- Interactions remain readable.
- Assets are properly aligned.
- Performance is acceptable.
- Mobile presentation has been evaluated.
- Placeholder assets are clearly identified.
- Screenshots or Studio captures are available for review.

Codex must not claim a beautiful environment has been implemented merely because scripts create primitive parts.

Distinguish between:

- Blockout geometry.
- Functional prototype.
- Art pass.
- Polished environment.
- Release-ready environment.

If professional-quality models, textures, animations, or audio cannot be created with available tools, document the gap and provide a precise asset specification and implementation plan.

Do not pretend unavailable assets have been produced.

---

# PART IV — USER INTERFACE AND EXPERIENCE DESIGN

# 24. UI DESIGN SYSTEM

Create a cohesive UI design system.

The interface should feel modern, elegant, playful, and polished.

Use:

- Consistent typography.
- Rounded elements where appropriate.
- Carefully chosen spacing.
- Clear visual hierarchy.
- Subtle animations.
- Consistent iconography.
- Readable text.
- Responsive layouts.
- Accessible contrast.

Avoid generic default buttons as the final design.

Avoid excessive decorative panels.

The UI should complement the 3D environment.

# 25. REQUIRED INTERFACES

Design and implement incrementally:

- Loading screen.
- Main menu.
- New-player onboarding.
- Store HUD.
- Cash and profit display.
- Inventory menu.
- Checkout interface.
- Building mode.
- Expansion menu.
- Employee management.
- Shift summary.
- Chaos event notifications.
- Rewards screen.
- Business map.
- Cosmetic shop.
- Settings.
- Error and recovery messages.

Each interface must have documented states, interactions, navigation behavior, and accessibility considerations.

# 26. MOBILE-FIRST INTERACTION

Support touch controls from the beginning.

Ensure:

- Touch targets are appropriately sized.
- Text remains readable.
- Menus fit smaller screens.
- Important controls remain reachable.
- Interactions do not require precision mouse input.
- Gameplay remains responsive.
- HUD elements do not obstruct the world.

Test on actual mobile devices when available.

Do not claim compatibility based only on desktop simulation.

# 27. INTERACTION FEEDBACK

Every major action should have consistent feedback.

For example:

**Checkout**

- Product moves across scanner.
- Scanner sound plays.
- Display updates.
- Customer reacts.
- Currency reward is shown.

**Restocking**

- Shelf visually fills.
- Product count updates.
- Short animation plays.
- Inventory changes are confirmed.

**Expansion**

- Preview shows the future layout.
- Purchase requirements are displayed.
- Construction animation plays.
- New area becomes accessible.
- The world visibly changes.

Authoritative state changes must be server-validated.

Client animations must not be treated as proof of successful transactions.

---

# PART V — DOCUMENTATION STANDARDS

# 28. DOCUMENTATION OWNERSHIP AND VOICE

All documentation must read like normal professional engineering documentation maintained within this project.

It must not resemble an AI conversation or generated response.

Do not write:

- "The owner said..."
- "The user requested..."
- "Based on the prompt..."
- "Codex decided..."
- "The AI generated..."
- "As an AI..."
- "I was asked to..."
- "The following was requested..."
- "This document was created by the assistant..."

Use direct technical statements.

Example:

Incorrect:

"The owner wanted a beautiful supermarket."

Correct:

"The environment uses a cohesive stylized visual language with detailed interiors, coordinated materials, and balanced lighting."

Incorrect:

"Codex implemented server validation."

Correct:

"Store transactions are validated by the server before balances or inventory are modified."

Incorrect:

"The user requested multiplayer."

Correct:

"Cooperative sessions support shared operational tasks while preserving store ownership and authorization boundaries."

Use natural, professional engineering language.

Avoid repetitive, generic paragraphs and unnecessary filler.

Do not invent human-authored history, approvals, personal experience, or executed tests.

Maintain accurate licensing, contribution, and provenance records where applicable.

Ordinary technical documentation should focus on the product and implementation rather than the tools used to produce it.

# 29. DOCUMENTATION-DRIVEN DEVELOPMENT

Documentation is mandatory.

Each significant feature requires:

- Requirements.
- Design rationale.
- Architecture description.
- Data contracts.
- Security assumptions.
- Implementation references.
- Tests.
- Failure handling.
- Performance considerations.
- Known limitations.

Update documentation in the same change as implementation.

Do not mark undocumented functionality complete.

# 30. DOCUMENTATION DIRECTORY

Create the following structure progressively:

```text
docs/
├── README.md
├── project-status.md
├── requirements/
│   ├── product-requirements.md
│   ├── functional-requirements.md
│   ├── nonfunctional-requirements.md
│   └── traceability-matrix.md
├── game-design/
│   ├── game-design-document.md
│   ├── first-session-experience.md
│   ├── onboarding-flow.md
│   ├── gameplay-loops.md
│   ├── progression-system.md
│   ├── building-and-expansion.md
│   ├── customer-behavior.md
│   ├── employee-system.md
│   ├── chaos-director.md
│   ├── business-types.md
│   ├── economy-balancing.md
│   ├── multiplayer-design.md
│   └── content-roadmap.md
├── visual-design/
│   ├── art-direction.md
│   ├── environment-design.md
│   ├── supermarket-interior.md
│   ├── supermarket-exterior.md
│   ├── neighborhood-design.md
│   ├── lighting-guide.md
│   ├── material-library.md
│   ├── character-design.md
│   ├── animation-guide.md
│   ├── ui-design-system.md
│   ├── audio-design.md
│   └── visual-quality-checklist.md
├── architecture/
│   ├── system-overview.md
│   ├── client-server-architecture.md
│   ├── business-engine.md
│   ├── service-dependencies.md
│   ├── networking-contracts.md
│   ├── data-models.md
│   ├── persistence-design.md
│   ├── commerce-architecture.md
│   ├── performance-design.md
│   └── architecture-decisions/
├── development/
│   ├── getting-started.md
│   ├── environment-setup.md
│   ├── repository-structure.md
│   ├── coding-standards.md
│   ├── development-workflow.md
│   ├── testing-guide.md
│   ├── debugging-guide.md
│   ├── troubleshooting.md
│   ├── dependency-management.md
│   └── contribution-guide.md
├── security/
│   ├── security-architecture.md
│   ├── threat-model.md
│   ├── risk-register.md
│   ├── remote-security.md
│   ├── economy-security.md
│   ├── purchase-security.md
│   ├── persistence-security.md
│   ├── abuse-prevention.md
│   ├── incident-response.md
│   └── security-test-matrix.md
├── operations/
│   ├── deployment-guide.md
│   ├── release-checklist.md
│   ├── rollback-guide.md
│   ├── monitoring.md
│   ├── backup-and-recovery.md
│   ├── live-operations.md
│   └── release-readiness.md
├── business/
│   ├── business-plan.md
│   ├── revenue-model.md
│   ├── cost-model.md
│   ├── analytics-and-kpis.md
│   ├── player-retention.md
│   └── marketing-strategy.md
├── assets/
│   ├── asset-register.md
│   ├── asset-standards.md
│   ├── third-party-licenses.md
│   └── asset-production-workflow.md
├── provenance/
│   ├── creator-decisions.md
│   ├── contributions.md
│   └── intellectual-property-notes.md
└── releases/
    ├── changelog.md
    └── release-template.md
```

Do not create empty documents merely to satisfy the directory structure.

Create documents relevant to the current phase.

Maintain a backlog for future documentation.

# 31. REQUIREMENTS TRACEABILITY

Assign stable identifiers to important features.

Examples:

- ONBOARDING-001
- STORE-EXP-001
- ECON-001
- CUSTOMER-001
- CHAOS-001
- MULTI-001
- SECURITY-001
- VISUAL-001

Link requirements to:

- Design specifications.
- Architecture.
- Implementation.
- Tests.
- Security controls.
- Verification evidence.
- Release status.

Maintain the traceability matrix.

# 32. ARCHITECTURE DECISION RECORDS

Create ADRs for significant decisions.

Each ADR must include:

- Context.
- Problem.
- Alternatives.
- Decision.
- Rationale.
- Tradeoffs.
- Consequences.
- Status.

Use Mermaid diagrams when they improve clarity.

---

# PART VI — REPOSITORY AND DEVELOPMENT TOOLING

# 33. REPOSITORY STRUCTURE

Use a private Git repository.

Recommended structure:

```text
supermarket-chaos/
├── README.md
├── MASTER_SPECIFICATION.md
├── AGENTS.md
├── LICENSE
├── .gitignore
├── .editorconfig
├── .github/
│   └── workflows/
├── docs/
├── src/
│   ├── client/
│   ├── server/
│   └── shared/
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── security/
│   └── performance/
├── scripts/
├── assets/
├── config/
├── default.project.json
├── stylua.toml
├── selene.toml
└── aftman.toml
```

Adapt the structure to supported tool requirements.

# 34. TOOLCHAIN

Evaluate and configure:

- Roblox Studio.
- Luau.
- Git.
- GitHub.
- Rojo.
- StyLua.
- Selene.
- Luau Language Server.
- Aftman or an appropriate supported tool manager.
- Roblox-compatible testing framework.
- GitHub Actions.

Use Wally only when justified.

Pin dependency versions where appropriate.

Document installation and configuration.

# 35. AGENTS.MD

Create persistent Codex operating instructions.

Every future development session must:

1. Read the project specification.
2. Read the current project status.
3. Inspect relevant existing code.
4. Review architectural decisions.
5. Identify affected systems.
6. Produce an implementation plan for significant changes.
7. Define acceptance criteria.
8. Implement a small, complete change.
9. Run available checks.
10. Report actual results.
11. Update documentation.
12. Record risks.
13. Update project status.
14. Preserve security boundaries.
15. Avoid unnecessary dependencies.
16. Avoid unapproved production changes.

Never claim an unavailable test was executed.

Never silently change the economy, persistence schema, commerce logic, or authorization rules.

# 36. SESSION CONTINUITY

Maintain `docs/project-status.md`.

Record:

- Current milestone.
- Completed functionality.
- Files changed.
- Tests executed.
- Unverified functionality.
- Known defects.
- Security risks.
- Documentation status.
- Pending decisions.
- Next recommended task.

Use this file to resume work in later Codex sessions.

---

# PART VII — TECHNICAL ARCHITECTURE

# 37. ARCHITECTURAL PRINCIPLES

Use:

- Server-authoritative gameplay.
- Modular services.
- Strict Luau typing where practical.
- Explicit dependencies.
- Validated networking.
- Data-driven configuration.
- Versioned persistence.
- Testable business logic.
- Controlled replication.
- Structured error handling.

Avoid unnecessary frameworks and circular dependencies.

# 38. SHARED BUSINESS ENGINE

Design a reusable foundation for future business types.

Core responsibilities:

- Business ownership.
- Building placement.
- Inventory.
- Economy.
- Customers.
- Employees.
- Progression.
- Operational events.
- Deliveries.
- Permissions.
- Persistence.

Implement only the parts needed for the current milestone.

Document extension points for restaurants, warehouses, and shopping plazas.

# 39. SERVICE RESPONSIBILITIES

Evaluate services such as:

- PlayerSessionService.
- PlayerDataService.
- StoreService.
- BuildingService.
- ExpansionService.
- InventoryService.
- CustomerService.
- CheckoutService.
- EconomyService.
- EmployeeService.
- ChaosEventService.
- ProgressionService.
- BusinessService.
- CommerceService.
- AnalyticsService.

These are conceptual boundaries.

Use simpler structures where appropriate.

---

# PART VIII — CORE GAMEPLAY SYSTEMS

# 40. STORE BUILDING

Implement:

- Purchasable plots.
- Floor expansion.
- Shelf placement.
- Checkout placement.
- Department construction.
- Object rotation.
- Object repositioning.
- Collision validation.
- Ownership checks.
- Placement limits.
- Persistent layouts.

Clients may preview placement.

The server validates final changes.

Use compact, versioned layout records.

# 41. CUSTOMER AI

Support states such as:

- Spawn.
- Enter.
- Browse.
- Select products.
- Navigate.
- Queue.
- Checkout.
- Exit.

Implement bounded concurrency.

Avoid expensive pathfinding loops.

Handle navigation failures.

Customers must not create authoritative currency.

# 42. CHAOS DIRECTOR

Create an extensible event system.

Initial events:

- Customer Rush.
- Power Outage.
- Runaway Shopping Cart.

Each event must define:

- Identifier.
- Eligibility.
- Difficulty.
- Duration.
- Objectives.
- Rewards.
- Cleanup.
- Failure recovery.

Chaos events must be funny, manageable, and rewarding.

Do not permanently destroy saved progress.

Do not adjust difficulty based on Robux spending.

# 43. EMPLOYEES

Support future roles such as:

- Cashier.
- Stock clerk.
- Cleaner.
- Delivery worker.
- Customer assistant.
- Department specialist.

Employees should reduce repetitive work.

Automation must not eliminate all meaningful gameplay.

# 44. MULTIPLAYER

Begin with a target of four cooperating players per store.

Support:

- Ownership.
- Invitations.
- Session membership.
- Employee roles.
- Shared tasks.
- Contribution-based rewards.
- Disconnect recovery.
- Authorization boundaries.

Prevent unauthorized modification of another player's store or money.

All introductory objectives must remain solo-playable.

---

# PART IX — ECONOMY AND PERSISTENCE

# 45. ECONOMY

Use fictional in-game currency separate from Robux.

The server controls:

- Balances.
- Revenue.
- Expenses.
- Purchases.
- Upgrades.
- Wages.
- Rewards.
- Unlocks.

Use integer-denominated currency where practical.

Prevent:

- Negative transactions.
- Duplicate rewards.
- Invalid identifiers.
- Replayed requests.
- Unauthorized modifications.
- Race conditions.
- Numeric boundary abuse.

Define and test economic invariants.

# 46. PERSISTENCE

Use supported Roblox persistence APIs.

Implement:

- Versioned schemas.
- Safe defaults.
- Session ownership.
- Conflict handling.
- Save retries.
- Rate-limit awareness.
- Data migrations.
- Shutdown handling.
- Corruption detection.
- Recovery procedures.

Do not assume exactly-once persistence.

Avoid stale writes overwriting newer data.

Document platform limitations.

---

# PART X — MONETIZATION

# 47. FAIR MONETIZATION

Initial products may include:

- Store themes.
- Decorative furniture.
- Employee uniforms.
- Checkout effects.
- Cosmetic bundles.
- Additional design slots.

Do not make purchases mandatory for core gameplay.

Avoid misleading purchase prompts.

Verify current Roblox policies before implementation.

# 48. COMMERCE SECURITY

For developer products:

- Use supported receipt processing.
- Verify product identifiers.
- Track fulfillment durably.
- Implement idempotent grants.
- Handle duplicate callbacks.
- Handle persistence failures.
- Reconcile incomplete fulfillment.

For game passes:

- Verify ownership through authoritative APIs.
- Do not trust client entitlement claims.

Never grant purchases based solely on client notifications.

Do not activate production commerce without approval.

---

# PART XI — SECURITY ENGINEERING

# 49. THREAT MODEL

Consider:

- Malicious clients.
- RemoteEvent exploitation.
- RemoteFunction abuse.
- Currency manipulation.
- Unauthorized building.
- Inventory duplication.
- Purchase replay.
- Data corruption.
- Permission escalation.
- Resource exhaustion.
- Unsafe administration tools.
- Third-party dependency risks.

Treat all client input as untrusted.

Validate types, ranges, identifiers, ownership, permissions, current state, and request frequency.

# 50. SECURITY TESTS

Create tests for:

- Forged requests.
- Invalid types.
- Out-of-range values.
- Cross-player ownership attacks.
- Duplicate transactions.
- Replay attempts.
- Request flooding.
- Concurrent operations.
- Persistence failures.
- Purchase reconciliation.

Security defects affecting money, ownership, purchases, or persistent progress must block release.

---

# PART XII — PERFORMANCE

# 51. PERFORMANCE BUDGETS

Define measurable budgets for:

- NPC counts.
- Pathfinding frequency.
- Physics objects.
- Network traffic.
- Replication.
- DataStore requests.
- Client memory.
- Frame rate.
- Asset complexity.
- Texture usage.
- Lighting cost.
- Visual effects.

Use actual Roblox profiling tools.

Measure desktop and mobile performance separately.

Do not fabricate benchmarks.

# 52. VISUAL PERFORMANCE SCALING

Provide appropriate quality scaling for:

- Shadows.
- Decorative objects.
- Particle effects.
- Ambient animations.
- Lighting effects.
- Draw distance where supported.
- Environmental density.

Do not sacrifice gameplay readability.

Avoid assuming unsupported control over Roblox graphics settings.

---

# PART XIII — TESTING AND QUALITY ASSURANCE

# 53. UNIT TESTING

Test:

- Economy calculations.
- Inventory operations.
- Building validation.
- Unlock conditions.
- Reward calculations.
- Permissions.
- Chaos event selection.
- Data migrations.

# 54. INTEGRATION TESTING

Test:

- Service interactions.
- Persistence.
- Store expansion.
- Multiplayer.
- Commerce.
- Recovery.
- Onboarding progression.

# 55. MANUAL ROBLOX STUDIO TESTING

Provide procedures for:

- Player movement.
- Interactions.
- Customer navigation.
- Multiplayer.
- Physics.
- Mobile UI.
- Save and reload.
- Purchases.
- Chaos events.
- Visual quality.
- Performance.

Never mark unexecuted tests as passed.

# 56. PLAYER EXPERIENCE TESTING

Measure:

- First interaction completion.
- First sale completion.
- Time to first reward.
- First upgrade completion.
- First shift completion.
- Second shift starts.
- Tutorial abandonment.
- Session duration.
- Replay intent.

Suggested initial design targets:

- First interaction completion: 90% or higher.
- First sale completion: 85% or higher.
- First upgrade completion: 70% or higher.
- First shift completion: 65% or higher.
- Voluntary second shift: 40% or higher.

These are hypotheses for testing, not verified platform benchmarks.

---

# PART XIV — CI/CD AND DEPLOYMENT

# 57. CONTINUOUS INTEGRATION

Configure supported checks for:

- Formatting.
- Linting.
- Type checking.
- Unit tests.
- Build validation.
- Dependency checks.
- Documentation validation.

Use least-privilege credentials.

Protect deployment secrets.

# 58. ENVIRONMENTS

Maintain separate:

- Development.
- Staging.
- Production.

Use environment-specific Roblox identifiers and commerce settings.

Do not mix test data with production data.

# 59. DEPLOYMENT GUIDE

Document:

1. Roblox Studio installation.
2. Roblox experience creation.
3. Local repository setup.
4. Rojo synchronization.
5. Local playtesting.
6. Multiplayer testing.
7. Staging publication.
8. DataStore configuration.
9. Commerce configuration.
10. Game settings.
11. Icons and thumbnails.
12. Production publication.
13. Monitoring.
14. Rollback procedures.

Distinguish automated actions from manual Roblox Studio or Creator Dashboard steps.

Never publish without approval.

# 60. ROLLBACK

Document code rollback, configuration rollback, and persistent-data recovery separately.

Do not assume reverting code restores player data.

Plan forward-compatible migrations.

---

# PART XV — BUSINESS OPERATIONS

# 61. ANALYTICS

Define:

- Onboarding completion.
- Session duration.
- Day-1 retention.
- Day-7 retention.
- Expansion progression.
- Chaos participation.
- Purchase conversion.
- Revenue per paying player.
- Acquisition costs.
- Technical failure rates.

Respect privacy requirements.

Avoid unnecessary personal-data collection.

# 62. FINANCIAL PLANNING

Create conservative, base, and optimistic scenarios.

Distinguish:

- Robux sales.
- Earned Robux.
- DevEx proceeds.
- Gross revenue.
- Operating expenses.
- Net business profit.

Verify current platform economics.

Do not guarantee earnings.

# 63. MARKETING

Plan:

- Gameplay clips.
- Visual showcases.
- Community feedback.
- Update announcements.
- Seasonal events.
- New business expansions.

Avoid expensive advertising before retention is validated.

---

# PART XVI — ASSET MANAGEMENT AND PROVENANCE

# 64. ASSET REGISTRY

Maintain records for:

- Asset identifier.
- Asset type.
- Source.
- License.
- Roblox asset ID.
- Performance characteristics.
- Modification history.

Use original or properly licensed assets.

Avoid unverified third-party scripts.

# 65. PROJECT PROVENANCE

Maintain accurate records of:

- Creative decisions.
- Architecture decisions.
- Contributions.
- Asset origins.
- Third-party licenses.
- Significant revisions.

Use professional documentation language.

Do not fabricate authorship or remove legally required attribution.

---

# PART XVII — DEVELOPMENT PHASES AND QUALITY GATES

# 66. PHASE 0 — FOUNDATION

Deliver:

- Repository structure.
- README.
- MASTER_SPECIFICATION.md.
- AGENTS.md.
- Product requirements.
- Game Design Document.
- Visual Design Bible.
- Architecture.
- Threat model.
- Documentation index.
- Toolchain configuration.
- Initial CI.
- Development backlog.
- Beginner setup guide.

Quality gate G0: Architecture and project foundation approved.

# 67. PHASE 1 — BEAUTIFUL FIRST PLAYABLE

Implement:

- A polished small supermarket exterior.
- A cohesive interior.
- Attractive lighting.
- Basic landscaping.
- Player interactions.
- Shelves.
- Customers.
- Checkout.
- Shift system.
- One chaos event.
- Basic rewards.
- First upgrade.
- Onboarding.

Quality gate G1: One complete playable shift verified.

A functional but visually unfinished prototype must be identified as such.

# 68. PHASE 2 — PROGRESSION

Implement:

- Inventory.
- Upgrades.
- Economy balancing.
- Basic physical expansion.
- Persistent player data.
- Store customization foundation.

Quality gate G2: Progression and persistence verified.

# 69. PHASE 3 — MULTIPLAYER

Implement:

- Cooperative sessions.
- Roles.
- Permissions.
- Shared objectives.
- Additional chaos events.

Quality gate G3: Multiplayer behavior verified.

# 70. PHASE 4 — ADVANCED STORE OPERATIONS

Implement:

- Employees.
- Automation.
- Departments.
- More customization.
- Advanced progression.

Quality gate G4: Store systems verified.

# 71. PHASE 5 — SECURITY AND COMMERCE

Complete:

- Security hardening.
- Persistence recovery.
- Commerce integration.
- Purchase verification.
- Analytics.
- Failure testing.

Quality gate G5: Security and commerce review passed.

# 72. PHASE 6 — BETA AND RELEASE

Complete:

- External playtesting.
- Visual polish.
- Performance optimization.
- Mobile validation.
- Security review.
- Documentation review.
- Staging release.
- Production approval.

Quality gate G6: Public launch readiness approved.

# 73. PHASE 7 — RETAIL EMPIRE EXPANSION

After validating the core game, introduce:

- Warehouse.
- Delivery gameplay.
- Restaurants.
- Cafés.
- Shopping plaza.
- Multiple locations.
- Distribution centers.
- Retail empire progression.

Each expansion must pass design, security, performance, and release reviews.

---

# PART XVIII — DEFINITION OF DONE

# 74. FEATURE COMPLETION

A feature is complete only when:

1. Requirements are satisfied.
2. Implementation is verified.
3. Security boundaries are reviewed.
4. Relevant tests pass.
5. Documentation is current.
6. Performance is acceptable.
7. Failure handling is defined.
8. Known limitations are recorded.
9. Manual verification steps exist.
10. Visual quality meets the current milestone standard.
11. Required approvals are obtained.

Generated code alone does not establish completion.

---

# PART XIX — IMMEDIATE EXECUTION

# 75. BEGIN PHASE 0

Inspect the repository and available development environment.

Do not assume tools are installed.

Perform the following:

1. Assess technical feasibility.
2. Identify major engineering risks.
3. Create product requirements.
4. Create the Game Design Document.
5. Create the first-session experience specification.
6. Create the Visual Design Bible.
7. Define the supermarket exterior design.
8. Define the supermarket interior design.
9. Establish the color and material systems.
10. Establish the lighting strategy.
11. Define the initial neighborhood.
12. Design the client-server architecture.
13. Define Business Engine boundaries.
14. Create the threat model.
15. Establish documentation standards.
16. Create the repository structure.
17. Create AGENTS.md.
18. Configure supported development tools.
19. Create initial quality-check workflows.
20. Create the requirements traceability matrix.
21. Create the initial development backlog.
22. Write beginner-friendly Roblox Studio setup instructions.
23. Create the project status document.
24. Record unresolved decisions and risks.

Create actual files where possible.

Run available checks.

If a tool, asset, account, or capability is unavailable, document the limitation and the exact manual steps needed.

Do not pretend that 3D assets, screenshots, animations, or runtime tests exist if they have not been produced.

# 76. PHASE 0 COMPLETION REPORT

Provide:

- Executive summary.
- Repository structure.
- Game Design Document status.
- Visual Design Bible summary.
- Supermarket visual direction.
- Architecture diagram.
- Documentation inventory.
- Threat model summary.
- Toolchain status.
- Test results.
- Initial backlog.
- Known risks.
- Required manual actions.
- Recommended Phase 1 sprint.

Use professional engineering language.

Do not frame project documentation as an AI-generated response.

Stop at the G0 review gate and request approval before beginning Phase 1.

**Begin Phase 0 now.**