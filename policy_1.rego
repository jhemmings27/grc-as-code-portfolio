package meridian.mfa

import rego.v1

# This rule "deny" collects one message for every admin account
# that does NOT have MFA enabled.
#
# input.accounts[_]  -> loop through every account in the input data
#                       ("_" means "I don't need the index number")
# account.mfa_enabled == false  -> the condition that triggers a denial
# msg := ...  -> build the message that explains WHY it was denied

deny contains msg if {
	some account in input.accounts
	account.mfa_enabled == false
	msg := sprintf("MFA not enabled for account: %s", [account.name])
}
