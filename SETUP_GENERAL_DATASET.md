# Setup for a General Dataset

This document aims to outline how to use the code in the repository herein on a general dataset (could be your own). For examples, see the additional code and documentation for the addition of the [CMU Panoptic Studio](http://domedb.perception.cs.cmu.edu/) dataset at [mvn/datasets/cmu_preprocessing/README.md](https://github.com/Samleo8/learnable-triangulation-pytorch/blob/master/mvn/datasets/cmu_preprocessing/README.md)

Note that this document only entails the setup for a general dataset. The next steps are probably to test or train your dataset; you can consult the other documents for [testing](TESTING_ON_GENERAL_DATASET.md) and [training](TRAINING_ON_GENERAL_DATASET.md) respectively.

## Overview

There are actually 4 main parts that one is required to do before to fully do testing/training:

1. Generate a labels file (`.npy`) file containing all the necessary data the algorithm needs, as listed in the [requirements](#requirements) section below. This is done using a `generate labels.py` file under `mvn/datasets/<your_dataset>`, specific to the dataset and [how the data is organised](#data-organisation).

   Part of this label file generation will also include generating a consolidated `npy` file with the BBOX data. This may be done separately using another python script.

2. Create a subclass of the pytorch `Dataset` class that loads information specific to your dataset, as organised in your npy labels file. This should be in `mvn/datasets/`
3. Create config files under the `experiments` folder that tell the algorithm how to handle your data.
4. Updating the `train.py` (or `demo.py`) file

- [Setup for a General Dataset](#setup-for-a-general-dataset)
  - [Overview](#overview)
- [1. Generating the Labels](#1-generating-the-labels)
  - [Requirements](#requirements)
  - [Data Organisation](#data-organisation)
    - [Images](#images)
    - [Camera Calibration Data](#camera-calibration-data)
    - [Pose Data (needed for training, and volumetric triangulation testing)](#pose-data-needed-for-training-and-volumetric-triangulation-testing)
  - [Generating bounding boxes](#generating-bounding-boxes)
    - [Algorithm for BBOXes](#algorithm-for-bboxes)
    - [BBOX Labels File](#bbox-labels-file)
  - [Needed Python Scripts](#needed-python-scripts)
    - [BBOX Generation Script](#bbox-generation-script)
    - [Labels Generation Script](#labels-generation-script)
- [2. Dataset Subclass](#2-dataset-subclass)
- [3. Config Files](#3-config-files)
- [4. Modifying main algorithm files](#4-modifying-main-algorithm-files)
  - [Modifying `train.py` or `demo.py`](#modifying-trainpy-or-demopy)
  - [Modifying `triangulation.py`](#modifying-triangulationpy)

***

# 1. Generating the Labels

## Requirements

For testing (and training), you will need the following data:

## Data Organisation

Preferably, the data should be organised similar to that of the CMU Panoptic Studio dataset, where the data is grouped by `action/scene` > `camera` > `person`.

Specifically, it would be good if the data is organised as below. Of course, the data does not necessarily have to be in the exact format; you would just need to make the appropriate changes to the respective [label generation](#labels-generation-script) and dataset subclass files.

### Images

`$DIR_ROOT/[ACTION_NAME]/hdImgs/[CAMERA_ID]/[FRAME_ID].jpg`

### Camera Calibration Data

`$DIR_ROOT/[ACTION_NAME]/calibration_[ACTION_NAME].json`

The JSON data should have this format, with the camera IDs in their appropriate order, or labelled accordingly:

```javascript
[
    {
        'id':   0, // optional
        'R':    [ /* 3x3 rotation matrix */ ],
        'k':    [ /* 3x3 calibration/instrinsics matrix */ ],
        't':    [ /* 3x1 translation matrix */ ],
        'dist': [ /* 5x1 distortion coefficients */ ]
    },
    {
        'id':   1, // optional
        'R':    [ /* 3x3 rotation matrix */ ],
        'k':    [ /* 3x3 calibration/instrinsics matrix */ ],
        't':    [ /* 3x1 translation matrix */ ],
        'dist': [ /* 5x1 distortion coefficients */ ]
    },
    {
        // ...
    }
]
```

More information on distortion coefficients [here](#https://docs.opencv.org/2.4/modules/calib3d/doc/camera_calibration_and_3d_reconstruction.html).

### Pose Data (needed for training, and volumetric triangulation testing)

`$DIR_ROOT/[ACTION_NAME]/3DKeypoints_[FRAME_ID].json`

The JSON data should have this notable format:

```javascript
[
    {
        'id':     [ /* PERSON_ID */ ],
        'joints': [ /* ARRAY OF JOINT COORDINATES IN COCO 19 FORMAT */ ]
    },
    {
        // ...
    }
]
```

## Generating bounding boxes

There are 2 inherent parts to this: the algorithm (MRCNN or SSD) to figure out the actual bounding boxes; and the generation of a labels file that consolidates the said data into a single labels file.

### Algorithm for BBOXes

This repository does not contain any algorithm to detect persons in the scene. For now, you need to find your own. Popular algorithms include Mask-RCNN (MRCNN) and Single Shot Detectors (SSD). Current SOTA include [Detectron2](https://github.com/facebookresearch/detectron2) and [MM Detection](https://github.com/open-mmlab/mmdetection).

**UPDATE:** I have used detectron to generate BBOXes for the CMU panoptic studio dance dataset [here](https://github.com/Samleo8/detectron2).

The data should ideally be organised by **action/scene** > **camera ID** > **person ID** with a JSON file containing an array of BBOXes in order of frame number.

### BBOX Labels File

A python script is needed to consolidate the bouding box labels. More information is given [below](#bbox-generation-script)

## Needed Python Scripts

I have included a template python script for a dataset called `ExampleDataset` which can be modified accordingly for your use. Parts which require attention have been marked with `TODO` statements. The scripts are modified directly from the relevant files related to the CMU Panoptic Dataset; you can reference those scripts too.

### BBOX Generation Script

Modify the `./mvn/datasets/example_preprocessing/collect-bboxes-npy.py` script. This script is used to generate an npy file that consolidates the BBOX data needed for the [labels generation script](#labels-generation-script). In the file are `TODO` statements which will point out what needs to be changed, and where.

### Labels Generation Script

Modify the `./mvn/datasets/example_preprocessing/generate-labels-npy.py` script. This script is used to generate an npy file containing all the information needed for the [dataset subclass python file](#2-dataset-subclass) to parse. In the file are `TODO` statements which will point out what needs to be changed, and where.

In particular, note that if you only want to do testing (no training) and have no ground truth keypoint data, you have to remove the `keypoints` field accordingly.

# 2. Dataset Subclass

An example of the dataset subclass is found in `./mvn/datasets/example_dataset.py`. Just follow the `TODO` comments in the `example_dataset.py` file and modify accordingly.

# 3. Config Files

There are also appropriate `.yaml` config files to be found that require appropriate modification in `./experiments/example` folder that the above subclass file uses. Again, follow the `TODO` comments in the respective YAML files. In particular, you need to update the file paths in the individual config files.

In particular, there is an `example_frames.yaml` file which allows you to specify the train/val splits by action > person > frames. This is an optional file. The config files that you will most likely use are `train/vol`.

Feel free to add more options into the config files, and then change the `train.py` files accordingly.

# 4. Modifying main algorithm files

After setting up your dataset subclass and config files, you need to let the `train.py` file "know about" your new dataset. If you directly run your dataset config files, you will get a `NotImplementedError`, which you need to fix by implementing your dataset. In this example, we are assuming that you dataset is named as `example`; this name is set in the [config files](#3-config-files) above.

Moreover, if you are testing using H36M as your pretrained weights, there may be some differences between your dataset and the pretrained one. This may require modifications to the other sections. For example, there may be differences in metric system (mm vs cm), or you may have different axes. See the issues [here](https://github.com/karfly/learnable-triangulation-pytorch/issues/24) and [here](https://github.com/karfly/learnable-triangulation-pytorch/issues/75) for reference.

## Modifying `train.py` or `demo.py`

**NOTE:** If know that you are only performing testing (i.e. you have no ground truth), then you should be modifying `demo.py` instead.

The first thing you need to do is to `import` your [dataset subclass](#2-dataset-subclass) at the top of `train.py`:

```python
from mvn.datasets import human36m, cmupanoptic, example # name of your dataset
```

After that, you need to setup your dataset for loading. Under the `setup_dataloaders` function, you need to add the following:

```python
# Change according to name of dataset
elif config.dataset.kind == 'example':
    train_dataloader, val_dataloader, train_sampler = setup_example_dataloaders(config, is_train, distributed_train)
```

Then, you will need to create the actual `setup_example_dataloaders` function. This is a literal copy pasta of the `setup_cmu_dataloaders` function, with modifications to the names of the [dataset subclasses](#2-dataset-subclass):

```python
def setup_cmu_dataloaders(config, is_train, distributed_train):
    train_dataloader = None
    if is_train:
        # train
        train_dataset = example_dataset.ExampleDataset(
            example_root=config.dataset.train.example_root,
            # ...
        )

        # ...

    # val
    val_dataset = example_dataset.ExampleDataset(
        example_root=config.dataset.train.example_root,
        #...
    )

    # ...

    return train_dataloader, val_dataloader, train_sampler
```

Note that it does not matter whether or not you have keypoint ground truth data, or whether you intend to use it for training or not. The code will just ignore it later accordingly.

## Modifying `triangulation.py`

It may be possible that your world coordinate system is different from that of the dataset used for the pretrained weights (Human 3.6M by default). Please refer to these issues [here](https://github.com/karfly/learnable-triangulation-pytorch/issues/24) and [here](https://github.com/karfly/learnable-triangulation-pytorch/issues/75) to check. If this is the case, you may need to change code in `triangulation.py`.

In `triangulation.py`, search for the comment `# different world coordinates` or the variable `self.transfer_cmu_to_human36m`. You should find a code similar to the following.

```python
# transfer
if self.transfer_cmu_to_human36m or self.kind == "cmu":  # different world coordinates
    coord_volume = coord_volume.permute(0, 2, 1, 3)
    inv_idx = torch.arange(coord_volume.shape[1] - 1, -1, -1).long().to(device)
    coord_volume = coord_volume.index_select(1, inv_idx)

    # print("Using different world coordinates")
```

Similary, you need to write code which changes the world coordinates if necessary, based on the `self.kind` parameter set in the config file.
