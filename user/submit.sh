#!/bin/bash



# Run settings

IMAGE=registry.rcp.epfl.ch/lts2-<project>/<image_name>:<tag>

# Submit job
# gpu_fraction: 0.5 for half-GPU, 1 for full GPU etc.
# pvc and existing-pvc: use the same path for both
# uid: your gaspar uid
# gid: 10423 (for LTS2)
runai submit \
    --tty \
    --stdin \
    --large-shm \
    --gpu gpu_fraction  \
    --name <job name>  \
	--image $IMAGE \
	--pvc lts2-scratch:/rcp  \
    --existing-pvc claimname=lts2-scratch,path=/rcp \
    --run-as-uid uid \
    --run-as-gid 10423 \
    --environment WANDB_API_KEY="your wandb api" \
    --working-dir  /rcp/username/path \
    --command -- /bin/bash -ic "./train_job.sh"











