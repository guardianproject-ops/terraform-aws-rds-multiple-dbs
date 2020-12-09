---
- hosts: localhost
  become: false
  tags: [create]
  vars_files:
    - ansible-vars-rds.yml
  tasks:
    - name: Test for presence of local keypair
      stat:
        path: "{{ keypair_path }}"
      register: keypair_local

    - name: Delete remote keypair
      ec2_key:
        profile: "{{ aws_profile }}"
        name: "{{ keypair_name }}"
        state: absent
      when: not keypair_local.stat.exists

    - name: Create keypair
      ec2_key:
        profile: "{{ aws_profile }}"
        name: "{{ keypair_name }}"
      register: keypair

    - name: Persist the keypair
      copy:
        dest: "{{ keypair_path }}"
        content: "{{ keypair.key.private_key }}"
        mode: 0600
      when: keypair.changed

    - name: create provisioner instance
      ec2_instance:
        profile: "{{ aws_profile }}"
        region: "{{ region }}"
        key_name: "{{ keypair_name }}"
        state: running
        instance_type: t3.micro
        instance_initiated_shutdown_behavior: terminate
        instance_role: "{{ iam_instance_profile }}"
        image_id: "{{ image_id }}"
        name: "{{ instance_name }}"
        security_group: "{{ security_group }}"
        vpc_subnet_id: "{{ vpc_subnet_id }}"
        tags: "{{ tags }}"
        wait: true
        user_data: |
          #!/bin/bash
          shutdown -h +120

- hosts: localhost
  become: false
  tags: [destroy]
  vars_files:
    - ansible-vars-rds.yml
  tasks:
    - name: Test for presence of local keypair
      file:
        path: "{{ keypair_path }}"
        state: absent

    - name: Delete remote keypair
      ec2_key:
        profile: "{{ aws_profile }}"
        name: "{{ keypair_name }}"
        state: absent

    - name: Destroy provisioner instance
      ec2_instance:
        profile: "{{ aws_profile }}"
        state: absent
        name: "{{ instance_name }}"
        filters:
          "tag:Application": "{{ tags.Application }}"
        wait: true


