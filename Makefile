# Observability Swift Client Makefile
# Provides convenient targets for XcodeGen project management

# Project configuration
PROJECT_NAME := Observability
SCHEME_NAME := Observability
PROJECT_FILE := $(PROJECT_NAME).xcodeproj
XCODEGEN_SPEC := project.yml

# XcodeGen configuration
XCODEGEN_VERSION ?= 2.40.0
XCODEGEN_BINARY := .build/xcodegen/$(XCODEGEN_VERSION)/xcodegen

# Xcode configuration
CONFIGURATION ?= Debug
PLATFORM ?= iOS
SIMULATOR_NAME ?= "iPhone 16 Pro"

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
RESET := \033[0m

.PHONY: help
help: ## Show this help message
	@echo "$(PURPLE)Observability Swift Client - Makefile Help$(RESET)"
	@echo ""
	@echo "$(CYAN)Available targets:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(CYAN)Examples:$(RESET)"
	@echo "  make install          # Install XcodeGen"
	@echo "  make generate         # Generate Xcode project"
	@echo "  make build            # Build the project"
	@echo "  make test             # Run all tests"
	@echo "  make clean            # Clean build artifacts"

# XcodeGen Management
.PHONY: install
install: ## Install XcodeGen
	@echo "$(BLUE)Installing XcodeGen $(XCODEGEN_VERSION)...$(RESET)"
	@mkdir -p .build/xcodegen/$(XCODEGEN_VERSION)
	@curl -L -o $(XCODEGEN_BINARY) https://github.com/yonaskolb/XcodeGen/releases/download/$(XCODEGEN_VERSION)/xcodegen.zip
	@unzip -p $(XCODEGEN_BINARY) xcodegen/bin/xcodegen > $(XCODEGEN_BINARY)
	@chmod +x $(XCODEGEN_BINARY)
	@rm -f xcodegen.zip
	@echo "$(GREEN)✓ XcodeGen installed successfully$(RESET)"

.PHONY: update-xcodegen
update-xcodegen: ## Update XcodeGen to latest version
	@echo "$(BLUE)Updating XcodeGen to latest version...$(RESET)"
	@LATEST_VERSION=$$(curl -s https://api.github.com/repos/yonaskolb/XcodeGen/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'); \
	echo "$(YELLOW)Latest version: $$LATEST_VERSION$(RESET)"; \
	$(MAKE) install XCODEGEN_VERSION=$$LATEST_VERSION

.PHONY: check-xcodegen
check-xcodegen: ## Check if XcodeGen is installed
	@if [ ! -f "$(XCODEGEN_BINARY)" ]; then \
		echo "$(RED)XcodeGen not found. Installing...$(RESET)"; \
		$(MAKE) install; \
	else \
		echo "$(GREEN)✓ XcodeGen is installed$(RESET)"; \
	fi

# Project Generation
.PHONY: generate
generate: check-xcodegen ## Generate Xcode project from project.yml
	@echo "$(BLUE)Generating Xcode project...$(RESET)"
	@$(XCODEGEN_BINARY) generate --spec $(XCODEGEN_SPEC)
	@echo "$(GREEN)✓ Project generated successfully$(RESET)"

.PHONY: generate-force
generate-force: check-xcodegen ## Force regenerate Xcode project (clean first)
	@echo "$(BLUE)Force regenerating Xcode project...$(RESET)"
	@rm -rf $(PROJECT_FILE)
	@$(MAKE) generate

# Xcode Operations
.PHONY: open
open: generate ## Open project in Xcode
	@echo "$(BLUE)Opening project in Xcode...$(RESET)"
	@open $(PROJECT_FILE)

.PHONY: build
build: generate ## Build the project
	@echo "$(BLUE)Building project ($(CONFIGURATION))...$(RESET)"
	@xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -configuration $(CONFIGURATION) build

.PHONY: build-all
build-all: generate ## Build for all platforms
	@echo "$(BLUE)Building for all platforms...$(RESET)"
	@xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" build
	@xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=macOS" build

.PHONY: test
test: generate ## Run all tests
	@echo "$(BLUE)Running tests...$(RESET)"
	@xcodebuild test -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)"

.PHONY: test-unit
test-unit: generate ## Run unit tests only
	@echo "$(BLUE)Running unit tests...$(RESET)"
	@xcodebuild test -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" -only-testing:ObservabilityTests

.PHONY: test-ui
test-ui: generate ## Run UI tests only
	@echo "$(BLUE)Running UI tests...$(RESET)"
	@xcodebuild test -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" -only-testing:ObservabilityUITests

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(RESET)"
	@xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) clean
	@rm -rf DerivedData
	@echo "$(GREEN)✓ Clean completed$(RESET)"

