#!/bin/bash

doormat --smoke-test || doormat -r && eval $(doormat aws --account se_demos_dev)

dryrun="--dry-run"
if [[ "$1" == "--no-dry-run" ]]; then
	echo NO DRY RUN
	echo Press enter to continue
	read

	dryrun=""
fi

image_filter='Name=name,Values=strawbtest/se-onboarding/webserver*'

for region in eu-west-1 eu-west-2; do
	echo "Region: ${region}"
	echo "Deleting Image(s):"

	# TODO: search with prefix
	aws --region=${region} ec2 describe-images --owners=self --filters ${image_filter} | jq -r .Images[]
	images=$(aws --region=${region} ec2 describe-images --owners=self --filters ${image_filter} | jq -r .Images[].ImageId)

	echo "${images}"
	for image_id in ${images}; do
		aws --region=${region} ec2 deregister-image ${dryrun} --image-id=${image_id}

		echo "Deleting Snapshot(s):"
		aws --region ${region} ec2 describe-snapshots --filters "Name=description,Values=*${image_id}*"  | jq -r .Snapshots[]
		snapshots=$(aws --region ${region} ec2 describe-snapshots --filters "Name=description,Values=*${image_id}*"  | jq -r .Snapshots[].SnapshotId)

		echo "${snapshots}"
		for snapshot_id in ${snapshots}; do
			aws --region ${region} ec2 delete-snapshot ${dryrun} --snapshot-id ${snapshot_id}
		done
	done
done

if [[ ${dryrun} == "--dry-run" ]]; then
	echo
	echo To run for real, run with
	echo ./cleanup.sh --no-dry-run
fi
