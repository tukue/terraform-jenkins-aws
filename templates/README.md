# Platform Templates

This directory contains Backstage Scaffolder templates for self-service infrastructure provisioning.

## Available Templates

### 1. Create Jenkins EC2 Instance
**File**: `create-jenkins-ec2-template.yaml`

Create a new Jenkins EC2 instance with customizable options.

**What it does**:
- Provisions EC2 instance
- Configures security groups
- Sets up load balancer
- Configures SSL/TLS
- Enables monitoring

**Required inputs**:
- Instance name
- Environment (dev/qa/prod)
- Instance type
- Owner email

**Example usage**:
1. In Backstage, click **Create**
2. Select "Create Jenkins EC2 Instance"
3. Fill in the form
4. Review configuration
5. Click Deploy
6. Template creates PR, you review and merge

### 2. Create Customer ECS Runtime
**File**: `create-customer-ecs-runtime-template.yaml`

Provision a customer-specific ECS runtime for a microservice application.

**What it does**:
- Provisions an ECS cluster and service
- Creates an application load balancer
- Configures security groups and logs
- Optionally wires DNS and TLS

**Required inputs**:
- Customer name
- Environment (dev/qa/prod)
- AWS account ID
- AWS region
- Container image
- Owner email

The template form is the Backstage frontend for provisioning. The customer enters the AWS account and AWS region there, and the platform resolves the network defaults from the landing zone.

### 3. Create VPC (Coming Soon)
Create a new VPC with public/private subnets.

### 4. Create RDS Database (Coming Soon)
Provision a managed RDS database with backups and multi-AZ.

### 5. Create S3 Bucket (Coming Soon)
Create an S3 bucket with encryption and versioning.

## Template Structure

Each template follows this structure:

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  # Template information
  name: template-name
  title: Display Title
  description: What this template does
spec:
  # Input parameters
  parameters:
    - title: Step 1 Title
      required: [field1]
      properties:
        field1:
          type: string
          description: Field description
  
  # Execution steps
  steps:
    - id: step-id
      name: Step Name
      action: action-type
      input: {}
```

## Common Actions

### fetch:template
Fetch and template files from a location.

```yaml
- id: fetch
  name: Fetch template
  action: fetch:template
  input:
    url: https://github.com/org/repo/tree/main/templates/example
    targetPath: ./result
    values:
      name: ${{ parameters.name }}
```

### publish:github
Publish to GitHub repository.

```yaml
- id: publish
  name: Publish to GitHub
  action: publish:github
  input:
    allowedHosts: ['github.com']
    repoUrl: github.com/org/repo
    token: ${{ secrets.GITHUB_TOKEN }}
```

### catalog:register
Register component in Backstage catalog.

```yaml
- id: register
  name: Register
  action: catalog:register
  input:
    repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
    catalogInfoPath: '/catalog-info.yaml'
```

## Creating Custom Templates

### Step 1: Create Template File
```yaml
# templates/my-template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: my-template
  title: My Custom Template
  description: Description of what this creates
spec:
  owner: platform-team
  type: resource
  
  parameters:
    - title: Basic Information
      required: [name]
      properties:
        name:
          type: string
          title: Resource Name
          pattern: '^[a-z0-9-]+$'
  
  steps:
    - id: log
      name: Log output
      action: debug:log
      input:
        message: 'Creating ${{ parameters.name }}'
```

### Step 2: Register Template
Add to your Backstage `app-config.yaml`:

```yaml
catalog:
  locations:
    - type: url
      target: https://raw.githubusercontent.com/org/repo/main/templates/my-template.yaml
```

### Step 3: Test Template
1. Restart Backstage backend
2. Navigate to Create in Backstage
3. Your template should appear
4. Fill form and test execution

## Best Practices

### 1. Input Validation
Always validate user inputs:

```yaml
properties:
  name:
    type: string
    pattern: '^[a-z0-9-]{3,30}$'  # Validate format
    minLength: 3
    maxLength: 30
  
  port:
    type: number
    minimum: 1024
    maximum: 65535
```

### 2. Provide Defaults
Help users by providing sensible defaults:

```yaml
instance_type:
  type: string
  enum: [t3.micro, t3.small, t3.medium]
  default: t3.small
  description: Select instance size
```

### 3. Clear Descriptions
Write helpful, clear descriptions:

```yaml
properties:
  environment:
    type: string
    title: Deployment Target
    description: |
      Select the environment where this will be deployed:
      - dev: Development (manual cleanup)
      - prod: Production (24/7 monitoring)
```

### 4. Multi-Step Forms
Break complex templates into multiple steps:

```yaml
parameters:
  - title: Basic Configuration
    # ...
  - title: Advanced Options
    # ...
  - title: Review & Confirm
    # ...
```

### 5. Clear Output
Provide helpful output after execution:

```yaml
output:
  links:
    - title: Repository
      url: ${{ steps.publish.output.repoContentsUrl }}
    - title: Pull Request
      url: ${{ steps.publish.output.pullRequestUrl }}
  text:
    - title: Next Steps
      content: |
        Your resource is being created!
        1. Review the PR
        2. Merge when ready
        3. Monitor deployment
```

## Template Examples

### Example 1: Simple AWS Resource
Creates a simple AWS resource with minimal options.

### Example 2: Team Service
Creates a service with team ownership and documentation.

### Example 3: Microservice
Creates complete microservice with CI/CD, docs, and monitoring.

## Troubleshooting

### Template not appearing in Backstage
- Verify location URL is accessible
- Check YAML syntax is valid
- Restart Backstage backend

### Template execution fails
- Check all required fields are provided
- Verify GitHub token has permissions
- Check action input parameters

### Generated code issues
- Verify template variables are correct
- Check for typos in expressions
- Test template locally first

## Related Documentation
- [Scaffolder Documentation](https://backstage.io/docs/features/software-templates)
- [Template Syntax](https://backstage.io/docs/features/software-templates/writing-templates)
- [Built-in Actions](https://backstage.io/docs/features/software-templates/builtin-actions)
