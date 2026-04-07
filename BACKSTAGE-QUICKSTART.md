# Quick Start: Backstage Integration

Get started with Backstage for this platform in 5 minutes.

## What You'll Get

- Centralized catalog of all infrastructure
- Self-service templates for creating resources
- Unified documentation and runbooks
- Cost, compliance, and monitoring dashboards

## Installation Steps

### 1. Prerequisites

```bash
# Check if you have Node.js and npm
node --version  # Should be 14.x or higher
npm --version   # Should be 6.x or higher
```

### 2. Create Backstage App

```bash
# Create new Backstage instance (if you don't have one)
npx @backstage/create-app@latest

# Or use existing Backstage instance
cd my-backstage-instance
```

### 2.1 Run Dockerized Backstage (Repository Setup)

If you want a fast local runtime from this repository, use the prebuilt container setup:

```bash
cd backstage
cp .env.example .env
docker compose up -d
```

Open `http://localhost:3000` after containers become healthy.

### 3. Add GitHub Integration

In `app-config.yaml`:

```yaml
catalog:
  providers:
    github:
      providerId: production
      organization: 'tukue'
      token: ${GITHUB_TOKEN}

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

### 4. Register This Repository

Add to your Backstage catalog:

```yaml
# In Backstage catalog location
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: terraform-jenkins-aws
spec:
  targets:
    - https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/catalog-info.yaml
```

### 5. Install Required Plugins

```bash
# From your backstage directory
yarn add --cwd packages/app @backstage/plugin-catalog
yarn add --cwd packages/app @backstage/plugin-techdocs
yarn add --cwd packages/app @backstage/plugin-kubernetes
yarn add --cwd packages/app @spotify-backstage/backstage-plugin-scaffolder-backend-module-terraform
```

### 6. Add to Frontend (App)

In `packages/app/src/App.tsx`:

```typescript
import { TechDocsPage } from '@backstage/plugin-techdocs';
import { CatalogPage } from '@backstage/plugin-catalog';

// Add routes
<Route path="/catalog" element={<CatalogPage />} />
<Route path="/docs" element={<TechDocsPage />} />
```

### 7. Start Backstage

```bash
# Start the backend
yarn start-backend

# In another terminal, start the frontend
yarn start
```

### 8. Access Backstage

Open browser:
```
http://localhost:3000
```

## First Steps in Backstage

### 1. View Catalog
- Navigate to **Catalog** in the left sidebar
- Search for "terraform-jenkins-aws"
- Click to view component details

### 2. Explore Documentation
- Click on **Docs** tab
- View Getting Started, Architecture, and Runbooks
- Follow tutorials

### 3. Create Resources (Optional)
- Click **Create** button
- Select "Create Jenkins EC2 Instance" template
- Fill out the form
- Deployment happens automatically

## Customizations

### Add Custom Logo
In `app-config.yaml`:

```yaml
app:
  title: Jenkins Platform
  logo:
    url: 'https://your-organization.com/logo.png'
```

### Customize Homepage
Edit `packages/app/src/components/home/HomePage.tsx`

### Add Team Information
Update `catalog-info.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: platform-team
spec:
  type: team
  parent: organization
  profile:
    displayName: Platform Engineering
    email: platform@organization.com
```

## Connecting to AWS

### Install AWS Plugin

```bash
yarn add --cwd packages/app @aws-backstage/plugin-aws
```

### Configure AWS Access

In `app-config.yaml`:

```yaml
aws:
  s3:
    bucket: my-bucket
  ec2:
    region: us-east-1
    credentials:
      roleArn: arn:aws:iam::ACCOUNT:role/backstage-role
```

## Enabling TechDocs

TechDocs provides documentation directly in Backstage.

### 1. Install Backend Plugin

```bash
yarn add --cwd packages/backend @backstage/plugin-techdocs-backend
```

### 2. Configure Docs Builder

In `app-config.yaml`:

```yaml
techdocs:
  builder: 'local'
  generators:
    techdocs: 'docker'
  publisher:
    type: 'local'
```

### 3. Access Docs

- In Backstage, click on any component
- Click **DOCS** tab
- View auto-generated documentation from `docs/` folder

## Troubleshooting

### Catalog items not showing
- Verify GitHub token is valid
- Check `catalog-info.yaml` URL is accessible
- Review Backstage backend logs

### TechDocs not rendering
- Ensure Docker is installed (for local builder)
- Check docs folder structure
- Verify mkdocs.yml is present

### Plugin errors
- Run `yarn install` to ensure all dependencies
- Clear cache: `rm -rf node_modules && yarn install`
- Check plugin compatibility with Backstage version

## Next Steps

1. **Explore**: Browse the catalog and documentation
2. **Customize**: Modify colors, branding, and layouts
3. **Integrate**: Connect to your CI/CD, monitoring, and cost systems
4. **Enable**: Turn on additional features as needed
5. **Train**: Share with your team

## Get Help

- 📖 [Backstage Documentation](https://backstage.io/docs)
- 💬 [Backstage Community](https://backstage.io/community)
- 🐛 [Report Issues](https://github.com/backstage/backstage/issues)
- 📧 Contact: platform-team@organization.com

## Related Documentation
- [Backstage Integration Guide](./Backstage-Platform-Integration.md)
- [Architecture Overview](./docs/architecture.md)
- [Getting Started](./docs/getting-started.md)
