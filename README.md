# PWP (Present Wrapping Problem)

As described in the [project assignment](assignment.pdf), PWP can be seen as a specialization of the more general rectangle packing problem, in which we have a set of rectangles (our presents) of given dimensions that have to fit into a pre-determined container (the wrapping paper) of a given size. The great thing about PWP is that we know the items will perfectly fit into the given container, without any kind of wasted space.

## Installation & Execution

This project was written and tested with `Python 3.8`, so make sure that you have it installed on your system.
The libraries required by the project are listed in the `requirements.txt` file. You can install them by running:

```bash
pip install -r requirements.txt
```

The core of the project is inside the [pwp.ipynb](pwp.ipynb) Jupyter notebook, which is subdivided into the following sections:

- `CP`, containing different MiniZinc models
- `SMT`, containing various Z3 models

Minizinc models have been implemented using the [iMiniZinc](https://github.com/MiniZinc/iminizinc) Jupyter extension, while Z3 models are implemented with the official [Z3 Python API](https://z3prover.github.io/api/html/namespacez3py.html).

## Usage & Explanation

You can directly execute models inside the Jupyter notebook to see the corresponding outputs. Moreover, models are well-documented in the notebook itself, with detailed improvements history and constraints studying.

In case you don't want to install Jupyter on your system, you can simply check our results in the [pwp.html](pwp.html) file and read more about the project in the [report.pdf](report/report.pdf) file.

## Other files

Folders in the root of the project have the following content:

- `instances`: contains PWP test instances (check [pwp.html](pwp.html) to see the file structure)
- `models`: contains CP and SMT models, in `.mzn` and `.smt2` extensions
- `out`: contains textual outputs for both CP and SMT solutions
- `plots`: contains graphical solutions and running time plots for both CP and SMT final models
- `report`: contains the project report
