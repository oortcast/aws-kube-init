#!/bin/bash
read -p "Please make sure aws-auth-cm.yaml: <ARN of instance role> is correct? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
echo ""
kubectl apply -f aws-auth-cm.yaml
kubectl apply -f storage-class.yaml
