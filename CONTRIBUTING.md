# Contributing Guidelines

## Welcome to the terraform-jenkins-aws Platform

Thank you for contributing to our platform! This document provides guidelines for contributing to the project.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## How to Contribute

### 1. Fork and Clone
```bash
git clone https://github.com/yourusername/terraform-jenkins-aws.git
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

### 4. Create a Pull Request

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
