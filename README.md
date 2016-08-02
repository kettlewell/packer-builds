# packer-builds
My Packer image templates and provisioners for creating .ova files and ami images.

# Example Usage:

## Validate the script
packer.io validate centos7.json

## Build All
packer.io build -force centos7.json

## Build Some Of Them
packer.io build -force -only=minimal,ansible centos7.json

## Build Minimal
packer.io build -force -only=minimal centos7.json

## Build Ansible Master
packer.io build -force -only=ansible centos7.json


## Upload to S3 and Create AWS AMI

packer.io build -force -only=minimal -var s3buket=my-bucket-name' -var awsregion=us-east-1' centos7.json
