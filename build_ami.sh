#!/bin/sh

set -eu

build_timestamp="$(date +%s)"
centos_version='7.2.1511'
packer_opts=''
s3_bucket='kettlewell-images'


function usage {
    cat <<EOF
Usage: ${0##*/} [-b s3_bucket] [-p packer_options] [-v centos_version]

  -b            The name of the S3 bucket. Default is hardcoded.
  -p options    Additional packer options. Ex: '--var foo=bar --var bar=foo'
  -v version    The version of CentOS to build. Default is ${centos_version}.

EOF
}

while getopts "b:d:hp:v:" opt; do
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
        *)
            echo
            usage >&2
            exit 1
        ;;
    esac
done

shift $(( OPTIND - 1 ))

if [ -z "${s3_bucket}" ]; then
    echo "s3_bucket name required" 
    usage >&2
    exit 1
fi

if [ -z "${centos_version}" ]; then
    echo 'CentOS version cannot be blank' >&2
    exit 1
fi

if [ -f centos-"${centos_version}"-x86_64-template.json ]; then 
  echo "Starting Packer Build..."
  packer.io build --var build_number="${build_timestamp}" ${packer_opts} centos-"${centos_version}"-x86_64-template.json
else
  echo "centos-"${centos_version}"-x86_64-template.json not found"
  echo "exiting.."
  exit 1
fi
mkdir -p output_packer

if [ -f output_packer/centos-"${centos_version}"-x86_64-"${build_timestamp}".ova ]; then
  echo "Uploading to S3... "

  aws s3 cp "output_packer/centos-${centos_version}-x86_64-${build_timestamp}.ova" "s3://${s3_bucket}/centos-${centos_version}-x86_64-${build_timestamp}.ova"
else
  echo "output_packer/centos-${centos_version}-x86_64-${build_timestamp}.ova not found"
  echo "exiting..."
  exit 1
fi

echo "Importing EC2 Image... "

aws ec2 import-image --cli-input-json "{\"Description\": \"centos-${centos_version}-x86_64-${build_timestamp}\",\"DiskContainers\": [{\"Description\": \"centos-${centos_version}-x86_64-${build_timestamp}\",\"UserBucket\": {\"S3Bucket\": \"${s3_bucket}\",\"S3Key\": \"centos-${centos_version}-x86_64-${build_timestamp}.ova\"}}]}" | jq '.'

aws ec2 describe-import-image-tasks  | jq -r '.ImportImageTasks[]|select(.SnapshotDetails[].UserBucket.S3Key=="centos-7.2.1511-x86_64-1468241602.ova").ImportTaskId'


aws_task_id=aws ec2 describe-import-image-tasks  | jq -r '.ImportImageTasks[]|select(.Status=="active")|select(.SnapshotDetails[].UserBucket.S3Key=="centos-${centos_version}-x86_64-${build_timestamp}.ova").ImportTaskId'

aws_ami=aws ec2 describe-images --owners self | jq -r '.Images[]|select(.Name=="${aws_task_id}").ImageId'

echo "AMI is: ${aws_ami}"



# aws s3 cp "/tmp/packer-centos-${centos_version}-x86_64-updates-AMI-${build_timestamp}/packer-centos-${centos_version}-x86_64-updates-AMI-${build_timestamp}.ova" "s3://${s3_bucket}/${s3_prefix}packer-centos-${centos_version}-x86_64-updates-AMI-${build_timestamp}.ova"

#echo "Importing EC2 Image... "
#aws ec2 import-image --cli-input-json "{\"Description\": \"packer-centos-${centos_version}-x86_64-updates-AMI-${build_timestamp}\",\"DiskContainers\": [{\"Description\": \"packer-centos-${centos_version}-x86_64-updates-AMI-${build_timestamp}\",\"UserBucket\": {\"S3Bucket\": \"${s3_bucket}\",\"S3Key\": \"${s3_prefix}packer-centos-${centos_version}-x86_64-updates-AMI-${build_timestamp}.ova\"}}]}"
