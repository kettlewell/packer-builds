#!/usr/bin/env bash

set -eu

build_timestamp="$(date +%s)"
centos_version='7.2.1511'
packer_opts=''
s3_bucket='kettlewell-images'
aws_only=0

function usage {
    cat <<EOF
Usage: ${0##*/} [-b s3_bucket] [-p packer_options] [-v centos_version] [-t timestamp ] [-u]

  -b bucket     The name of the S3 bucket. Default is hardcoded.
  -p options    Additional packer options. Ex: '--var foo=bar --var bar=foo'
  -v version    The version of CentOS to build. Default is ${centos_version}.
  -t timestamp  The timestamp to use if uploading to S3 (-u)
  -u            Upload to S3 (requires timestamp)

EOF
}

while getopts "b:d:hut:p:v:" opt; do
    case ${opt} in
        b)
            s3_bucket="${OPTARG}"
        ;;
        h)
            usage
            exit 0
        ;;
        p)
            packer_opts="${OPTARG}"
        ;;
        v)
            centos_version="${OPTARG}"
        ;;
        t)  
            build_timestamp="${OPTARG}"
        ;;
        u)  
            aws_only=1
        ;;
        *)
            echo
            usage >&2
            exit 1
        ;;
    esac
done

shift $(( OPTIND - 1 ))

if [[ ${aws_only} -ne 1 ]]; then

  if [ -z "${s3_bucket}" ]; then
      echo "s3_bucket name required" 
      usage >&2
      exit 1
  fi

  if [ -z "${centos_version}" ]; then
      echo 'CentOS version cannot be blank' >&2
      exit 1
  fi

  # remove initial directory, if exists ( .ova's get copied to a saved dir later )
  if [[ -d output_packer ]]; then
      rm -rf output_packer
  fi

  if [ -f centos-"${centos_version}"-x86_64-template.json ]; then 
    echo "Starting Packer Build..."
    packer.io build --var build_number="${build_timestamp}" ${packer_opts} centos-"${centos_version}"-x86_64-template.json
  else
    echo "centos-"${centos_version}"-x86_64-template.json not found"
    echo "exiting.."
    exit 1
  fi

  # mkdir -p output_packer
  mkdir -p saved_builds 

  # make a copy of the build into the saved_builds directory
  if [ -f output_packer/centos-"${centos_version}"-x86_64-"${build_timestamp}".ova ]; then
    cp output_packer/centos-"${centos_version}"-x86_64-"${build_timestamp}".ova saved_builds/centos-"${centos_version}"-x86_64-"${build_timestamp}".ova
  fi
fi # end if aws_only

if [[ ${aws_only} -eq 1 ]]; then
  cp saved_builds/centos-"${centos_version}"-x86_64-"${build_timestamp}".ova output_packer/centos-"${centos_version}"-x86_64-"${build_timestamp}".ova
fi

if [ -f output_packer/centos-"${centos_version}"-x86_64-"${build_timestamp}".ova ]; then
  echo "Uploading to S3... "

  aws s3 cp "output_packer/centos-${centos_version}-x86_64-${build_timestamp}.ova" "s3://${s3_bucket}/centos-${centos_version}-x86_64-${build_timestamp}.ova"
else
  echo "output_packer/centos-${centos_version}-x86_64-${build_timestamp}.ova not found"
  echo "exiting..."
  exit 1
fi

ova_name=centos-${centos_version}-x86_64-${build_timestamp}.ova

echo "Importing EC2 Image... "

aws_task_id=$(aws ec2 import-image --cli-input-json "{\"Description\": \"centos-${centos_version}-x86_64-${build_timestamp}\",\"DiskContainers\": [{\"Description\": \"centos-${centos_version}-x86_64-${build_timestamp}\",\"UserBucket\": {\"S3Bucket\": \"${s3_bucket}\",\"S3Key\": \"centos-${centos_version}-x86_64-${build_timestamp}.ova\"}}]}" | jq -r '.ImportTaskId')

echo "Getting AWS AMI id... "

aws_ami=''

while true; do
  aws_ami=$(aws ec2 describe-images --owners self | jq -j --arg awstaskid $aws_task_id '.Images[]|select(.Name==$awstaskid).ImageId')

  if [[ -z ${aws_ami} ]]; then
    echo "Progress: `aws ec2 describe-import-image-tasks | jq -j '.ImportImageTasks[]|select(.Progress>0).Progress'`%"
    sleep 60;
  else
    echo -e "aws_ami IS READY..."
    break
  fi

done

echo "AMI is: ${aws_ami}"

