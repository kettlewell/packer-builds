#!/usr/bin/env bash

set -eu

build_timestamp="$(date +%s)"
centos_version='7.2.1511'
packer_opts=''
s3_bucket='kettlewell-images'
aws_only=0
image_format="vmdk"

function usage {
    cat <<EOF
Usage: ${0##*/} [-b s3_bucket] [-p packer_options] [-v centos_version] [-t timestamp ] [-u]

  -b bucket     The name of the S3 bucket. Default is hardcoded.
  -p options    Additional packer options. Ex: '--var foo=bar --var bar=foo'
  -v version    The version of CentOS to build. Default is ${centos_version}.
  -t timestamp  The timestamp to use if uploading to S3 (-u)
  -u            Upload to S3 (requires timestamp)
  -f format     Format of the output file ( ova or vmdk)

EOF
}

while getopts "b:d:hut:p:v:f:" opt; do
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
        f)
            image_format="${OPTARG}"
        ;;
        *)
            echo
            usage >&2
            exit 1
        ;;
    esac
done

shift $(( OPTIND - 1 ))


if [[ ${image_format} == "vmdk" ]] && [[ 1 -eq 1 ]]; then
    image_name=centos-7.2-${build_timestamp}-disk1.vmdk
elif [[ ${image_format} == "ova" ]] && [[ 1 -eq 1 ]]; then
    image_name=centos-7.2-${build_timestamp}.ova
else
    echo "unknown image format. Only ova and vmdk recognized."
fi

echo "image name:  ${image_name}"


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

  # remove initial directory, if exists ( images get copied to a saved dir later )

  echo "checking for existing output_packer directory"
  if [[ -d output_packer ]]; then
      echo "removing output_packer directory... "
      rm -rf output_packer
  fi

  if [ -f centos-7.2-packer-template.json ]; then 
    echo "Starting Packer Build..."
    PACKER_LOG=0 packer.io build --var build_number="${build_timestamp}" ${packer_opts} centos-7.2-packer-template.json
  else
    echo "centos-7.2-packer-template.json not found"
    echo "exiting.."
    exit 1
  fi

  # mkdir -p output_packer
  mkdir -p saved_builds 

  # make a copy of the build into the saved_builds directory
  if [[ ${image_format} == "vmdk" ]] && [[ -f output_packer/centos-7.2-"${build_timestamp}"-disk1.vmdk ]]; then
    cp output_packer/centos-7.2-"${build_timestamp}"-disk1.vmdk saved_builds/centos-7.2-"${build_timestamp}"-disk1.vmdk
  elif [[ ${image_format} == "ova" ]] && [[ -f output_packer/centos-7.2-"${build_timestamp}".ova ]]; then
    cp output_packer/centos-7.2-"${build_timestamp}".ova saved_builds/centos-7.2-"${build_timestamp}".ova
  else
    echo "unable to copy file to saved_builds directory... "
    if [[ ${image_format} == "vmdk" ]]; then
       echo "image not found:  output_packer/centos-7.2-${build_timestamp}-disk1.vmdk"
    elif [[ ${image_format} == "ova" ]]; then
       echo "image not found:  output_packer/centos-7.2-${build_timestamp}.ova"
    fi
  fi

fi # end if aws_only

if [[ ${aws_only} -eq 1 ]] && [[ ${image_format} == "vmdk" ]]; then
  cp saved_builds/centos-7.2-"${build_timestamp}"-disk1.vmdk output_packer/centos-7.2-"${build_timestamp}"-disk1.vmdk
elif [[ ${aws_only} -eq 1 ]] && [[ ${image_format} == "ova" ]]; then
  cp saved_builds/centos-7.2-"${build_timestamp}".ova output_packer/centos-7.2-"${build_timestamp}".ova
fi

if [[ ${image_format} == "vmdk" ]] && [[ -f output_packer/centos-7.2-"${build_timestamp}"-disk1.vmdk ]]; then
  echo "Uploading VMDK Image to S3... "
  aws s3 cp "output_packer/centos-7.2-${build_timestamp}-disk1.vmdk" "s3://${s3_bucket}/centos-7.2-${build_timestamp}-disk1.vmdk"
elif [[ ${image_format} == "ova" ]] && [[ -f output_packer/centos-7.2-"${build_timestamp}".ova ]]; then
  echo "Uploading OVA Image to S3... "
  aws s3 cp "output_packer/centos-7.2-${build_timestamp}.ova" "s3://${s3_bucket}/centos-7.2-${build_timestamp}.ova"
else
  echo "Image not found"
  echo "exiting..."
  exit 1
fi

if [[ ${image_format} == "vmdk" ]]; then
    image_name=centos-7.2-${build_timestamp}-disk1.vmdk
elif [[ ${image_format} == "ova" ]]; then
    image_name=centos-7.2-${build_timestamp}.ova
else
    echo "unknown image format. Only ova and vmdk recognized."
    exit 1
fi

image_desc=centos-7.2-${build_timestamp}

echo "Importing EC2 Image... "

aws_task_id=$(aws ec2 import-image --cli-input-json "{\"Description\": \"${image_desc}\",\"DiskContainers\": [{\"Description\": \"${image_desc}\",\"UserBucket\": {\"S3Bucket\": \"${s3_bucket}\",\"S3Key\": \"${image_name}\"}}]}" | jq -r '.ImportTaskId')

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

