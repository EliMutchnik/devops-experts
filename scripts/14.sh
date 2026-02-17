# Setup Ansible lab
git clone https://github.com/avielb/ansible-demo
cd ansible-demo
docker compose up -d

# Setup master and nodes
docker exec -it ansible-demo-ansible-1 bash
git clone https://github.com/avielb/ansible-demo
cd ansible-demo
ssh-keygen
ssh-copy-id node1
ssh-copy-id node2
# p@ssw0rd is "screencast"

mkdir /etc/ansible
cp hosts /etc/ansible/hosts

#############
# Ad-Hoc Commands
ansible servers -m ping
ansible servers -a "echo Hello World!"
ansible servers -m apt -a "name=nginx state=present"

# Hosts Inventory
cat /etc/ansible/hosts

# Variables, Tags
ansible-playbook vars.yml --tags=tag1
ansible-playbook vars.yml --tags=tag2

# Handlers, Variable register, If statement, Module, Tasks
ansible-playbook demo.yml

ssh node1
userdel avielb

# Roles and Tasks
ansible-playbook common.yml

# Templates
ansible-playbook template.yml

ssh node1 cat /root/hostname.conf
ssh node2 cat /root/hostname.conf

# Ansible Galaxy
https://galaxy.ansible.com/ui/
ansible-galaxy install geerlingguy.java
ansible-playbook -i hosts -u root galaxy-role.yml

# Secrets
ansible-vault create secrets.yml

db_password: SecretPass123

ansible-vault decrypt secrets.yml

# secret-play.yml
---
- name: Use encrypted secrets
  hosts: localhost
  vars_files:
    - secrets.yml

  tasks:
    - name: Print a message with a secret
      debug:
        msg: "The database password is {{ db_password }}"

ansible-playbook secret-play.yml --ask-vault-pass

###########

# group_vars/servers.yml
---
app_path: "/var/www/html"

# playbooks/site.yml

- name: Configure webservers
  hosts: servers
  tasks:
    - name: Ensure the application path exists
      file:
        path: "{{ app_path }}"
        state: directory
        mode: '0755'

###########

# Usefull Ansible modules
https://docs.ansible.com/projects/ansible/latest/collections/index_module.html#ansible-builtin

echo "MY_ENV_VAR=foo" > /tmp/envs1

- name: Set MY_ENV_VAR
  lineinfile:
    path: /tmp/envs1
    regexp: '^MY_ENV_VAR='
    line: MY_ENV_VAR=eli123

- name: Create envs2
  lineinfile:
    path: /tmp/envs2
    line: PING=pong
    create: yes
