# Contribution and Usage Guidelines

## Project Positioning

This repository is a **Platform Engineering showcase project** used for learning, portfolio demonstration, and interview discussions.

It is **not managed as a public open-source project** with community roadmap governance.

## Contribution Model

External pull requests are not the primary workflow for this repository.

Preferred usage:
- Study architecture and implementation patterns
- Reuse ideas in your own platform projects
- Open issues for questions or feedback

Direct code contributions are limited to the project owner/maintainers unless specifically invited.

## When "Platform as a Product" Is Required

Platform as a product is needed when infrastructure work must scale across many teams, not just one project.

### Scenario 1: Many Teams Repeating the Same Setup
- Teams keep rebuilding similar Jenkins, networking, IAM, and deployment patterns.
- Delivery slows down because every team reinvents and debugs the same foundations.
- A platform product solves this with reusable modules, templates, and golden paths.

### Scenario 2: Developer Experience Becomes a Bottleneck
- Developers wait on ticket-based infrastructure requests.
- Platform engineers become a central queue and cannot scale support.
- A platform product enables self-service through Backstage catalog + templates + clear docs.

### Scenario 3: Inconsistent Security and Compliance
- Different teams apply different standards for IAM, networking, backups, and logging.
- Audit and risk posture become unpredictable.
- A platform product enforces secure defaults, policy checks, and shared governance patterns.

### Scenario 4: Too Many Production Incidents from Drift
- Environments diverge over time due to manual changes or copied Terraform.
- Recovery takes longer because no single standard exists.
- A platform product reduces drift with standardized modules, automated validation, and runbooks.

### Scenario 5: Leadership Needs Measurable Platform Value
- The organization wants faster onboarding, shorter lead time, lower incident rate, and lower cloud waste.
- Ad-hoc infra work cannot show clear product outcomes.
- A platform product defines users, SLAs, adoption metrics, and continuous improvement loops.

### How This Repository Fits
- This repo is the product surface for infrastructure consumers.
- Terraform modules are product capabilities.
- Backstage catalog, docs, and templates are the platform UX.
- CI/CD checks and policies are product quality controls.
- Runbooks are post-deployment support features.

## Why Jenkins on AWS Platform Product Is Needed

These are practical business scenarios where a Jenkins-on-AWS platform is valuable:

### Scenario A: Regulated Delivery with Traceability
- Industries like finance, healthcare, and telecom require auditable CI/CD trails.
- Jenkins pipelines plus AWS IAM, CloudWatch, and controlled Terraform modules provide repeatable and traceable releases.

### Scenario B: Multi-Team Standardization
- Different product teams need CI/CD, but inconsistent tooling creates security and reliability risks.
- A shared Jenkins platform in AWS enforces common build, deploy, and security patterns across teams.

### Scenario C: Hybrid and Legacy Integration
- Organizations often run mixed workloads (legacy VMs, modern containers, on-prem integrations).
- Jenkins remains strong for integrating heterogeneous toolchains while AWS provides scalable infrastructure.

### Scenario D: Cost and Capacity Control
- Self-managed CI/CD at team level can cause duplicated compute, idle capacity, and poor visibility.
- Centralized Jenkins on AWS enables right-sizing, scheduling, and cost governance with shared observability.

### Scenario E: Faster Onboarding and Time-to-Delivery
- New teams lose time setting up CI/CD basics repeatedly.
- A platform product approach offers golden paths (templates, runbooks, defaults) so teams can deliver faster with fewer operational mistakes.

### Business Outcomes to Highlight
- Reduced lead time for change
- Higher deployment frequency with fewer failed releases
- Lower operational overhead for platform support
- Improved security/compliance consistency
- Better cloud cost efficiency and visibility

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## How Maintainers Contribute

### 1. Clone and Branch
```bash
git clone https://github.com/tukue/terraform-jenkins-aws.git
cd terraform-jenkins-aws
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

Follow these guidelines:

#### Terraform Code
- Use consistent naming conventions
- Add comments for complex logic
- Follow the module structure
- Use variables for configuration
- Validate with `terraform validate`

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Lint with TFLint
tflint
```

