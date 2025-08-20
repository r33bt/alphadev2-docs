---
description: Spec-driven development planning with PRP framework
argument-hint: feature-title | epic-name | project-area
model: claude-3-5-sonnet-20241022
---
Create detailed implementation plan for: $ARGUMENTS

**PRP Framework (Plan-Review-Program):**

**PLAN Phase:**
1. **Requirements Analysis**: User stories, acceptance criteria, edge cases
2. **Technical Design**: Architecture decisions, data models, API contracts
3. **Task Breakdown**: Granular tasks with effort estimates and dependencies
4. **Risk Assessment**: Technical risks, blockers, mitigation strategies

**REVIEW Phase:**
5. **Design Review**: Architecture patterns, scalability considerations  
6. **Security Review**: Authentication, authorization, data protection
7. **Performance Review**: Expected load, optimization opportunities
8. **Test Strategy**: Unit, integration, e2e testing approach

**PROGRAM Phase:**
9. **Implementation Sprints**: Prioritized development phases
10. **Quality Gates**: Code review, testing, documentation checkpoints
11. **Deployment Plan**: Environment setup, rollout strategy, rollback plan
12. **Success Metrics**: KPIs, monitoring, performance benchmarks

Save plan to .claude/tasks/${feature-name}-plan.md
Reference @CLAUDE.md for project context and standards.
