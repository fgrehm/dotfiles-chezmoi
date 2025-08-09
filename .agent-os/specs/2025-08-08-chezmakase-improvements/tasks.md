# Spec Tasks

## Tasks

- [ ] 1. **Devcontainer Compatibility Audit**
  - [x] 1.1 Test current installation in devcontainer environment and document behavior
  - [x] 1.2 Identify components that fail in containers (confirmed: desktop apps, system configs
        properly skipped)
  - [x] 1.3 Verify template conditionals handle container detection properly (✅ working)
  - [x] 1.4 Create devcontainer configuration for development and testing
  - [x] 1.5 Verify core development tools work in devcontainer environment

- [ ] 2. **Optional Components Configuration System**
  - [ ] 2.1 Design configuration schema for major component categories
  - [ ] 2.2 Create `.chezmoi.toml.tmpl` with sensible defaults and user options
  - [ ] 2.3 Update installation scripts to check configuration before installing components
  - [ ] 2.4 Add configuration prompts to initial setup process
  - [ ] 2.5 Test opt-in/opt-out functionality for each major component category

- [ ] 3. **Existing TODO Resolution**
  - [ ] 3.1 Catalog all TODO items in codebase with priority assessment
  - [ ] 3.2 Implement Claude Code CLI installation script
  - [ ] 3.3 Add markdown linting (markdownlint-cli2) to development tools
  - [ ] 3.4 Configure shellcheck for bash script validation
  - [ ] 3.5 Implement Alacrity terminal setup and configuration
  - [ ] 3.6 Address remaining TODOs or move to issue tracker

- [ ] 4. **Testing and Validation**
  - [x] 4.1 Create Docker-based test framework for devcontainer validation
  - [x] 4.2 Implement container detection testing with real Docker environments
  - [ ] 4.3 Create test script for bare metal installation validation (VirtualBox-based)
  - [ ] 4.4 Set up CI/CD pipeline for automated testing (GitHub Actions)
  - [ ] 4.5 Test optional component configuration across different scenarios
  - [ ] 4.6 Verify all tests pass in both containerized and bare metal environments
  - [ ] 4.7 Add test coverage for installer script behavior in different environments
  - [ ] 4.8 Create performance benchmarks for installation time across environments

- [ ] 5. **Test Framework Infrastructure**
  - [x] 5.1 Create comprehensive Docker-based testing system (`test/simulate-devcontainer.sh`)
  - [x] 5.2 Implement automated container detection validation
  - [x] 5.3 Add test coverage for template execution in container environments
  - [ ] 5.4 Extend test framework to support bare metal simulation (VirtualBox)
  - [ ] 5.5 Add test reporting and metrics collection
  - [ ] 5.6 Create test matrix for different Ubuntu/Linux distro versions
  - [ ] 5.7 Implement regression testing for chezmoi template changes
  - [ ] 5.8 Add integration tests for full installation workflows

- [ ] 6. **Documentation and Polish**
  - [x] 6.1 Create devcontainer setup documentation and troubleshooting guide
  - [ ] 6.2 Update README with new optional components information
  - [ ] 6.3 Create troubleshooting guide for common installation issues
  - [ ] 6.4 Document test framework usage for contributors
  - [ ] 6.5 Update installation instructions with configuration options
  - [ ] 6.6 Validate all documentation is accurate and complete

## Radar

- What is the best framework for shell testing these days? Anything that helps interactions with docker / chezmakase?
- **User Customization Strategy**: How should users fork/customize chezmakase? Consider:
  - Template repository approach vs fork-and-customize
  - Namespace/branding (chezmakase framework vs user's dotfiles-chezmakase)
  - Configuration inheritance and overrides
  - Update mechanism when base framework evolves
