#!/bin/bash

set -e

echo "🚀 Starting full deployment pipeline..."

#############################
# 1. TERRAFORM APPLY
#############################

echo "🧱 Step 1: Terraform provisioning..."

cd ../terraform
terraform init
terraform apply -auto-approve

#############################
# 2. GET VM IP
#############################

echo "📡 Step 2: Retrieving VM IP..."

VM_IP=$(terraform output -raw vm_ip)

echo "✅ VM IP detected: $VM_IP"

#############################
# 3. WAIT FOR PING
#############################

echo "⏳ Step 3: Waiting for VM to respond to ping..."

until ping -c1 $VM_IP &>/dev/null; do
  echo "Waiting for VM..."
  sleep 5
done

echo "✅ VM is reachable via ping"

#############################
# 4. WAIT FOR SSH
#############################

echo "🔐 Step 4: Waiting for SSH..."

until nc -z $VM_IP 22; do
  echo "Waiting for SSH..."
  sleep 5
done

echo "✅ SSH port is open"

#############################
# 5. SSH TEST
#############################

echo "🧪 Step 5: Testing SSH connection..."

ssh -o StrictHostKeyChecking=no debian@$VM_IP "echo SSH OK"

echo "✅ SSH connection successful"

#############################
# 6. RUN ANSIBLE
#############################

echo "⚙️ Step 6: Running Ansible..."

cd ../ansible

# inject IP dynamically into inventory
sed -i "s/ansible_host=.*/ansible_host=$VM_IP/" inventory/hosts.ini

ansible-playbook playbook.yml

#############################
# DONE
#############################

echo "🎉 Deployment complete!"
echo "🌍 VM ready at: http://$VM_IP"
