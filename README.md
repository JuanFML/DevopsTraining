# TerraformVPC

Created an aws VPC with 2 public subnets and 2 private subnets
Use:

- terraform init
- terraform plan
- terrfaorm apply

Make sure you have you aws configuration correctly

# Install Ansible

First install virtual env:

```
pip3 install virtualenv
```

create a virtual env in the Ansible folder and activate it:

```
python3 -m virtualenv Ansible
source Ansible/bin/activate
```

Now install all the packages:

```
python3 -m pip install --upgrade pip
python3 -m pip install ansible
python3 -m pip install "ansible-lint[yamllint]"
```
