.PHONY: test test-unit test-integration test-e2e test-all clean-test

# Configuration
EMACS ?= emacs
EMACSCLIENT ?= emacsclient
TEST_FILE = test/claudemacs-test.el
ACTIONS_TEST_FILE = test/claudemacs-actions-test.el
PROJECTILE_INTEGRATION_TEST_FILE = test/claudemacs-projectile-integration-test.el

# Default target
test: test-unit
	@echo "✓ Unit tests completed"

# Unit tests - fast, no external dependencies
test-unit:
	@echo "Running unit tests..."
	$(EMACS) -batch -l $(TEST_FILE) -f ert-run-tests-batch-and-exit "^claudemacs-test-.*" || exit 1
	$(EMACS) -batch -l $(ACTIONS_TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :unit))" || exit 1
	$(EMACS) -batch -l $(PROJECTILE_INTEGRATION_TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :integration))" || exit 1

# TDD tests - simple batch-mode tests for development
test-tdd:
	@echo "Running TDD batch-mode tests..."
	$(EMACS) -batch -l $(ACTIONS_TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :tdd))" || exit 1

# Integration tests - with mocked dependencies
test-integration:
	@echo "Running integration tests..."
	$(EMACS) -batch -l $(TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :integration))" || exit 1
	$(EMACS) -batch -l $(ACTIONS_TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :integration))" || exit 1
	$(EMACS) -batch -l $(PROJECTILE_INTEGRATION_TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :integration))" || exit 1

# End-to-end tests - requires Claude CLI
test-e2e:
	@echo "Running end-to-end tests..."
	@if command -v claude >/dev/null 2>&1; then \
		$(EMACS) -batch -l $(TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :e2e))"; \
		$(EMACS) -batch -l $(ACTIONS_TEST_FILE) --eval "(ert-run-tests-batch-and-exit '(tag :e2e))"; \
	else \
		echo "⚠ Skipping e2e tests (Claude CLI not found)"; \
	fi

# Run all test categories
test-all: test-unit test-integration test-e2e
	@echo "✓ All test categories completed"

# Run specific test pattern
test-specific:
	@echo "Running tests matching pattern: $(TEST_PATTERN)"
	$(EMACS) -batch -l $(TEST_FILE) -l $(ACTIONS_TEST_FILE) -l $(PROJECTILE_INTEGRATION_TEST_FILE) -f ert-run-tests-batch-and-exit "$(TEST_PATTERN)"

# Validate test file loads correctly
test-load:
	@echo "Validating test files load without errors..."
	$(EMACS) -batch -l $(TEST_FILE) --eval "(message \"✓ Test file loaded successfully\")"
	$(EMACS) -batch -l $(ACTIONS_TEST_FILE) --eval "(message \"✓ Actions test file loaded successfully\")"
	$(EMACS) -batch -l $(PROJECTILE_INTEGRATION_TEST_FILE) --eval "(message \"✓ Projectile integration test file loaded successfully\")"

# Clean up test artifacts
clean-test:
	@echo "Cleaning up test artifacts..."
	@find . -name "*-test.log" -delete 2>/dev/null || true
	@find . -name "claudemacs-test-*" -type d -exec rm -rf {} + 2>/dev/null || true

# Help target
help:
	@echo "Claudemacs Test Targets:"
	@echo "  test            - Run unit tests (default)"
	@echo "  test-unit       - Run unit tests only"
	@echo "  test-integration- Run integration tests"
	@echo "  test-e2e        - Run end-to-end tests (requires Claude CLI)"
	@echo "  test-all        - Run all test categories"
	@echo "  test-specific   - Run specific pattern (use TEST_PATTERN=...)"
	@echo "  test-load       - Validate test file loads correctly"
	@echo "  clean-test      - Clean up test artifacts"
	@echo "  help            - Show this help"
