# Meridian Health Analytics — PHI storage bucket (hypothetical, portfolio purposes)
# FIXED version — addresses the encryption, public-access, versioning, and
# logging gaps flagged by Checkov (tied to risk register R-08 and R-06).

resource "aws_s3_bucket" "phi_storage" {
  bucket = "meridian-phi-storage"
}

# Fix 1: block all public access — closes the exposure path entirely
resource "aws_s3_bucket_public_access_block" "phi_storage" {
  bucket                  = aws_s3_bucket.phi_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Fix 2: encrypt everything at rest using a managed KMS key (addresses R-08)
resource "aws_s3_bucket_server_side_encryption_configuration" "phi_storage" {
  bucket = aws_s3_bucket.phi_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Fix 3: enable versioning so accidental deletion/overwrite of PHI is recoverable
resource "aws_s3_bucket_versioning" "phi_storage" {
  bucket = aws_s3_bucket.phi_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Fix 4: enable access logging (addresses R-06 — logs exist but weren't complete)
resource "aws_s3_bucket" "access_logs" {
  bucket = "meridian-access-logs"
}

resource "aws_s3_bucket_logging" "phi_storage" {
  bucket        = aws_s3_bucket.phi_storage.id
  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "phi-storage-logs/"
}
