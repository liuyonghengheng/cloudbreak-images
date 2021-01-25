#!/bin/bash

AMI_NAME=$(aws ec2 describe-images --region $SOURCE_LOCATION --image-ids $IMAGE_NAME --owners "self" --query 'Images[*].[Name]' --output "text")
echo "Restoring AMI $IMAGE_NAME ($AMI_NAME) from region $SOURCE_LOCATION to regions $AWS_AMI_REGIONS"

for REGION in $(echo $AWS_AMI_REGIONS | sed "s/,/ /g")
do
  echo "Copying to region $REGION..."

  if [ "$REGION" == "$SOURCE_LOCATION" ]
  then
    echo "Source and destination regions are the same, skipping"
    continue
  fi

  AMI_IN_REGION=$(aws ec2 copy-image --source-image-id $IMAGE_NAME --source-region $SOURCE_LOCATION --region $REGION --name $AMI_NAME --output "text")
  echo "AMI copy started to region $REGION as $AMI_IN_REGION"

  aws ec2 wait image-available --region $REGION --image-ids $AMI_IN_REGION & # wait for image availability in a new process
done

echo "Waiting for copy operations to finish..."
wait
echo "Image restored"
