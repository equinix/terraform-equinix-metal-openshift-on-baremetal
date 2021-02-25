# SSH Key Module for Equinix Metal

Given a name name and project_id, this module will:

* create an SSH key
* register that key with the Equinix Metal user account
* keep a copy of the private key in ~/.ssh (identified by name, with a random suffix)

By default, Equinix Metal devices are deployed with authorization for all SSH tokens associated with the user account and project responsible for the device.
