#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

console.log('🚀 Backstage Local Catalog Test');
console.log('================================\n');

// Test catalog-info.yaml
try {
  const catalogPath = path.join(__dirname, '..', 'catalog-info.yaml');
  const catalogContent = fs.readFileSync(catalogPath, 'utf8');
  const catalog = yaml.load(catalogContent);

  console.log('✅ catalog-info.yaml loaded successfully');
  console.log(`   Type: ${catalog.kind}`);
  console.log(`   Name: ${catalog.metadata.name}`);
  console.log(`   System: ${catalog.spec.system}`);
  console.log('');
} catch (error) {
  console.log('❌ Error loading catalog-info.yaml:', error.message);
  console.log('');
}

// Test system-and-components.yaml
try {
  const systemPath = path.join(__dirname, '..', '.backstage', 'system-and-components.yaml');
  const systemContent = fs.readFileSync(systemPath, 'utf8');
  const docs = yaml.loadAll(systemContent);

  console.log('✅ system-and-components.yaml loaded successfully');
  let componentCount = 0;
  let apiCount = 0;

  docs.forEach(doc => {
    if (doc.kind === 'System') {
      console.log(`   System: ${doc.metadata.name} - ${doc.metadata.title}`);
    } else if (doc.kind === 'Component') {
      componentCount++;
    } else if (doc.kind === 'API') {
      apiCount++;
    }
  });

  console.log(`   Components: ${componentCount}`);
  console.log(`   APIs: ${apiCount}`);
  console.log('');
} catch (error) {
  console.log('❌ Error loading system-and-components.yaml:', error.message);
  console.log('');
}

// Test groups-and-users.yaml
try {
  const groupsPath = path.join(__dirname, '..', '.backstage', 'groups-and-users.yaml');
  const groupsContent = fs.readFileSync(groupsPath, 'utf8');
  const docs = yaml.loadAll(groupsContent);

  console.log('✅ groups-and-users.yaml loaded successfully');
  let groupCount = 0;
  let userCount = 0;

  docs.forEach(doc => {
    if (doc.kind === 'Group') {
      groupCount++;
    } else if (doc.kind === 'User') {
      userCount++;
    }
  });

  console.log(`   Groups: ${groupCount}`);
  console.log(`   Users: ${userCount}`);
  console.log('');
} catch (error) {
  console.log('❌ Error loading groups-and-users.yaml:', error.message);
  console.log('');
}

// Test platform-resources.yaml
try {
  const resourcesPath = path.join(__dirname, '..', '.backstage', 'platform-resources.yaml');
  const resourcesContent = fs.readFileSync(resourcesPath, 'utf8');
  const docs = yaml.loadAll(resourcesContent);

  console.log('✅ platform-resources.yaml loaded successfully');
  console.log(`   Resources: ${docs.filter(doc => doc.kind === 'Resource').length}`);
  console.log('');
} catch (error) {
  console.log('❌ Error loading platform-resources.yaml:', error.message);
  console.log('');
}

// Test Templates
const templates = [
  'templates/create-jenkins-ec2-template.yaml',
  'templates/create-customer-ecs-runtime-template.yaml',
  'templates/create-standard-service-template.yaml',
  'templates/create-s3-bucket-template.yaml',
  'templates/create-vpc-template.yaml',
  'templates/create-rds-database-template.yaml',
  'templates/create-ec2-instance-template.yaml',
  'templates/create-security-group-template.yaml',
];

templates.forEach(templatePath => {
  try {
    const fullPath = path.join(__dirname, '..', templatePath);
    const content = fs.readFileSync(fullPath, 'utf8');
    const doc = yaml.load(content);

    console.log(`✅ ${templatePath} loaded successfully`);
    console.log(`   Kind: ${doc.kind}`);
    console.log(`   Name: ${doc.metadata.name}`);
    console.log(`   Title: ${doc.metadata.title}`);
    console.log('');
  } catch (error) {
    console.log(`❌ Error loading ${templatePath}:`, error.message);
    console.log('');
  }
});

console.log('🎯 Catalog Summary:');
console.log('- Internal developer platform system with infrastructure components');
console.log('- AWS platform resources and reusable Terraform modules');
console.log('- Platform Engineering teams and users');
console.log('- Jenkins, ECS runtime, standard service, S3 bucket, and security group templates');
console.log('- Ready for local Backstage loading');
console.log('');
console.log('📋 Next Steps:');
console.log('1. Start locally: make local-up');
console.log('2. Or run on host: make backstage-start');
console.log('3. Access at: http://localhost:7000');
