---
- hosts: ${application_snake}
  become: true
  vars_files:
    - ansible-vars-rds.yml
  vars:
    ansible_ssh_private_key_file: "{{ keypair_path }}"
    ansible_user: admin
    ansible_ssh_common_args: >-
     '-o StrictHostKeyChecking=accept-new' 
     '-o ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters \"portNumber=%p\""'
    rds: "{{ lookup('community.sops.sops', sops_rds_secrets_path) | from_yaml }}"
    synapse_database_password: "{{ rds.synapse_database_password }}"
    sygnal_database_password:  "{{ rds.sygnal_database_password }}"
    rds_host: "${rds_host}"
    rds_port: "${rds_port}"
    rds_admin_user: "${rds_admin_user}"
    rds_admin_password: "{{ rds.admin_password }}"
    rds_databases: "{{ rds.databases }}"
    rds_users: "{{ rds.database_users }}"
  tasks:
    - name: Install deps
      apt:
        name:
          - postgresql-client
          - python3-psycopg2
        update_cache: yes
        state: present

    - name: Create dbs
      postgresql_db:
        name: "{{ item.name }}"
        encoding: "{{ item.encoding | default('UTF-8') }}"
        lc_collate: "{{ item.lc_collate | default('C') }}"
        lc_ctype: "{{ item.lc_ctype | default('C') }}"
        template: template0
        state: present
        login_host: "{{ rds_host }}"
        login_user: "{{ rds_admin_user}}"
        login_password: "{{ rds_admin_password }}"
      no_log: true
      with_items: "{{ rds_databases }}"

    - name: Create db users
      postgresql_user:
        db: "{{ item.db }}"
        name: "{{ item.username }}"
        password: "{{ item.password }}"
        priv: "{{ item.priv | default("") }}"
        role_attr_flags: "{{ item.role_attr_flags | default("") }}"
        login_host: "{{ rds_host }}"
        login_user: "{{ rds_admin_user}}"
        login_password: "{{ rds_admin_password }}"
      no_log: true
      with_items: "{{ rds_users }}"

    - name: shutdown instance
      command: /usr/sbin/shutdown -h +1
