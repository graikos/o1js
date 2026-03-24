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

## Architecture

```
src/
├── index.ts                    # Public API - all exports defined here
├── lib/
│   ├── provable/               # Core provable type system
│   │   ├── field.ts            # Field element (base type for all ZK values)
│   │   ├── bool.ts, int.ts     # Bool, UInt32, UInt64, Int64
│   │   ├── wrapped.ts          # Field, Bool, Group, Scalar exports
│   │   ├── provable.ts         # Provable namespace (if, switch, witness, etc.)
│   │   ├── types/              # Struct, provable interfaces, type derivers
│   │   ├── gadgets/            # Low-level circuit primitives (range checks, bitwise, SHA, ECDSA)
│   │   ├── crypto/             # Poseidon, Keccak, signatures, encryption, curves
│   │   ├── foreign-field.ts    # Non-native field arithmetic
│   │   ├── merkle-tree*.ts     # Merkle trees (standard, indexed)
│   │   └── dynamic-array.ts    # Variable-length arrays in circuits
│   ├── mina/
│   │   ├── v1/                 # Current stable API
│   │   │   ├── zkapp.ts        # SmartContract, @method, @state
│   │   │   ├── account-update.ts # AccountUpdate, Permissions
│   │   │   ├── state.ts        # On-chain state management
│   │   │   ├── transaction.ts  # Transaction building
│   │   │   ├── fetch.ts        # GraphQL queries to Mina nodes
│   │   │   ├── actions/        # Reducer, BatchReducer, OffchainState
│   │   │   └── token/          # TokenContract, forest iterator
│   │   └── v2/                 # Experimental next-gen API (Experimental.V2)
│   ├── proof-system/           # ZkProgram, proofs, verification keys, caching
│   └── util/                   # Utility types
├── bindings/                   # OCaml/Rust backend (git submodules)
│   ├── compiled/               # Prebuilt WASM + JS artifacts (version-controlled)
│   ├── ocaml/                  # Js_of_ocaml bindings to Pickles/snarky
│   ├── crypto/                 # Generated crypto constants
│   └── mina-transaction/       # Generated transaction type layouts
├── mina-signer/                # Standalone Mina transaction signer (separate build)
├── examples/                   # Example zkApps and usage patterns
└── tests/                      # Integration/e2e test files
```

### Key Architectural Concepts

**Dual execution model:** Code inside `@method` or `Provable.witness()` runs twice — once at compile time (building the constraint system with symbolic variables) and once at prove time (with real witness values). This means:
- No standard `if/else` on provable values — use `Provable.if()`
- No dynamic array indexing — use `Provable.switch()`
- All conditional branches are always evaluated (constraint generation is eager)
- Side effects during compilation won't re-run during proving

**Bindings layer:** The Rust proof system (Kimchi) is compiled to WASM, and OCaml code (Pickles, snarky) is transpiled to JS via js_of_ocaml. Both are stored as prebuilt artifacts in `src/bindings/compiled/`. You rarely need to rebuild these unless modifying the OCaml/Rust code.

**Submodules:** After cloning, run `git submodule update --init --recursive`. The Mina repo is a submodule containing the OCaml/Rust backend. Run `git submodule status` if you see unexpected build failures.

### Two Test Patterns

1. **Jest tests** (`*.test.ts`): Run via `./jest <file>`. Use `@jest/globals` or standard Jest APIs. Located throughout `src/`.
2. **Unit tests** (`*.unit-test.ts`): Plain TypeScript scripts that use `expect` from the `expect` package directly. Run via `node` after building. Located in `src/lib/`.

### Mina-signer

The `src/mina-signer/` package has its own build step. Before running mina-signer tests: `cd src/mina-signer && npm run build && cd ../..`

## Pre-commit Hooks

Husky is configured but opt-in: `git config husky.optin true` enables a pre-commit hook that auto-fixes formatting on staged files. You can skip lint checks on a PR by adding the `skip-lint` label.

## Also Read

- `AGENT.md` — Detailed context for AI agents including common pitfalls and the circuit model
- `AGENT_LOG.md` — Append-only log of hard-won lessons from previous agent sessions
- `README-dev.md` — Full build guide including bindings rebuilding and debugging
