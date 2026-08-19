# Backstage Plugin Installation - WSL Guide

This guide focuses on Phase `2.2` plugin configuration for:
- Terraform
- GitHub
- Kubernetes
- Jenkins CI/CD
- AWS

## Prerequisites

- WSL 2
- Node.js and Yarn in WSL
- A Backstage app created with `@backstage/create-app`
- This repository cloned in WSL-accessible path

## 1. Create or Open Backstage App

```bash
# Example: create a Backstage app
npx @backstage/create-app@latest --path ~/backstage-app
cd ~/backstage-app
```

## 2. Run Plugin Installer from This Repository

```bash
# From your Backstage app root
bash /mnt/c/Users/tukue/terraform-jenkins-aws/backstage/install-plugins.sh --app-path "$(pwd)"
```

Useful flags:

```bash
# Preview only
bash /mnt/c/Users/tukue/terraform-jenkins-aws/backstage/install-plugins.sh --app-path "$(pwd)" --dry-run

# Skip final build
bash /mnt/c/Users/tukue/terraform-jenkins-aws/backstage/install-plugins.sh --app-path "$(pwd)" --skip-build
```

## 3. Merge Plugin Config

Copy relevant sections from:
- `/mnt/c/Users/tukue/terraform-jenkins-aws/backstage/app-config-plugins.yaml`

Into your Backstage app config, usually:
- `app-config.yaml`
- `app-config.local.yaml`

## 4. Configure Environment Variables

Use this template:
- `/mnt/c/Users/tukue/terraform-jenkins-aws/backstage/.env.local.example`

Create `.env.local` in your Backstage app and fill required secrets:
- `GITHUB_TOKEN`
- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`
- `JENKINS_*`
- `AWS_*`
- database values

## 5. Apply Code Snippets

Use:
- `/mnt/c/Users/tukue/terraform-jenkins-aws/backstage/plugin-code-snippets.md`

Update:
- `packages/app/src/App.tsx` for plugin routes
- `packages/backend/src/index.ts` for backend plugin wiring

## 6. Run and Verify

```bash
yarn start-backend
# new terminal
yarn start
```

Verify routes/pages:
- `/terraform`
- `/github`
- `/kubernetes`
- `/jenkins`

## Troubleshooting

### Dependency conflicts

```bash
rm -rf node_modules yarn.lock
yarn install
```

### Build fails after plugin install

- Check plugin version compatibility with your Backstage version
- Install incrementally by plugin group if needed

### WSL localhost access from Windows browser

```bash
hostname -I
```

Then open `http://<wsl-ip>:3000`.
