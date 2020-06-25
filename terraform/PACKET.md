# Packet Public Cloud

1. Sign up for a Packet Public Cloud account at https://app.packet.net/signup

2. Follow the wizard **"Getting Started with Packet"** at https://app.packet.net/getting-started/overview that guides you through creating a project.

**IMPORTANT:**

Using the Packet Public Cloud [web portal](https://app.packet.net/), upload one or more SSH keys to either your *"Personal Settings"* (personal SSH keys) or the newly created projects' *"Project Settings"* (project-level SSH keys).

These keys will be automatically added (to `.ssh/authorized_keys`) on every server created by you on the Packet Public Cloud. These keys must be generated for every SSH client you will be using to access these servers.

See details at https://www.packet.com/developers/docs/servers/key-features/ssh-keys/

One of these SSH keys must be generated in the host system used for driving the deployment. Copy location and names of these SSH key files on that system, they will be used later as values for `ssh_private_key_path` and `ssh_public_key_path` variables in the Terraform configuration.

3. After the project has been created, navigate to its *"Project Settings"*, and at the *"General"* tab locate the project ID, copy it as is, it will be used later as a value for the `project_id` variable in the Terraform configuration.

```
Example of the project_id value: "e36a901f-d5e1-28e1-0f21-efb1c3676d89"
```

4. Create a single API key, either from either your *"Personal Settings"* or from your project *"Project Settings"*, give it a descriptive name and *"Read/Write"* permissions. Copy this key's token value as is, it will be used later as a value for the `auth_token` variable in the Terraform configuration.

```
Example of the auth_token value: "atBncno1a8ipxEYAKNTpuFp7CyyDDZVA"
```

Next, follow [this](CLOUDFLARE.md)

[Top](README.md)
