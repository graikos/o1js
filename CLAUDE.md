# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**o1js v2.14.0** | Last updated: 2026-03-24

o1js is the TypeScript SDK for writing zero-knowledge applications on Mina Protocol. It compiles TypeScript into zk-SNARK circuits, generates proofs, and interacts with the Mina blockchain.

## Build & Development Commands

```bash
# Install and build (downloads prebuilt OCaml/WASM bindings from CI)
npm install
npm run build                # Build for Node.js (most common)
npm run build:web            # Build for browser
npm run build:dev            # TypeScript-only build (no bindings check)

# Run a single test file (preferred way to run individual tests)
./jest <path/to/test.ts>
# This is a wrapper for: NODE_OPTIONS=--experimental-vm-modules npx jest <path>

# Run a single TypeScript file directly
./run <path/to/file.ts> --bundle

# Test suites
npm run test                 # All jest tests (finds *.test.ts in src/)
npm run test:unit            # Unit tests (runs compiled *.unit-test.js from dist/node/)
npm run test:integration     # Integration tests (runs example zkApps)
npm run test:e2e             # Playwright browser tests

# Linting and formatting
npm run lint                 # oxlint
npm run lint:fix             # oxlint with auto-fix
npm run format <file>        # prettier --write
npm run format:check <file>  # prettier --check
```

**Important:** Unit tests (`*.unit-test.ts`) are run as plain Node scripts after building (`npm run build` then `node dist/node/...`), not through Jest. Jest tests use `*.test.ts` suffix. The default test timeout is 1,000,000ms because proof generation is slow.

**Mina-signer** has its own build step: `cd src/mina-signer && npm run build && cd ../..`

**Pre-commit hooks** are opt-in: `git config husky.optin true`. Skip lint on a PR with the `skip-lint` label.

## Also Read

- `AGENT.md` — **Read this next.** Architecture, key concepts, circuit model, common pitfalls, and file organization
- `AGENT_LOG.md` — Append-only log of hard-won lessons from previous agent sessions
- `README-dev.md` — Full build guide including bindings rebuilding and debugging
