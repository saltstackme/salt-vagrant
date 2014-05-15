# TEMPLATE for SANDBOX specific variables
#
# copy this file a folder above vagrant environment
# and fill out the values
#

# provider, virtualbox or rackspace
PROVIDER = "virtualbox"

# home folder for on host to copy 
# private and public keys to sandbox
HOME = "/home/myuser"

# username, also used to define sandbox environment
# if vagrant is going to be used to provision cloud servers
# USERNAME has to be unique under the same cloud account
# to prevent possible name collusions
PREFIX = ""

# username to use for commits
GITHUB_USERNAME = ""

# e-mail address to use for commits
GITHUB_EMAIL = ""

# sandbox instance name
INSTANCE_NAME = "master1"

