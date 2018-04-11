#!/bin/bash

echo "# Hello Accelo."
echo "# This script will create the stack, create a roster file for saltstack, then deploy the stack onto both nodes."
echo "# It will then provide you with a URL to connect to the web instance."
echo "# You can replace the key with yours below in the script."
echo "# Get a coffee. This will take a while. There is a lot to install."
echo "# Enjoy."
echo " - Alexander Nicholson."

# Create the stack.
aws cloudformation deploy --template-file cloudformation.template --stack-name accelo-prod --parameter-overrides KeyName=accelo-prod --capabilities CAPABILITY_NAMED_IAM
launch1=`aws ec2 describe-instances --query 'Reservations[0].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'Name|ec2' | sed -e "s/^Name//" | awk '{$1=$1};1' | grep -c app`
launch2=`aws ec2 describe-instances --query 'Reservations[1].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'Name|ec2' | sed -e "s/^Name//" | awk '{$1=$1};1' | grep -c web`
rds=`aws rds describe-db-instances --query "DBInstances[].Endpoint[].Address"`
# Create our roster.
touch roster-accelo.yaml
aws ec2 describe-instances --filters Name=tag:Name,Values=app --query 'Reservations[0].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'Name' | sed -e "s/^Name//" | awk '{$1=$1};1' >> roster-accelo.yaml
perl -pi -e 'chomp if eof' roster-accelo.yaml
printf : >> roster-accelo.yaml
echo >> roster-accelo.yaml
printf "    host: " >> roster-accelo.yaml
aws ec2 describe-instances --filters Name=tag:Name,Values=app --query 'Reservations[0].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'ec2' | sed -e "s/^Name//" | awk '{$1=$1};1' >> roster-accelo.yaml
echo "    user: ec2-user" >> roster-accelo.yaml
echo "    priv: accelo-prod.pem" >> roster-accelo.yaml
echo "    sudo: True" >> roster-accelo.yaml
aws ec2 describe-instances --filters Name=tag:Name,Values=web --query 'Reservations[1].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'Name' | sed -e "s/^Name//" | awk '{$1=$1};1' >> roster-accelo.yaml
perl -pi -e 'chomp if eof' roster-accelo.yaml
printf : >> roster-accelo.yaml
echo >> roster-accelo.yaml
printf "    host: " >> roster-accelo.yaml
aws ec2 describe-instances --filters Name=tag:Name,Values=web --query 'Reservations[1].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'ec2' | sed -e "s/^Name//" | awk '{$1=$1};1' >> roster-accelo.yaml
echo "    user: ec2-user" >> roster-accelo.yaml
echo "    priv: accelo-prod.pem" >> roster-accelo.yaml
echo "    sudo: True" >> roster-accelo.yaml

# Alter RDS connection host in app state.
sed -i -e 's/replaceme/'"$rds"'/g' states/app.sls

nginxrev="\"http:\/\/"
# Find the app instance and replace it in Nginx config.
nginxrev+=`aws ec2 describe-instances --filters Name=tag:Name,Values=app --query 'Reservations[0].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'ec2' | sed -e "s/^Name//" | awk '{$1=$1};1'`
nginxrev+="\""

# Alter reverse proxy connection host in web state.
sed -i -e 's/replaceme/'"$nginxrev"'/g' states/files/nginx.conf

# Create virtual environment so we can use saltstack without changing the client machine.
virtualenv venv
source venv/bin/activate
pip install --trusted-host pypi.python.org salt-ssh
echo "Initialising roster."
sudo salt-ssh -i '*' --raw 'sudo yum install -y python'
echo "Testing connectivity."
sudo salt-ssh -i '*' test.ping
echo "[+] Starting run for our web instance."
sudo salt-ssh -i 'web' state.apply web
echo "[+] Starting run for our app instance."
sudo salt-ssh -i 'app' state.apply app
echo "Saltstack completed."

# Completed.
echo You can access the stack web instance via the following link:
printf https://
aws ec2 describe-instances --filters Name=tag:Name,Values=web --query 'Reservations[1].Instances[*].[PublicDnsName,Tags[*]]' | grep -E 'ec2' | sed -e "s/^Name//" | awk '{$1=$1};1'
