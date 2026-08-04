#######################################
########## Setup Ansible lab ##########
#######################################

cd ansible-demo/docker
docker compose up -d

# Setup master and nodes
docker exec -it docker-ansible-1 bash
ssh-keygen
ssh-copy-id node1
ssh-copy-id node2
# p@ssw0rd is "screencast"

git clone https://github.com/EliMutchnik/devops-experts.git
cd devops-experts/ansible-demo

mkdir -p /etc/ansible
cp config/hosts /etc/ansible/
cp config/ansible.cfg /etc/ansible/


######################################
########## Ansible commands ##########
######################################

# Hosts Inventory and config
cat /etc/ansible/hosts
cat /etc/ansible/ansible.cfg

# Ad-Hoc Commands
ansible servers -m setup
ansible servers -m ping

ansible servers -a "echo Hello World!"
ansible servers -a "uptime"
ansible servers -a "df -h"

ansible servers -m apt -a "name=nginx state=present"
# on both nodes: check if pkg installed
ansible servers -m service -a "name=nginx state=started enabled=yes use=service"
# on both nodes: "service nginx status"

# Get files
echo "I am node<N>" > /tmp/test.txt
ansible servers -m fetch -a "src=/tmp/test.txt dest=/tmp/files/ flat=no"

# Run first playbook
ansible-playbook playbook.yml
curl node1

# Variables, Tags
ansible-playbook vars.yml --tags=tag1
ansible-playbook vars.yml --tags=tag2

# Handlers, Variable register, If statement, Module, Tasks
ansible-playbook demo.yml
ssh node1
userdel elim
ansible-playbook demo.yml
# Show if statement in action

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
ansible-vault create secrets.yml # Setup your pass
# insert:
db_password: SecretPass123
ansible-vault decrypt secrets.yml
ansible-vault encrypt secrets.yml

# Create secret-playbook.yml:
---
- name: Use encrypted secrets
  hosts: localhost
  vars_files:
    - secrets.yml

  tasks:
    - name: Print a message with a secret
      debug:
        msg: "The database password is {{ db_password }}"

ansible-playbook secret-playbook.yml --ask-vault-pass

###########

# group_vars/servers.yml
---
app_path: "/tmp/bla"


# dir.yml
---
- name: Configure webservers
  hosts: servers
  tasks:
    - name: Ensure the application path exists
      file:
        path: "{{ app_path }}"
        state: directory
        mode: '0755'

ansible-playbook dir.yml
mv group_vars/servers.yml group_vars/servers1.yml
ansible-playbook dir.yml

###########

# Usefull Ansible modules
https://docs.ansible.com/projects/ansible/latest/collections/index_module.html#ansible-builtin

echo "MY_ENV_VAR=foo" > /tmp/envs1
---
- name: Configure webservers
  hosts: servers
  tasks:
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