#### Documentation
- Update relevant documentation
- Use Markdown formatting
- Include examples where helpful
- Add links to related docs

#### Testing
- Test in dev environment first
- Validate all variables work
- Test error conditions
- Document manual verification steps

### 3. Commit Guidelines

Write clear, concise commit messages:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Example**:
```
feat(jenkins): add docker support to jenkins module

This change adds Docker installation and configuration to the Jenkins
EC2 instance module, enabling containerized workloads.

Closes #123
```

### 4. Create a Pull Request (Maintainers / Invited Contributors)

- Provide a clear title and description
- Reference related issues with "Closes #123"
- Include testing done
- Request review from maintainers
- Address review feedback

### 5. PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Configuration change

## Testing Done
- How was this tested?
- What scenarios were verified?

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Terraform validated and formatted
- [ ] No breaking changes
- [ ] Tested in dev environment

## Related Issues
Closes #123
```

## Development Workflow

### Setting Up Development Environment

```bash
# Install dependencies
brew install terraform terraform-docs tflint checkov

# Validate setup
terraform version
tflint --version
checkov --version

# Create feature branch
git checkout -b feature/my-feature
```

### Testing Locally

```bash
# Navigate to module directory
cd jenkins/

# Initialize
terraform init

# Validate
terraform validate

# Format check
terraform fmt -check .

# Plan (don't apply!)
terraform plan -var-file="../dev.tfvars"

# Security scanning
checkov -d .

# Code analysis
tflint .
```

### Code Review Checklist

**As an Author**:
- [ ] Code is well-documented
- [ ] Tests pass locally
- [ ] No sensitive data exposed
- [ ] Follows naming conventions
- [ ] Backward compatible or migration plan provided

**As a Reviewer**:
- [ ] Code is readable and understandable
- [ ] Follows project conventions
- [ ] No security vulnerabilities
- [ ] Performance impact assessed
- [ ] Documentation is clear

## Quality Standards

### Code Quality
- Terraform code must pass `terraform validate`
- Must be formatted with `terraform fmt`
- TFLint checks must pass
- Checkov security scans must have no critical issues

### Test Coverage
- All modules must have example configurations
- Critical modules require test coverage
- Breaking changes require migration guide

### Documentation
- All modules must have README
- Complex logic requires inline comments
- Public variables need descriptions
- Outputs must be documented

## Common Workflows

### Adding a New Module

1. Create new directory under terraform root
2. Create `main.tf`, `variables.tf`, `outputs.tf`
3. Add module to README
4. Document with examples
5. Add to Backstage catalog
6. Create PR with module addition

### Updating Existing Module

1. Ensure backward compatibility
2. Update documentation
3. Test with existing configurations
4. Add migration notes if breaking
5. Create PR with change rationale

### Fixing a Bug

1. Create issue (if not exists)
2. Create feature branch `fix/bug-description`
3. Add test case that fails
4. Fix the bug
5. Verify test passes
6. Create PR referencing issue

## Merge Criteria

PRs must meet these criteria for merge:
- [ ] All checks pass (CI/CD)
- [ ] At least 2 approvals (for critical changes)
- [ ] Code review completed
- [ ] Documentation updated
- [ ] No breaking changes (unless major version bump)
- [ ] All conversations resolved

## Release Process

### Versioning
Uses semantic versioning: MAJOR.MINOR.PATCH

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Release Steps
1. Update CHANGELOG.md
2. Update version in module READMEs
3. Create release tag: `v1.2.3`
4. Create GitHub release with notes
5. Update documentation site

## Support & Questions

- 💬 **Slack**: #platform-engineering
- 📧 **Email**: platform-team@organization.com
- 📖 **Docs**: [Backstage Documentation](https://backstage.yourorganization.com)
- 🐛 **Issues**: [GitHub Issues](https://github.com/tukue/terraform-jenkins-aws/issues)

## Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Best Practices](https://docs.aws.amazon.com)
- [Our Architecture Guide](./docs/architecture.md)
- [Best Practices](./docs/best-practices.md)

Thank you for contributing!
