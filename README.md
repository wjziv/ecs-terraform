# ECS Application With Terraform Example

For the software development team who would like to check all environment variables, regardless of secrecy, through encryption where necessary.

Usecase Requirements:
1. My developers would like to check encrypted secrets into source.
2. My developers would like to encrypt secrets on their local machines via CLI.
3. My developers only have access to their own accounts through their development machines.
4. My developers should be able to assume the role of a "secrets-handler" when authenticated as themselves.
5. My application is deployed through a continuous pipeline, capable of leveraging a service account permissioned to assume a secrets-decryption role.


Goals:

- enable the developer to push encrypted secrets and envvars to source with the features which rely on them
- deploy a containerized application to ECS through Terraform
- run deploy pipelines through github actions
- separate product-engineering concerns from devops concerns


## Anticipated Flow

This demo is intended to stand as an example of a steady state application (an echo server) which is capable of running in three environments:
- locally, on a dev machine with non-essential secrets
- qa, in the cloud (AWS) with essential secrets
- production, in the cloud (AWS) with essential secrets

As if DevOps has already set up the Terraform files and product engineers are free to add environment variables and secrets as they must.

The only additional task required of product engineers in this project is in secret management: in order to add a new secret, they must:
1. authenticate to AWS through CLI
2. decrypt the existing secrets files
3. add their plain-text secrets to the files
4. re-encrypt the secrets files


## AWS IAM Configuration

This demo will end with the following IAM configuration:

- Roles
  - Secrets Handler
    - permissions:
      - kms:Encrypt
      - kms:ReEncrypt
      - kms:Decrypt
  - Secrets Decrypter
    - permissions:
      - kms:Decrypt
- User Groups
  - people
    - 
  - service-accounts
- Users
  - my-human-developer-1
    - user-groups:
      - people
  - my-deployment-bot
    - user-groups:
      - service-accounts


## Requirements

It is assumed the developer has access to AWS + Github accounts for this demo.

We will be using the following products on AWS:
- ECS
- KMS


## Developer Experience

The content of `./config/*.env` is an example of the final result.
You should delete these files and replace them with your own unencrypted files, while keys are yet to be provisioned.

After running the terraform script, there are a handful of adjustments to this repository to take place before the developer is ready to start acting:
1. Replace the role and key ARNs in `./config/.sops.yaml` for those which were created by the terraform run.

That's it.

Now the developer is ready to take over:

1. Authorize `awscli` on your own machine.
2. Decrypt a set of secrets for local development
   1. `sops -d config/dev.env > .env`
3. Develop!
   1. Start encrypting secrets in `./config/*.env`.
   2. Decrypt them when needed!
   3. The `docker-compose.yaml` depends on the `.env` made by the developer.


### Software

- [awscli](https://formulae.brew.sh/formula/awscli)
- [docker](https://formulae.brew.sh/formula/docker)
- [terraform](https://formulae.brew.sh/formula/terraform)
- [sops](https://formulae.brew.sh/formula/sops)
