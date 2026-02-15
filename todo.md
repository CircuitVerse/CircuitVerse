# Kamal 2.0 Deployment — TODO Checklist (Minimal with Essential Hooks)


## Core Kamal Setup

- [ ] Create hooks directory — `.kamal/hooks/`

- [ ] Update Kamal deploy configuration — `config/deploy.yml`

- [ ] Create secrets template — `.kamal/secrets`

- [ ] Update Rails production configuration — `config/environments/production.rb`

- [ ] Create Kamal deployment documentation — `.kamal/kamal_deployment.md`

- [ ] Update Docker installation documentation — `installation_docs/docker.md`

## Essential Deployment Hooks for automation(Pre & Post only)

- [ ] Pre-deploy hook — `.kamal/hooks/pre-deploy.sample`

- [ ] Pre-app-boot hook — `.kamal/hooks/pre-app-boot.sample`

- [ ] Post-app-boot hook — `.kamal/hooks/post-app-boot.sample`

- [ ] Post-deploy hook — `.kamal/hooks/post-deploy.sample`

## Hook Permissions

- [ ] Make hooks executable — `.kamal/hooks/*.sample`
