study-encoders
===================
## Info
This repository hosts the study of encoders. The encoders could be already in use on the robot or new ones.

The studies could concern validating a given encoder or of the SW/FW that reads an encoder and its diagnostic.


## 🌿 Repository structure
This repository is organized based upon the following multiple parallel (i.e. orphan in Git jargon) branches:
- 🔘 [`master`](../../tree/master) contains general information.
- 🔘 [`sim`](../../tree/sim) contains simulations.
- 🔘 [`code`](../../tree/code) contains code and configuration files.
- 🔘 [`mech`](../../tree/mech) contains mechanical drawings.

### 🔽 How to clone specific branches locally
```console
git clone https://github.com/icub-tech-iit/encoders-study.git --single-branch --branch <branch-name>
```

Be careful that some branches (e.g., `master`, `mech`...) are handled via [Git LFS](https://help.github.com/en/articles/installing-git-large-file-storage).
