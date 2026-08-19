package terraform.s3

import input as tfplan

# Extract the resource key (everything after the first dot in the address)
resource_key(address) := key if {
    parts := split(address, ".")
    key := concat(".", array.slice(parts, 1, count(parts)))
}

# Collect all S3 bucket keys
bucket_keys contains key if {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket"
    key := resource_key(resource.address)
}

# Collect all encryption config keys
encryption_keys contains key if {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket_server_side_encryption_configuration"
    key := resource_key(resource.address)
}

# Collect all public access block keys
block_keys contains key if {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    key := resource_key(resource.address)
}

# Collect all versioning config keys
versioning_keys contains key if {
    resource := tfplan.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"
    key := resource_key(resource.address)
}

# Deny S3 buckets without server-side encryption
deny contains msg if {
    key := bucket_keys[_]
    not encryption_keys[key]
    msg := sprintf("S3 bucket '%s' must have server-side encryption enabled (aws_s3_bucket_server_side_encryption_configuration)", [key])
}

# Deny S3 buckets without public access block
deny contains msg if {
    key := bucket_keys[_]
    not block_keys[key]
    msg := sprintf("S3 bucket '%s' must block public access (aws_s3_bucket_public_access_block)", [key])
}

# Deny S3 buckets without versioning
deny contains msg if {
    key := bucket_keys[_]
    not versioning_keys[key]
    msg := sprintf("S3 bucket '%s' must have versioning enabled (aws_s3_bucket_versioning)", [key])
}
