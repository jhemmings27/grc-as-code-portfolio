"""
check_mfa_compliance.py

A tiny "compliance as code" check.
It reads Meridian's admin account list and fails (like a real CI pipeline
check would) if any admin account doesn't have MFA enabled.

This is a simplified version of exactly what tools like Checkov,
Cloud Custodian, or AWS Config Rules do at a much larger scale.
"""

import yaml  # a library that lets Python read YAML files

# Step 1: Load the account data from the YAML file
with open("accounts.yaml", "r") as f:
    data = yaml.safe_load(f)

accounts = data["accounts"]  # this is now a Python list of dictionaries

# Step 2: Check every account for MFA
violations = []  # empty list to collect any accounts that fail the check

for account in accounts:
    if not account["mfa_enabled"]:       # "not False" means "if MFA is NOT enabled"
        violations.append(account["name"])

# Step 3: Report the result — this is what a CI pipeline would read
# to decide whether to pass or block a deployment
print(f"Checked {len(accounts)} admin accounts.")
print(f"Found {len(violations)} MFA violation(s):")
for name in violations:
    print(f"  - {name}")

print()
if violations:
    print("COMPLIANCE CHECK: FAILED")
else:
    print("COMPLIANCE CHECK: PASSED")
