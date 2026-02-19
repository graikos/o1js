#!/usr/bin/env bash
set -Eeuo pipefail

# shared libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/ux.sh"

# paths
ROOT_DIR="$(get_repo_root)"

# setup
setup_script "${BASH_SOURCE[0]}" "VK regression check"

cd "$ROOT_DIR"

# steps
bold "Checking verification keys for regressions"

info "Running regression checks..."
info "Backend: wasm"
run_cmd env -u O1JS_REQUIRE_NATIVE_BINDINGS VK_TEST=1 ./run ./tests/vk-regression/vk-regression.ts --bundle
run_cmd env -u O1JS_REQUIRE_NATIVE_BINDINGS VK_TEST=2 ./run ./tests/vk-regression/vk-regression.ts --bundle

info "Backend: native"
run_cmd env O1JS_REQUIRE_NATIVE_BINDINGS=1 VK_TEST=1 ./run ./tests/vk-regression/vk-regression.ts --bundle
run_cmd env O1JS_REQUIRE_NATIVE_BINDINGS=1 VK_TEST=2 ./run ./tests/vk-regression/vk-regression.ts --bundle
ok "Verification keys regression check completed"

success "VK regression check complete"
