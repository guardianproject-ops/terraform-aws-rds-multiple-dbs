ROLES_DIR ?= roles
COLLECTIONS_DIR ?= collections
GALAXY_ARGS ?=

provision: deps create-instance db destroy-instance

.PHONY: create-instance
create-instance:
	ansible-playbook instance.yml --tags create

.PHONY: destroy-instance
destroy-instance:
	ansible-playbook instance.yml --tags destroy

.PHONY: db
db:
	ansible-playbook -i aws_ec2.yml create-db.yml

.PHONY: $(ROLES_DIR)
$(ROLES_DIR):
	ansible-galaxy role install -r requirements.yml -p $(ROLES_DIR) $(GALAXY_ARGS)

.PHONY: $(COLLECTIONS_DIR)
$(COLLECTIONS_DIR):
	ansible-galaxy collection install -r requirements.yml -p $(COLLECTIONS_DIR) $(GALAXY_ARGS)

deps: $(ROLES_DIR) $(COLLECTIONS_DIR)
