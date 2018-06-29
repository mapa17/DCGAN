# Deep Convolutional GAN 
In this exercise we have to create a GAN that generates images of melanoma similar
to [isic-archive](https://isic-archive.com).

> Note: The repository contains the trained models which are huge (~4GB) if you want to
> skip their download run:

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/mapa17/DCGAN.git
```

This repository contains the following tools
* **[isic_dataset](#isic_dataset)** a tool to download, resize and augment images from the isic-archive
* **[GANcontrol](#GANcontrol)** used to train GAN's, generate images with pre trained models, and continue training models
* **[DCGAN](#DCGAN)** a deep convolutional GAN based on [YadiraF's dcgan](https://github.com/YadiraF/GAN/blob/master/dcgan.py)
* **[img2dist](#img2dist)** a tool to calculate image similarity based on [Color Quantization](http://scikit-learn.org/stable/auto_examples/cluster/plot_color_quantization.html) and can visualize the distribution of multiple images by generating scatter plots of  

# GANcontrol
Gancontrol is helper script that facilitates the training, retraining and generation of images.

## Training
Train a model on images in ./training_data for 200000 training cycles with a batch size of 16, storing results to ./trained_model_output

    python GANcontrol.py training ./training_data 200000 16 ./trained_model_output

> Note: Use the option --keep-checkpoints to keep intermediate trained models

## Image generation
Use a pre trained network in **trained_models/dcgan-200000** and generate 50 new images, storing them in **./newlycreated**.

```bash
python GANcontrol.py generate trained_models/dcgan-200000 50 ./newlycreated
```

> Note: use the option --overview to generate a single figure containing NxN pictures

# DCGAN
This is a deep convolution GAN based on [YadiraF's dcgan](https://github.com/YadiraF/GAN/blob/master/dcgan.py). It has been altered 
to be trained and generate images of 160x160 pixels.

The best results have been obtained by hand selecting 55 images from the isis-archive and using image augmentation to generate 10000 training images.
The hand [selected image subset](training_images_160x160_subset) and the augmented [training set](training_set/training_images_160x160_augmented_10k.tar.bz2), are part of this repository. 

The network was trained on an Tesla P100-PCIE-12GB GPU for about 17 hours, producing results similar to

Example1 | Example 2  | Example 3
:-------------:|:------------:|:-------------:
![](example_images/example1.png)  | ![](example_images/example2.png)  | ![](example_images/example3.png)  |


# isic_dataset
This tool canb e used to download imges, preprocess them, and augment them using [Augmentor](https://github.com/mdbloice/Augmentor).

    python isic_dataset.py --help


## Download Images
One can download multiple images from the different data sets offered by isic

    python isic_dataset.py download --help

Example Download 1000 images to the folder original_images

    python isic_dataset.py download ./original_images -n 1000

*Note* Based on the content of the isic-archive fewer pictures might be downloaded
than specified.

## Transform Images
The original images exist in different resolutions and sizes. In order to use them
for training they have to be reshaped to the same size. This is done by center
cropping and resizing.

    python isic_dataset.py transform --help

Example: Transform all images in ./original_images to a size of 160x160 and store them in the folder ./test_images

    python isic_dataset.py transform ./original_images ./test_images 160 160

## Data Augmentation
Training images can be augmented using the [Augmentor](https://github.com/mdbloice/Augmentor) library.

    python isic_dataset.py augment --help


Example: Augment images in *training_images*, generating 10000 augmented images

    python isic_dataset.py augment training_images 10000

The augmented images are stored in *training_images/output*

# img2dist
In order to evaluate how diverse the image set is generated by the GAN's we can use another tool **img2dist** that calculates a distance between two images based on [Color Quantization](http://scikit-learn.org/stable/auto_examples/cluster/plot_color_quantization.html). A distance is defined as the sum of euclidean distances between the 5 closest centroids of an image in the RGB color space.

## Calculate the distance between two images
Calculate the distance of the two iamges Car.jpg and Airplane.jpg

```bash
python img2dist.py distance color_distance/OtherStuff/Car.jpg color_distance/OtherStuff/Airplane.jpg
```

## Generate a distance plot
In order to relate the distance of multiple images, one can create a plot that uses two dimensional embedding of the pairwise distances (in this case [multidimensional scaling](http://scikit-learn.org/stable/modules/generated/sklearn.manifold.MDS.html))

Create a plot **training_images_subset.jpg** by calculating the distances for all pictures inside of **training_images_160x160_subset** 
```bash
python img2dist.py embedding --skip-labels training_images_subset.jpg training_images_160x160_subset/
```

Or compare the distance distribution of various image groups, by saving images in different sub-folders.

```bash
python img2dist.py embedding --group --group-labels --limits 2.0 color_distance_test.jpg color_distance/*
```

> Note: One can define the limits of the plot using  *--limits 2.0*

## Evaluate img2dist
In order to evaluate if img2dist can produce useful distance measures and embedding,
we tried to generate a distance plot of six groups of images.

Groups S1-S5 have been produced by taking 5 random pictures from the training set, and
using image augmentation generating 10 variations of each.

The group **OtherStuff** is a set of 4 images chosen from the internet that contain
different objects than the isic dataset.

The result shows a clear clustering, where images of the same group (S1-S5) are
closer to each other than to other groups, and unrelated images from **OtherStuff**
is far apart from the rest.

![img2dist proof of concept](img2dist_experiment/color_distance.jpg)

## Image diversity of DCGAN generated images
Finally we tested the image diversity of pictures generated with the DCGAN,
tracking the pictures generated during multiple steps of the training process.

![DCGAN image diversity](img2dist_experiment/image_diversity_short/image_diversity_with_training_data.jpg)

Interpreting the results, one can see a clear difference between images generated
at the beginning (group dcgan-0) and later stages of training (dcgan-10000 til dcgan-99999).

Between the trained groups (dcgan-10000 til dcgan-99999) there is no obvious pattern
emerging, and the share similar in group as between group distances, although qualitatively,
the images differ strongly

In addition there seems to be a systematic shift in all trained images from the
training set, showing the most of the training images are not overlapping with the
generated image clusters. Judging by the spread of points from the training set, 
there seems to be more image diversity in the training set than in the generated
image sets at any time during training.


# Todo
* Quantify cluster metrics (like mean spread) in the MDS embedding containing all groups.