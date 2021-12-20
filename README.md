# CALVIN


[<b>CALVIN - A benchmark for Language-Conditioned Policy Learning for Long-Horizon Robot Manipulation Tasks</b>](https://arxiv.org/pdf/2112.03227.pdf)
[Oier Mees](https://www.oiermees.com/), [Lukas Hermann](http://www2.informatik.uni-freiburg.de/~hermannl/), [Erick Rosete](https://www.erickrosete.com/), [Wolfram Burgard](http://www2.informatik.uni-freiburg.de/~burgard)

 We present **CALVIN** (**C**omposing **A**ctions from **L**anguage and **Vi**sio**n**), an open-source simulated benchmark to learn long-horizon language-conditioned tasks.
Our aim is to make it possible to develop agents that can solve many robotic manipulation tasks over a long horizon, from onboard sensors, and specified only via human language. CALVIN tasks are more complex in terms of sequence length, action space, and language than existing vision-and-language task datasets and supports flexible specification of sensor
suites.

![](media/teaser.png)

# :computer:  Quick Start
To begin, clone this repository locally
```bash
git clone --recurse-submodules https://github.com/mees/calvin.git
$ export CALVIN_ROOT=$(pwd)/calvin

```
Install requirements:
```bash
$ cd $CALVIN_ROOT
$ conda create -n calvin_venv python=3.8  # or use virtualenv
$ conda activate calvin_venv
$ sh install.sh
```

Download dataset (choose which split you want to download with the argument D, ABC or ABCD):
```bash
$ cd $CALVIN_ROOT/dataset
$ sh download_data.sh D | ABC | ABCD
```
##	:weight_lifting_man: Train Baseline Agent
Train baseline models:
```bash
$ cd $CALVIN_ROOT/calvin_models/calvin_agent
$ python training.py datamodule.root_data_dir=/path/to/dataset/
```
You want to scale your training to a multi-gpu setup? Just specify the [number of GPUs](https://pytorch-lightning.readthedocs.io/en/latest/advanced/multi_gpu.html#select-gpu-devices) and DDP will automatically be used
 for training thanks to [Pytorch Lightning](https://www.pytorchlightning.ai/).
To train on all available GPUs:
```bash
$ python training.py trainer.gpus=-1
```
If you have access to a Slurm cluster, follow this [guide](https://github.com/mees/calvin/blob/main/slurm_scripts/README.md).

You can use [Hydra's](https://hydra.cc/) flexible overriding system for changing hyperparameters.
For example, to train a model with  rgb images from both static camera and the gripper camera:
```bash
$ python training.py datamodule/observation_space=lang_rgb_static_gripper model/perceptual_encoder=gripper_cam
```
To train a model with RGB-D from both cameras:
```bash
$ python training.py datamodule/observation_space=lang_rgbd_both model/perceptual_encoder=RGBD_both
```
To train a model with rgb images from the static camera and visual tactile observations:
```bash
$ python training.py datamodule/observation_space=lang_rgb_static_tactile model/perceptual_encoder=static_RGB_tactile
```

To see all available hyperparameters:
```console
$ python training.py --help
```
To resume a training, just override the hydra working directory :
```console
$ python training.py hydra.run.dir=runs/my_dir
```

## :framed_picture: Sensory Observations
 CALVIN  supports a range of sensors commonly utilized for visuomotor  control:
1. **Static camera RGB images** - with shape `200x200x3`.
2. **Static camera Depth maps** - with shape `200x200x1`.
3. **Gripper camera RGB images** - with shape `200x200x3`.
4. **Gripper camera Depth maps** - with shape `200x200x1`.
5. **Tactile image** - with shape `120x160x2x3`.
6. **Proprioceptive state** - EE position (3), EE orientation in euler angles (3), gripper width (1), joint positions (7), gripper action (1).

<p align="center">
<img src="media/sensors.png" alt="" width="50%">
</p>

## :joystick: Action Space
In CALVIN, the  agent  must perform  closed-loop  continuous  control  to  follow  unconstrained  language  instructions  characterizing  complex  robot manipulation tasks, sending continuous actions to the robot at  30hz.
In  order  to  give  researchers  and  practitioners  the freedom to experiment with different action spaces, CALVIN supports  the following actions spaces:
1. **Absolute cartesian pose**  - EE position (3), EE orientation in euler angles (3),  gripper action (1).
2. **Relative cartesian displacement**  - EE position (3), EE orientation in euler angles (3),  gripper action (1).
3. **Joint action** -  Joint positions (7),  gripper action (1).

## :muscle: Evaluation: The Calvin Challenge
### Long-horizon Multi-task Language Control (LH-MTLC)
The  aim  of  the  CALVIN  benchmark  is  to  evaluate  the learning  of  long-horizon  language-conditioned  continuous control  policies.  In  this  setting,  a  single  agent  must  solve complex  manipulation  tasks  by  understanding  a  series  of unconstrained  language  expressions  in  a  row,  e.g.,  “open the  drawer. . . pick  up  the  blue  block. . . now  push  the  block into the drawer. . . now open the sliding door”.
We provide  an  evaluation  protocol  with  evaluation  modes  of varying  difficulty  by  choosing  different  combinations  of sensor  suites  and  amounts  of  training  environments.
To avoid a biased initial position, the robot is reset to a neutral position before every multi-step sequence.

To evaluate a trained calvin baseline agent, run the following command:

```
$ cd $CALVIN_ROOT/calvin_models/calvin_agent
$ python evaluation/evaluate_policy.py --dataset_path <PATH/TO/DATASET> --train_folder <PATH/TO/TRAINING/FOLDER>
```
Optional arguments:

- `--checkpoint <PATH/TO/CHECKPOINT>`: by default, the evaluation loads the last checkpoint in the training log directory.
You can instead specify the path to another checkpoint by adding this to the evaluation command.
- `--debug`: print debug information and visualize environment.

If you want to evaluate your own model architecture on the CALVIN challenge, you can implement the `CustomModel` class in `evaluate_policy.py`
as an interface to your agent. You need to implement the following methods:

- \_\_init__():
  gets called once at the beginning of the evaluation.
- reset(): gets called at the beginning of each evaluation sequence.
- step(obs, goal): gets called every step and returns the predicted action.

Then evaluate the model by running:
```
$ python evaluation/evaluate_policy.py --dataset_path <PATH/TO/DATASET> --custom_model
```

You are also free to use your own language model instead of using the precomputed language embeddings provided by CALVIN.
For this, implement `CustomLangEmbeddings` in `evaluate_policy.py` and add `--custom_lang_embeddings` to the evaluation command.

### Multi-task Language Control (MTLC)
Alternatively, you can evaluate the policy on single tasks and without resetting the robot to a neutral position.
Note that this evaluation is currently only available for our baseline agent.
```
$ python evaluation/evaluate_policy_singlestep.py --dataset_path <PATH/TO/DATASET> --train_folder <PATH/TO/TRAINING/FOLDER> [--checkpoint <PATH/TO/CHECKPOINT>] [--debug]
```

### Pre-trained Model
Download the [MCIL](http://calvin.cs.uni-freiburg.de/model_weights/D_D_static_rgb_baseline.zip) model checkpoint trained on the static camera rgb images on environment D.
```
$ wget http://calvin.cs.uni-freiburg.de/model_weights/D_D_static_rgb_baseline.zip
$ unzip D_D_static_rgb_baseline.zip
```
## :speech_balloon: Relabeling Raw Language Annotations
You want to try learning language conditioned policies in CALVIN with a new awesome language model?

We provide an [example script](https://github.com/mees/calvin/blob/main/calvin_models/calvin_agent/utils/relabel_with_new_lang_model.py) to relabel the annotations with different language model provided in [SBert](https://www.sbert.net/docs/pretrained_models.html), such as the larger MPNet (paraphrase-mpnet-base-v2) or its corresponding multilingual model (paraphrase-multilingual-mpnet-base-v2).
The supported options are "mini", "mpnet" and "multi". If you want to try different SBert models, just change the model name [here](https://github.com/mees/calvin/blob/main/calvin_models/calvin_agent/models/encoders/language_network.py#L18).
```
cd $CALVIN_ROOT/calvin_models/calvin_agent
python utils/relabel_with_new_lang_model.py +path=$CALVIN_ROOT/dataset/task_D_D/ +name_folder=new_lang_model_folder model.nlp_model=mpnet
```
If you additionally want to sample different language annotations for each sequence (from the same task annotations) in the training split run the same command with the parameter `reannotate=true`.

## :chart_with_upwards_trend: SOTA Models
Open-source models that outperform the MCIL baselines from CALVIN:

Contact [Oier](https://www.oiermees.com/) to add your model here.

## Reinforcement Learning with CALVIN
Are you interested in trying  reinforcement learning agents for the different manipulation tasks in the CALVIN environment?
We provide a [google colab](https://github.com/mees/calvin/blob/main/RL_with_CALVIN.ipynb) to showcase how to leverage the CALVIN task indicators to learn RL agents with a sparse reward.

## Citation

If you find the dataset or code useful, please cite:

```
@article{calvin21,
author = {Oier Mees and Lukas Hermann and Erick Rosete-Beas and Wolfram Burgard},
title = {CALVIN - A benchmark for Language-Conditioned Policy Learning for Long-Horizon Robot Manipulation Tasks},
journal={arXiv preprint arXiv:2112.03227},
year = 2021,
}
```

## License

MIT License
