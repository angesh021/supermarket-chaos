# Repository working agreement

## Scope and truthfulness
- Keep work within the currently approved phase. Phase 0 ends at G0; do not begin Phase 1 implementation without approval.
- The server is authoritative for currency, inventory, ownership, permissions, transactions, progression, and persistence.
- Never claim a test, Studio play session, build, asset, benchmark, or publication succeeded unless it was run and observed. Label hypotheses and unverified assumptions.
- Do not publish to Roblox or activate production commerce without explicit approval.
- Use original or licensed assets only; record source, rights, IDs and modifications in `docs/operations/ASSETS_AND_PROVENANCE.md`.

## Engineering
- Prefer small, typed, modular Luau services with explicit dependencies and clear ownership.
- Treat every client argument as untrusted. Validate type, size, identifier, range, state, owner, permission and request rate on the server.
- Keep client presentation separate from authoritative rules. Share pure domain logic where it is safe and useful.
- Keep requirements, security assumptions, test procedures and known limitations documented with features.
- Avoid unnecessary packages and Toolbox scripts. Review any dependency and pin its version/source.
- Preserve existing user changes. Do not commit secrets, place IDs, API keys or private player data.

## Checks
- Run formatting, lint and build checks available for the touched files. Record command and outcome; do not describe unavailable Studio/runtime checks as passed.
- Use Rojo project mapping in `default.project.json`. Keep scripts in `src/` and project documentation in `docs/`.
- Add CI checks only when their commands and prerequisites are reproducible in the runner.

## Review
- Complete one playable, measurable milestone at a time. Every feature must include acceptance criteria, server/client boundaries, failure handling, and manual Studio verification steps.
- Record meaningful architecture changes in `docs/decisions/`.
