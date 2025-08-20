---
description: Security audit and vulnerability assessment
argument-hint: --scan | --audit | --compliance | --threats
model: claude-3-5-sonnet-20241022
---
Perform security analysis: $ARGUMENTS

**Security Assessment Framework:**

**1. Code Security Scan:**
- Identify injection vulnerabilities (SQL, XSS, CSRF)
- Review authentication and authorization logic
- Check for hardcoded secrets and credentials
- Analyze data validation and sanitization

**2. Dependency Security:**
- Audit npm/pip/gem dependencies for known vulnerabilities
- Check for outdated packages with security patches
- Review license compatibility and supply chain risks

**3. Architecture Security:**
- API security patterns and rate limiting
- Data encryption at rest and in transit
- Network security and access controls
- Container and infrastructure security

**4. Compliance Checks:**
- OWASP Top 10 compliance
- Industry-specific requirements (PCI, HIPAA, GDPR)
- Security best practices and standards

**5. Threat Modeling:**
- Identify attack vectors and threat actors
- Risk assessment and impact analysis
- Prioritized remediation roadmap

**Deliverables:**
- Security findings with severity ratings
- Remediation steps with code examples
- Compliance gap analysis
- Security improvement roadmap

Generate security report in .claude/reports/security-audit.md
"@;

    "workflow.md" = @"
---
description: Execute complete development workflow with sub-agents
argument-hint: --analyze | --plan | --develop | --qa | --deploy
model: claude-3-5-sonnet-20241022  
---
Execute professional development workflow: $ARGUMENTS

**Complete Workflow Stages:**

**1. Analysis Phase** (Architect + Security Specialist)
- Architecture assessment and system design review
- Security audit and vulnerability assessment  
- Technical debt analysis and optimization opportunities

**2. Planning Phase** (Architect)  
- Detailed technical specifications and ADRs
- Implementation roadmap with milestones
- Risk assessment and mitigation strategies

**3. Development Phase** (Multiple agents in parallel)
- Frontend implementation with UI/UX focus
- Backend development with TDD approach
- Database design and migration planning
- API development and integration

**4. Quality Assurance** (QA Engineer + Security Specialist)
- Comprehensive testing strategy execution  
- Security vulnerability scanning
- Performance benchmarking and optimization
- Code review and quality gates

**5. Deployment Preparation** (Architect)
- Infrastructure setup and configuration
- CI/CD pipeline configuration
- Monitoring and logging setup
- Rollback and disaster recovery planning

Each phase generates detailed reports saved to .claude/reports/
Use sub-agents for specialized tasks to maintain context efficiency.
