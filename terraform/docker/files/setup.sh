#!/bin/bash
#
# Docker Setup Script
#

# Setup Script
echo "> This is the AWS Terraform Development Environment Setup."
echo "> Please enter your ..."

read -e -p "> Name     : " name
read -e -p "> Email    : " -i "@boehringer-ingelheim.com" email 
read -e -p "> BB Token : " token

# parse email
IFS="@"
set -- $email

# run git config
git config --global url."https://$1%40$2:$token@bitbucket.biscrum.com".insteadOf https://bitbucket.biscrum.com

git config --global user.email "$email"
git config --global user.name "$name"

#eof
