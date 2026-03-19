# GitHub Integration Setup for Backstage

This guide explains how to set up GitHub integration with Backstage for catalog discovery and OAuth2 authentication.

## Prerequisites

- Backstage instance running
- GitHub account with organization admin access
- GitHub repository: terraform-jenkins-aws

## Step 1: Create GitHub OAuth2 Application

### In GitHub Organization Settings

1. Go to GitHub Organization → Settings → Developer settings → OAuth Apps (or Personal Settings for personal account)
   ```
   https://github.com/organizations/YOUR-ORG/settings/developers
   ```

2. Click **New OAuth App**

3. Fill in the form:
   - **Application name**: `Backstage Local` (for dev) or `Backstage Production` (for prod)
   - **Homepage URL**: `http://localhost:3000` (dev) or your Backstage URL
   - **Application description**: "Backstage platform portal for terraform-jenkins-aws"
   - **Authorization callback URL**: `http://localhost:3000/api/auth/github/handler/frame`

4. Click **Register application**

5. Copy the following for your `.env` file:
   - **Client ID** → `GITHUB_CLIENT_ID`
   - **Client Secret** → `GITHUB_CLIENT_SECRET` (click "Generate a new client secret")

## Step 2: Create GitHub Personal Access Token

### For Catalog Discovery

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   ```
   https://github.com/settings/tokens
   ```

2. Click **Generate new token (classic)**

3. Configure the token:
   - **Token name**: `backstage-catalog-discovery`
   - **Expiration**: 30 days (or your preference)
   - **Scopes**: Select these scopes:
     ```
     ✓ repo (Full control of private repositories)
     ✓ read:org (Read org and team membership)
     ✓ admin:repo_hook (Full control of repository hooks)
     ✓ user:email (Access user emails)
     ```

4. Click **Generate token**

5. Copy the token → `GITHUB_TOKEN` in your `.env` file

## Step 3: Configure Environment Variables

Create a `.env` file in your Backstage app directory:

```bash
# GitHub OAuth2
GITHUB_CLIENT_ID=your_client_id_here
GITHUB_CLIENT_SECRET=your_client_secret_here

# GitHub Token for catalog discovery
GITHUB_TOKEN=your_personal_access_token_here

# Database (PostgreSQL)
DB_HOST=localhost
DB_PORT=5432
DB_USER=backstage
DB_PASSWORD=your_secure_password_here
DB_NAME=backstage

# AWS Integration (optional)
AWS_REGION=us-east-1
AWS_EXTERNAL_ID=your_external_id_here

# Kubernetes Integration (optional)
K8S_URL=https://your-k8s-cluster:6443
K8S_TOKEN=your_service_account_token_here

# Google Analytics (optional)
GOOGLE_ANALYTICS_ID=GA_CODE_HERE
```

## Step 4: Enable Catalog Discovery

The Backstage instance will automatically discover catalog files from:

1. **This repository**: `catalog-info.yaml` at root
   ```
   https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/catalog-info.yaml
   ```

2. **System definitions**: `.backstage/system-and-components.yaml`
   ```
   https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/.backstage/system-and-components.yaml
   ```

3. **Groups/Users**: `.backstage/groups-and-users.yaml`
   ```
   https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/.backstage/groups-and-users.yaml
   ```

### Update GitHub Integration in app-config.yaml

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

catalog:
  providers:
    github:
      providerId: production
      organization: 'tukue'  # Your GitHub organization
      token: ${GITHUB_TOKEN}
      branch: 'main'
      catalogPath: '/catalog-info.yaml'
      schedule:
        initialDelay: { minutes: 1 }
        frequency: { minutes: 30 }

  locations:
    - type: url
      target: https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/catalog-info.yaml
    - type: url
      target: https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/.backstage/system-and-components.yaml
    - type: url
      target: https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/.backstage/groups-and-users.yaml
```

## Step 5: Test GitHub Integration

### 1. Verify OAuth2

```bash
# Start Backstage
yarn start

