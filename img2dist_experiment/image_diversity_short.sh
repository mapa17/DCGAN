#!/bin/bash

# Stop on any error
set -e

## Settings 
declare -a MODELS=("dcgan-0" "dcgan-10000" "dcgan-20000" "dcgan-30000" "dcgan-40000"
"dcgan-50000" "dcgan-60000" "dcgan-70000" "dcgan-80000" "dcgan-90000" "dcgan-99999")

MODEL_FOLDER="./trained_models/dcgan_BS16_short/"
OUTFOLDER="./image_diversity_short/"
NIMAGES=54

## Generate pictures
for MODEL in "${MODELS[@]}"
do
    echo "Processing model ${MODEL} ..."
    python GANcontrol.py generate ${MODEL_FOLDER}${MODEL} ${NIMAGES} ${OUTFOLDER}/generated/${MODEL}
done

## Generate a distance plot for each model
for MODEL in "${MODELS[@]}"
do
    echo "Generating distance plot for model ${MODEL} ..."
    python img2dist.py embedding ${OUTFOLDER}/image_diversity_${MODEL}.jpg ${OUTFOLDER}/generated/${MODEL}
done


# Generate an overview figure 
python img2dist.py embedding ${OUTFOLDER}/image_diversity.jpg ${OUTFOLDER}/generated/* --group --group-labels

# Generate another overview, including the training images
python img2dist.py embedding ${OUTFOLDER}/image_diversity_with_training_data.jpg ${OUTFOLDER}/generated/* ./training_images_160x160_subset --group --group-labels