.PHONY: clean-all
clean-all: clean ## Clean everything including generated project
	@echo "$(BLUE)Cleaning everything...$(RESET)"
	@rm -rf $(PROJECT_FILE)
	@rm -rf .build
	@echo "$(GREEN)✓ Full clean completed$(RESET)"

# Development Workflow
.PHONY: fresh
fresh: clean-all generate ## Clean everything and regenerate
	@echo "$(GREEN)✓ Fresh project generated$(RESET)"

.PHONY: run
run: generate ## Build and run on simulator
	@echo "$(BLUE)Building and running on simulator...$(RESET)"
	@xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" build
	@xcrun simctl boot $(SIMULATOR_NAME) 2>/dev/null || true
	@xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" test-without-building || xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" run-without-building

# Code Quality
.PHONY: format
format: ## Format Swift files (requires swiftformat)
	@echo "$(BLUE)Formatting Swift files...$(RESET)"
	@which swiftformat > /dev/null || (echo "$(RED)Error: swiftformat not installed. Install with 'brew install swiftformat'$(RESET)" && exit 1)
	@swiftformat .

.PHONY: lint
lint: ## Lint Swift files (requires swiftlint)
	@echo "$(BLUE)Linting Swift files...$(RESET)"
	@which swiftlint > /dev/null || (echo "$(RED)Error: swiftlint not installed. Install with 'brew install swiftlint'$(RESET)" && exit 1)
	@swiftlint

# Archive and Distribution
.PHONY: archive
archive: generate ## Archive the app
	@echo "$(BLUE)Archiving app...$(RESET)"
	@xcodebuild archive -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -configuration Release -archivePath ./build/$(PROJECT_NAME).xcarchive

.PHONY: export-archive
export-archive: archive ## Export archive to IPA
	@echo "$(BLUE)Exporting archive...$(RESET)"
	@xcodebuild -exportArchive -archivePath ./build/$(PROJECT_NAME).xcarchive -exportPath ./build -exportOptionsPlist exportOptions.plist

# Utilities
.PHONY: list-schemes
list-schemes: ## List all available schemes
	@echo "$(BLUE)Available schemes:$(RESET)"
	@xcodebuild -project $(PROJECT_FILE) -list

.PHONY: list-targets
list-targets: ## List all targets in the project
	@echo "$(BLUE)Project targets:$(RESET)"
	@xcodebuild -project $(PROJECT_FILE) -target

.PHONY: validate-project
validate-project: generate ## Validate generated project
	@echo "$(BLUE)Validating project...$(RESET)"
	@xcodebuild -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" dry-run

# Documentation
.PHONY: docs
docs: ## Generate documentation (requires jazzy)
	@echo "$(BLUE)Generating documentation...$(RESET)"
	@which jazzy > /dev/null || (echo "$(RED)Error: jazzy not installed. Install with 'gem install jazzy'$(RESET)" && exit 1)
	@jazzy --clean --author "Artful Archives Studio" --author_url https://artfularchives.studio --github_url https://github.com/artfularchives/observability-swift-client --module $(PROJECT_NAME) --source-directory Observability

# CI/CD Helpers
.PHONY: ci
ci: clean generate test ## CI pipeline (clean, generate, test)
	@echo "$(GREEN)✓ CI pipeline completed successfully$(RESET)"

.PHONY: ci-osx
ci-osx: clean generate ## CI pipeline for macOS (no simulator tests)
	@echo "$(BLUE)Running macOS CI pipeline...$(RESET)"
	@xcodebuild test -project $(PROJECT_FILE) -scheme $(SCHEME_NAME) -destination "platform=macOS"
	@echo "$(GREEN)✓ macOS CI pipeline completed successfully$(RESET)"