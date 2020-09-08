include "globals.mzn";

%Input values
int: w_paper;
int: h_paper;
int: n;
array[ns, 1..2] of int: presents;

% Constants
int: max_dim = max(w_paper, h_paper);
int: total_paper_area = w_paper * h_paper;
int: total_presents_area = sum(areas);
int: min_present_width = min(presents_xs);
int: min_present_height = min(presents_ys);
int: max_present_width = max(presents_xs);
int: max_present_height = max(presents_ys);
int: min_present_dim = min([min_present_width, min_present_height]);
int: max_present_dim = max([max_present_width, max_present_height]);
int: max_present_ind = arg_max(areas);
set of int: ns = 1..n;
array[ns] of int: presents_xs = [presents[i, 1] | i in ns];
array[ns] of int: presents_ys = [presents[i, 2] | i in ns];
array[ns] of int: areas = [presents_xs[i] * presents_ys[i] | i in ns];

% Variables
array[ns, 1..2] of var 0..max_dim - min_present_dim: bl_corners;
array[ns, 1..2] of var min_present_dim..max_dim: tr_corners;
array[ns] of var 0..coord_to_value(w_paper, h_paper): bl_corners_values;
array[ns] of var 0..w_paper - min_present_width: bl_corners_xs;
array[ns] of var 0..h_paper - min_present_height: bl_corners_ys;

% Functions
function int: coord_to_value(int: x, int: y) = x + (y * max_dim);
function var int: coord_to_value(var int: x, var int: y) = x + (y * max_dim);

% Channeling constraints
predicate bl_corners_channeling(int: i) = 
    bl_corners_xs[i] == bl_corners[i, 1] /\ 
    bl_corners_ys[i] == bl_corners[i, 2];
constraint forall(i in ns) (bl_corners_channeling(i));

predicate values_channeling(int: i) = 
    bl_corners_values[i] == coord_to_value(bl_corners_xs[i], bl_corners_ys[i]);
constraint forall(i in ns) (values_channeling(i));

predicate tr_corners_channeling(int: i) = 
    tr_corners[i, 1] == bl_corners_xs[i] + presents_xs[i] /\ 
    tr_corners[i, 2] == bl_corners_ys[i] + presents_ys[i];
constraint forall(i in ns) (tr_corners_channeling(i));

% Constraints
% Reduce presents domains
constraint forall(i in ns) (
    bl_corners_xs[i] <= w_paper - presents_xs[i] /\ 
    bl_corners_ys[i] <= h_paper - presents_ys[i]
);
constraint forall(i in ns) (
    tr_corners[i, 1] >= presents_xs[i] /\ 
    tr_corners[i, 2] >= presents_ys[i]
);

% Two presents sum to total height or width
constraint forall(i, j in ns where j > i) (
    presents_xs[i] == presents_xs[j] /\ presents_ys[i] + presents_ys[j] == h_paper -> 
    bl_corners_ys[j] = presents_ys[i] /\ bl_corners_ys[i] = 0
);
constraint forall(i, j in ns where j > i) (
    presents_ys[i] == presents_ys[j] /\ presents_xs[i] + presents_xs[j] == w_paper -> 
    bl_corners_xs[j] = presents_xs[i] /\ bl_corners_xs[i] = 0
);

% Sum of all the areas of all the placed presents equal to total area
constraint sum(i in ns) (
    (tr_corners[i, 1] - bl_corners[i, 1]) * (tr_corners[i, 2] - bl_corners[i, 2])
) <= total_paper_area;
constraint sum(i in ns) (
    (tr_corners[i, 1] - bl_corners[i, 1]) * (tr_corners[i, 2] - bl_corners[i, 2])
) == total_presents_area;

% All the presents have different bottom left corners
constraint alldifferent(bl_corners_values);

% One present is always placed at the origin
constraint count_eq(bl_corners_values, 0, 1);

% Presents cannot overlap
constraint diffn_k(bl_corners, presents);

% Presents should be contained inside the wrapping paper and they should be maximally stacked
constraint cumulative(bl_corners_xs, presents_xs, presents_ys, h_paper);
constraint cumulative(bl_corners_ys, presents_ys, presents_xs, w_paper);

% Symmetry breaking constraints
% Biggest rectangle contained in the lower-left quadrant
constraint 
    bl_corners_xs[max_present_ind] <= (w_paper - presents_xs[max_present_ind]) / 2 /\ 
    bl_corners_ys[max_present_ind] <= (h_paper - presents_ys[max_present_ind]) / 2;

/*
% Presents in the same column ordered by width
constraint forall(i, j in ns where j > i) (
    bl_corners_xs[i] == bl_corners_xs[j] /\ presents_xs[i] <= presents_xs[j] -> 
    bl_corners_ys[i] > bl_corners_ys[j]
);
*/

% Search
solve satisfy;
