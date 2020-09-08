include "globals.mzn";

% Input values
int: w_paper;
int: h_paper;
int: n;
array[1..n, 1..2] of int: presents;

% Variables
array[1..n, 1..2] of var 0..max(w_paper, h_paper) - 1: bl_corners;

% Constraints
% Presents cannot overlap
constraint forall(i, j in 1..n where j > i) (
    max(bl_corners[i, 1], bl_corners[j, 1]) >= min(bl_corners[i, 1] + presents[i, 1], bl_corners[j, 1] + presents[j, 1]) \/
    max(bl_corners[i, 2], bl_corners[j, 2]) >= min(bl_corners[i, 2] + presents[i, 2], bl_corners[j, 2] + presents[j, 2])
);

% Reduce presents domains
constraint forall(i in 1..n) (bl_corners[i, 1] <= w_paper - presents[i, 1]);
constraint forall(i in 1..n) (bl_corners[i, 2] <= h_paper - presents[i, 2]);

% Search
solve satisfy;