# Go to http://localhost:3000
# Click "Sign in" and select GitHub
# You should be able to authenticate
```

### 2. Verify Catalog Discovery

```bash
# In Backstage, go to Catalog
# You should see:
# - terraform-jenkins-aws Component
# - jenkins-platform System
# - All system components (terraform-*, ansible-jenkins-setup)
# - All groups and users
```

### 3. Monitor Catalog Sync

Check Backstage logs for catalog sync messages:

```bash
# Look for messages like:
[catalog] Refresh task completed
[catalog] Provider github:providerId=production
[catalog] Added 15 entities
```

## Step 6: Troubleshooting

### Catalog Not Syncing

**Problem**: "No entities found" in Backstage

**Solutions**:
1. Verify GITHUB_TOKEN is valid and has correct permissions:
   ```bash
   curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
   ```

2. Check Backstage logs for errors:
   ```bash
   yarn logs
   ```

3. Verify catalog files exist in repository:
   ```bash
   curl https://raw.githubusercontent.com/tukue/terraform-jenkins-aws/main/catalog-info.yaml
   ```

4. Ensure catalog chain references are correct:
   ```yaml
   owner: platform-team  # Must exist in groups-and-users.yaml
   system: jenkins-platform  # Must exist in system-and-components.yaml
   ```

### OAuth2 Not Working

**Problem**: "Invalid OAuth application" error

**Solutions**:
1. Verify Client ID and Secret are correct
2. Check Authorization callback URL matches in GitHub settings
3. Ensure GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET are set correctly

### Entities Not Appearing

**Problem**: Entities defined but not showing in Backstage

**Check**:
1. Entity kind is supported (Component, System, Group, User, API, Resource)
2. All references (owner, system, parent) exist in catalog
3. Entity namespace is correct (default namespace if not specified)
4. Run `yarn backstage-cli catalog validate` to check YAML syntax

## Advanced Configuration

### Set Up Automatic GitHub Sync

Update `app-config.yaml`:

```yaml
catalog:
  providers:
    github:
      organization: 'tukue'
      schedule:
        # Run every 30 minutes
        frequency: { minutes: 30 }
        # Start sync 1 minute after Backstage starts
        initialDelay: { minutes: 1 }
```

### Add GitHub Webhooks for Real-Time Updates

For production, set up webhooks to update Backstage immediately when catalog files change:

1. Go to GitHub repository → Settings → Webhooks → Add webhook

2. Configure:
   - **Payload URL**: `https://your-backstage-domain/api/webhooks/events`
   - **Content type**: `application/json`
   - **Events**: Send me everything
   - **Active**: Check ✓

### Multi-Organization Support

To catalog multiple organizations:

```yaml
catalog:
  providers:
    github:
      - organization: 'org1'
        schedule:
          frequency: { minutes: 30 }
      - organization: 'org2'
        schedule:
          frequency: { minutes: 30 }
```

## Security Best Practices

1. **Token Rotation**
   - Rotate personal access tokens every 90 days
   - Use GitHub Actions secrets for sensitive values

2. **Least Privilege**
   - Only grant necessary scopes to tokens
   - Use separate tokens for different purposes

3. **Secret Management**
   - Never commit `.env` files
   - Use environment variables or secret vaults in production
   - Mask tokens in logs

4. **HTTPS in Production**
   - Always use HTTPS URLs in production
   - Update Authorization callback URL for HTTPS
   - Use certificate management (ACM)

## Next Steps

1. Verify catalog entities appear in Backstage
2. Test OAuth2 authentication
3. Configure TechDocs for documentation
4. Set up Scaffolder templates
5. Add additional plugins (Kubernetes, Prometheus, etc.)

## Related Documentation

- [Backstage Quick Start](../BACKSTAGE-QUICKSTART.md)
- [Backstage Configuration](./config.md)
- [System and Components](./system-and-components.yaml)
- [Groups and Users](./groups-and-users.yaml)

## References

- [GitHub OAuth Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Backstage GitHub Integration](https://backstage.io/docs/integrations/github)
- [Backstage Catalog Format](https://backstage.io/docs/features/software-catalog/descriptor-format)
