# PWP (Present Wrapping Problem)

The PWP can be seen as a specialization of the more general rectangle packing problem, in which we have a set of rectangles (our presents) of given dimensions that have to fit into a pre-determined container (the wrapping paper) of a given size. The great thing about PWP is that we know the items will perfectly fit into the given container, without any kind of wasted space.

## Installation & Execution

This project was written and tested with `Python 3.8`, so make sure that you have it installed on your system.
The libraries required by the project are listed in the `requirements.txt` file. You can install them by running:

```bash
pip install -r requirements.txt
```

The core of the project is inside the `pwp.ipynb` Jupyter notebook, which is subdivided into the following sections:

* `CP`, containing different MiniZinc models
* `SMT`, containing various Z3 models

Minizinc models have been implemented using the [iMiniZinc](https://github.com/MiniZinc/iminizinc) Jupyter extension, while Z3 models are implemented with the official [Z3 Python API](https://z3prover.github.io/api/html/namespacez3py.html).

## Usage & Explanation

You can directly execute models inside the Jupyter notebook to see the corresponding outputs. Moreover, models are well-documented in the notebook itself, with detailed improvements history and constraints studying.

In case you don't want to install Jupyter on your system, you can simply check our results in the `pwp.html` or `pwp.pdf` files.

## References
- <a id="1">[1]</a>
  _Mikael Östlund (2017)_.\
  **Implementation and Evaluation of a Sweep-Based Propagator for Diffn in Gecode**.\
  Uppsala Universitet, Department of Information Technology.
- <a id="2">[2]</a>
  _Eric Huang, Richard E. Korf (2009)_.\
  **New Improvements in Optimal Rectangle Packing**.\
  IJCAI'09: Proceedings of the 21st international jont conference on Artifical intelligence, Pages 511–516.
- <a id="3">[3]</a>
  _Hakan Kjellerstrand_.\
  [**My Z3/Z3Py page**](http://www.hakank.org/z3/).
