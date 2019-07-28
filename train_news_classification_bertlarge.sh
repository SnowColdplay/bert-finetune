#!/usr/bin/env bash

echo -e "\n[INFO ] Caching Data\n"

python3 cache_bertlarge.py
python3 cache_data.py

echo -e "\n[INFO ] Running on $N_GPU GPUs!\n"

mpirun -np $N_GPU -H localhost:$N_GPU \
    -bind-to none -map-by slot \
    -x NCCL_DEBUG=WARNING -x LD_LIBRARY_PATH -x PATH \
    -mca pml ob1 -mca btl ^openib \
    python3 news_classification.py \
    --xla --amp --sparse_as_dense --fp16_allreduce --maxseqlen 512 \
    --batch_size 3 --epochs 5 --bertlarge --progress --lazyadam
    