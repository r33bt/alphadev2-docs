---
description: Systematic debugging and issue resolution  
argument-hint: error-description | issue-number | bug-report
model: claude-3-5-sonnet-20241022
---
Debug and fix: $ARGUMENTS

**Systematic Debugging Process:**

**1. Issue Analysis:**
- Reproduce the problem consistently
- Gather error logs, stack traces, system state
- Identify symptoms vs. root causes

**2. Root Cause Investigation:**
- Use Five Whys methodology for complex issues  
- Check recent changes (git log, PRs)
- Review related code paths and dependencies

**3. Solution Design:**
- Propose multiple fix approaches with trade-offs
- Consider impact on existing functionality
- Plan for regression prevention

**4. Implementation & Validation:**
- Write tests that fail with current bug
- Implement minimal fix to make tests pass  
- Verify fix doesn't break other functionality
- Add regression tests for future prevention

**5. Documentation:**
- Document root cause and solution
- Update troubleshooting guides if applicable
- Consider architectural improvements to prevent similar issues

Use "think hard" for complex debugging scenarios.
Reference error logs with !cat log-file.txt for context.
