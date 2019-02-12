- [ ] Pre-requisities
    - [ ] Make sure datadog-api-key SSM key is set for the account
    - [ ] Make sure quayio-key-lendesk SSM key is set for the account
- [ ] Create vars file for env
- [ ] Launch just point-of-sale/rds/postgres/postgres stack (you need the hostname for /${ENV}/lendesk/core-api/DATABASE_URL)
    - [ ] This requires you to launch point-of-sale/sg/sg
- [ ] Update cloudformation with new environment variables for each environment (e.g. appsignal doesn't send session data in production)
- [ ] Setup tools/ssm-parameters-setup.env with correct values
    - [ ] Generate 64-length passwords (with digits but no special characters because of escaping issues) for:
        - [ ] /${ENV}/lendesk/core-api/CORE_API_ENCRYPTED_ATTRIBUTES_KEY (this one must 32-length)
        - [ ] /${ENV}/lendesk/core-api/HYPERWAVE_SECRET
        - [ ] /${ENV}/lendesk/core-api/HYPERWAVE_TOKEN
        - [ ] /${ENV}/lendesk/core-api/JWT_AUTH_SECRET
        - [ ] /${ENV}/lendesk/core-api/SECRET_TOKEN
        - [ ] /${ENV}/lendesk/file-delivery-api/JWT_AUTH_SECRET must be the same as /${ENV}/lendesk/core-api/JWT_AUTH_SECRET
        - [ ] /${ENV}/lendesk/file-delivery-api/SUPER_SECRET_API_KEYS should be an escaped JSON single key-value pair hash key the key set to /${ENV}/lendesk/core-api/HYPERWAVE_TOKEN and the value set to /${ENV}/lendesk/core-api/HYPERWAVE_SECRET
        - [ ] /${ENV}/lendesk/elixir-app-collection/EAP_WEBSOCKET_ENDPOINT_SECRET_KEY_BASE
        - [ ] /${ENV}/lendesk/nylas-integration-service/CLIENT_ID
        - [ ] /${ENV}/lendesk/nylas-integration-service/CLIENT_SECRET
        - [ ] /${ENV}/lendesk/nylas-integration-service/HYPERWAVE_SECRET (same as the one in core-api)
        - [ ] /${ENV}/lendesk/nylas-integration-service/HYPERWAVE_TOKEN (same as the one in core-api)
    - [ ] Update DATABASE_URL:
        - [ ] You need to know the DB name, the username that will access it along with the password, and the host.
        - [ ] You can get the host (after launching it above) with: aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier==`pos-${ENV}-master`].Endpoint.Address' --output text
        - [ ] Format is: postgres://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}
    - [ ] Run tools/ssm-parameters-setup.env.
    - [ ] Remember to upload this to 1Password and add a label of "env: ${ENV}" so others can easily make changes or rebuild the env.
- [ ] Make sure you have API key in ~/.aws/credentials under appropriately named profile
- [ ] Run sceptre for env with profile above
- [ ] Create/configure IAM keys for codeship deploy
- [ ] Update core-client-app with new environment under config/environment
    - [ ] Reset codeship cache if using volumes
- [ ] Deploy apps
    - [ ] Deploy core-client-app
    - [ ] Deploy elixir-app-collection
- [ ] Update codeship files for all services (maybe)
- [ ] Add config for core-api (if not staging, qa, uat, or prd)
- [ ] Setup DNS entries
    - [ ] Set all of these in CloudFlare and don't send traffic through CloudFlare (the orange cloud icon with an arrow through it should be grey)
        - [ ] ${ENV}-api & $ENV-file point to ECS public ALB
        - [ ] ${ENV}-websockets points to Elixir public ALB
        - [ ] ${ENV}-app points to CloudFront distribution
        - [ ] Send DNS CNAMEs to (FTL product manager)
        - [ ] Mandrill
            - [ ] 2 Mandrill MX records
            - [ ] 2 TZT files: one DKIM and one SPF
- [ ] DB updates (if using old snapshot)
    - [ ] Run the following in the rails console:
        - [ ] Update team's inbound_domain to numbered environment. Team.update_all(inbound_domain: "#{ENV['ENVIRONMENT']}.lendesk.com")
        - [ ] Update team's storage_region to ca-central-1. Team.update_all(storage_region: 'ca-central-1')
        - [ ] Update e-sign key for all teams (silanis_key)
        - [ ] To make testing easier (only run if copying from an existing database, like from VMFarms):
            - [ ] Run user create script (for QA envs or when testing the env). This makes it easier for anyone to test.
            - [ ] Update all user's passwords to same. User.update_all(encrypted_password: BCrypt::Password.create!('Lendesk!!')). This makes it easier for testing.
        - [ ] Truncate/clear documents, signature_requests, and any other related table (e.g. Model.delete_all). Since we don't copy s3 buckets anyways, no point in keeping them around
- [ ] 3rd-party-services
    - [ ] Give NGW IPs (for each AZ) to…
        - [ ] Equifax (Rafe)
        - [ ] Paradigm Quest/lenders (FTL product manager)
    - [ ] Setup Mandril DNS (needs core-api to be running for it to work)
    - [ ] Make sure team's inbound_domain is updated
    - [ ] Create e-sign live account
        - [ ] Make sure team's e-sign key is updated
        - [ ] Add to Okta
- [ ] Call curl -XGET https://${ENV}-api.lendesk.com/devsettings/login to cache active admin (first time will always time out)
- [ ] Run data indexing service
    - [ ] Restart data indexing service (unless it's fixed)
- [ ] Run migrations for elixir-app-collection
    - [ ] Follow https://gist.github.com/pmarreck/a627387dbef93df40ed80856b75aa27a
        - [ ] Activity-history
            - [ ] EventHorizon.Repo
            - [ ] App name: :event_horizon
        - [ ] Stats
            - [ ] Stats.repo
            - [ ] App name: :holo_net
            - [ ] Change "priv/repo/migrations" to "priv/stats/repo/migrations"
Newrelic config — https://docs.newrelic.com/docs/agents/ruby-agent/configuration/ruby-agent-configuration
Appsignal config — https://docs.appsignal.com/ruby/configuration/options.html
Esign:
Setting up a new OneSpan Sign Account for a new Environment
* Go here and fill out the form - https://www.esignlive.com/partners-and-apps/sandbox-account-creation; use the email address devops+ENV-NAME@lendesk.com (e.g. devops+qa1@lendesk.com); this is a group email that currently goes to Geoff, Chris and Rafe.
* Log into the account here: https://sandbox.esignlive.com/login
* Go into "Admin" (via menu under user icon in top right)
* Click Integration, and get the API Key - you need to click the 'eye' icon on the right hand side of the page.
* Update the Callback URL - e.g. https://qa1-api.lendesk.com/api/signature_request_events and ensure that all events are activated (toggled on)
* Save the new API key in 1Password in the Vault "Admin - Staging", add it to the file "Esignlive / Onespan / Vasco API Keys"
* Ensure the login details for the new account gets into Okta. Currently Chris, Geoff and Rafe are the users with permission to do this. This new application in Okta should have the Ops group added to it.
IAM Keys (codeship)
- core-api
- core-client-app
- data-indexing-service
- elixir-app-collection
- file-delivery-api
- text-extractor-service
- text-to-payload-service
- nylas-integration-service