#!/bin/sh
# Runs train_cmu script iteratively with error handling

OFFSET=$1

if [ -z $2 ]; then
    END=9999
else
    END=$2
fi

WRITE_TO_USER=scleong

git pull && ./scripts/clear_nvidia_cache

for epoch in {$OFFSET..$END}
    git pull && ./clear_nvidia_cache
    ./train_cmu 3 || {
        cd ./logs/cmu/train
        ./change_checkpoints cmu_vol_softmax_VolumetricTriangulationNet@* $epoch
        echo "Epoch $epoch complete!" | write $WRITE_TO_USER
    }