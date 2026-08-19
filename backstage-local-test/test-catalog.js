#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const repoRoot = path.join(__dirname, '..');
const errors = [];

const catalogFiles = [
  'catalog-info.yaml',
  '.backstage/system-and-components.yaml',
  '.backstage/platform-resources.yaml',
  '.backstage/groups-and-users.yaml',
  'platform-modules/customer-ecs-runtime/catalog-info.yaml',
  'platform-modules/jenkins-infrastructure/catalog-info.yaml',
  'platform-modules/service-tier-wrapper/catalog-info.yaml',
  'platform-modules/compute/catalog-info.yaml',
  'platform-modules/ec2-instance/catalog-info.yaml',
  'platform-modules/edge/catalog-info.yaml',
  'cicd/core/network/catalog-info.yaml',
  'platform-modules/network/catalog-info.yaml',
  'platform-modules/rds-database/catalog-info.yaml',
  'platform-modules/security/catalog-info.yaml',
  'platform-modules/security-group/catalog-info.yaml',
  'platform-modules/vpc/catalog-info.yaml',
];

const templateFiles = [
  'templates/create-jenkins-ec2-template.yaml',
  'templates/create-customer-ecs-runtime-template.yaml',
  'templates/create-standard-service-template.yaml',
  'templates/create-s3-bucket-template.yaml',
  'templates/create-vpc-template.yaml',
  'templates/create-rds-database-template.yaml',
  'templates/create-ec2-instance-template.yaml',
  'templates/create-security-group-template.yaml',
];

const generatedCatalogTemplates = [
  'templates/customer-ecs-runtime/catalog-info.yaml.njk',
  'templates/jenkins-ec2/catalog-info.yaml.njk',
  'templates/standard-service/catalog-info.yaml.njk',
  'templates/s3-bucket/catalog-info.yaml.njk',
  'templates/vpc-setup/catalog-info.yaml.njk',
  'templates/rds-database/catalog-info.yaml.njk',
  'templates/ec2-instance/main.tf.njk',
  'templates/security-group-setup/catalog-info.yaml.njk',
];

function read(file) {
  return fs.readFileSync(path.join(repoRoot, file), 'utf8');
}

function loadAll(file) {
  try {
    return yaml.loadAll(read(file)).filter(Boolean);
  } catch (error) {
    errors.push(`${file}: invalid YAML - ${error.message}`);
    return [];
  }
}

function hasPlaceholderUrl(value) {
  return typeof value === 'string' && (
    value.includes('your-backstage-instance') ||
    value.includes('localhost:7000')
  );
}

function walk(value, visitor) {
  visitor(value);
  if (Array.isArray(value)) {
    value.forEach(item => walk(item, visitor));
  } else if (value && typeof value === 'object') {
    Object.values(value).forEach(item => walk(item, visitor));
  }
}

function collectSystems(docs) {
  return new Set(
    docs
      .filter(doc => doc.kind === 'System')
      .map(doc => doc.metadata && doc.metadata.name)
      .filter(Boolean),
  );
}

function validateEntity(file, doc, systems) {
  if (!doc.apiVersion || !doc.kind || !doc.metadata || !doc.metadata.name) {
    errors.push(`${file}: entity must include apiVersion, kind, metadata.name`);
  }

  const system = doc.spec && doc.spec.system;
  if (system && !systems.has(system)) {
    errors.push(`${file}: references unknown system "${system}"`);
  }

  walk(doc, value => {
    if (hasPlaceholderUrl(value)) {
      errors.push(`${file}: contains placeholder Backstage URL "${value}"`);
    }
  });
}

function validateTemplate(file, doc) {
  if (doc.kind !== 'Template') {
    errors.push(`${file}: expected kind Template`);
  }

  const serialized = JSON.stringify(doc);
  const usesUserToken = serialized.includes('secrets.USER_OAUTH_TOKEN');
  const requestsUserToken = serialized.includes('requestUserCredentials') &&
    serialized.includes('USER_OAUTH_TOKEN');

  if (usesUserToken && !requestsUserToken) {
    errors.push(`${file}: uses secrets.USER_OAUTH_TOKEN but does not request user credentials`);
  }

  walk(doc, value => {
    if (hasPlaceholderUrl(value)) {
      errors.push(`${file}: contains placeholder Backstage URL "${value}"`);
    }
  });

  const templateDir = path.dirname(path.join(repoRoot, file));
  const steps = (doc.spec && doc.spec.steps) || [];
  steps
    .filter(step => step.action === 'fetch:template')
    .forEach(step => {
      const url = step.input && step.input.url;
      if (typeof url === 'string' && url.startsWith('./')) {
        const resolved = path.resolve(templateDir, url);
        if (!fs.existsSync(resolved)) {
          errors.push(`${file}: fetch:template url does not exist: ${url}`);
        }
      }
    });
}

function validateGeneratedCatalogTemplate(file, systems) {
  if (!fs.existsSync(path.join(repoRoot, file))) {
    return;
  }

  const content = read(file);
  const match = content.match(/^\s*system:\s*([A-Za-z0-9_.-]+)\s*$/m);
  if (match && !systems.has(match[1])) {
    errors.push(`${file}: generated catalog references unknown system "${match[1]}"`);
  }

  if (hasPlaceholderUrl(content)) {
    errors.push(`${file}: contains placeholder Backstage URL`);
  }
}

console.log('Backstage catalog validation');
console.log('============================');

const catalogDocs = catalogFiles.flatMap(loadAll);
const systems = collectSystems(catalogDocs);

catalogFiles.forEach(file => {
  loadAll(file).forEach(doc => validateEntity(file, doc, systems));
  console.log(`OK catalog: ${file}`);
});

templateFiles.forEach(file => {
  const docs = loadAll(file);
  docs.forEach(validateTemplate.bind(null, file));
  console.log(`OK template: ${file}`);
});

generatedCatalogTemplates.forEach(file => {
  validateGeneratedCatalogTemplate(file, systems);
});

if (errors.length > 0) {
  console.error('\nValidation failed:');
  errors.forEach(error => console.error(`- ${error}`));
  process.exit(1);
}

console.log('\nValidation passed.');
console.log(`Systems: ${systems.size}`);
console.log(`Catalog files: ${catalogFiles.length}`);
console.log(`Templates: ${templateFiles.length}`);
