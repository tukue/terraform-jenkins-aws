# Backstage Plugin Code Snippets

Use these snippets after running `install-plugins.sh` in your Backstage app.

## Frontend (`packages/app/src/App.tsx`)

```tsx
import { TerraformPage } from '@spotify/backstage-plugin-terraform';
import { GithubActionsPage } from '@backstage/plugin-github';
import { KubernetesPage } from '@backstage/plugin-kubernetes';
import { JenkinsPage } from '@backstage/plugin-jenkins';
```

```tsx
<Route path="/terraform" element={<TerraformPage />} />
<Route path="/github" element={<GithubActionsPage />} />
<Route path="/kubernetes" element={<KubernetesPage />} />
<Route path="/jenkins" element={<JenkinsPage />} />
```

## Backend (`packages/backend/src/index.ts`)

Backstage backend wiring differs by Backstage version and backend system.
Use the plugin package docs for your exact version, but ensure these backend packages are registered:

- `@backstage/plugin-terraform-backend`
- `@backstage/plugin-github-backend`
- `@backstage/plugin-kubernetes-backend`
- `@backstage/plugin-jenkins-backend`
- `@aws-backstage/plugin-aws-backend`
- `@backstage/plugin-scaffolder-backend-module-github`
- `@spotify/backstage-plugin-scaffolder-backend-module-terraform`

## Config

Merge [app-config-plugins.yaml](/c:/Users/tukue/terraform-jenkins-aws/backstage/app-config-plugins.yaml) into your app `app-config.yaml`, then provide values from [`.env.local.example`](/c:/Users/tukue/terraform-jenkins-aws/backstage/.env.local.example).
