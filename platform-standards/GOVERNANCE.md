# Governance Model for Platform Modules

To implement the "you build it, you run it" principle, we will use a combination of `CODEOWNERS` and individual `OWNERS.yaml` files.

## 1. Global Governance (`.github/CODEOWNERS`)
This defines the default ownership for the entire repository to ensure all changes undergo mandatory peer review.

```text
# Default owner for the whole repo
*       @platform-team

# Specific team ownership for modules
/platform-modules/customer-ecs-runtime/   @platform-team @app-dev-leads
/platform-modules/jenkins-infrastructure/ @platform-team
```

## 2. Module Governance (`platform-modules/<module>/OWNERS.yaml`)
Each module will contain an `OWNERS.yaml` file to explicitly document who is responsible for the module's lifecycle, documentation, and support.

```yaml
# Example OWNER.yaml structure
owners:
  - name: Platform Team
    email: platform-team@example.com
    github_handle: "@platform-team"
    responsibility: "Core module maintenance and infrastructure stability"
  - name: App Dev Lead
    email: app-leads@example.com
    github_handle: "@app-dev-leads"
    responsibility: "Service integration and operational feedback"
```

## 3. Enforcement Strategy
- **PR Automation**: We can integrate a GitHub Action (e.g., `snyk/code-owners` or custom workflow) to automatically request reviews from the individuals listed in the relevant `OWNERS.yaml` whenever a file in that module is changed.
- **Backstage Integration**: The `catalog-info.yaml` will reference these files to keep the module metadata synchronized with the actual owners.
