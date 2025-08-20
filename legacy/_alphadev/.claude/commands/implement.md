---
description: TDD-focused implementation with automated quality checks
argument-hint: feature-name | component-name | issue-number
model: claude-3-5-sonnet-20241022
---
Implement: $ARGUMENTS using Test-Driven Development

**TDD Workflow:**
1. **Red**: Write failing tests that define expected behavior
2. **Green**: Implement minimal code to make tests pass
3. **Refactor**: Clean up code while keeping tests green
4. **Hooks**: Let automated formatting, linting, and build verification run

**Quality Gates:**
- All tests must pass before completion
- Code coverage should increase (target 80%+)
- Linting and formatting applied automatically
- Build verification successful
- Security considerations addressed

**Documentation Updates:**
- Update relevant README sections
- Add JSDoc/docstrings for public APIs
- Include usage examples

Use @CLAUDE.md for coding standards and architectural patterns.
