include "globals.mzn";

% Input values
int: w_paper;
int: h_paper;
int: n;
array[ns, 1..2] of int: presents;

% Constants
int: k = 2;
int: total_paper_area = w_paper * h_paper;
int: total_presents_area = sum(areas);
int: max_dim = max(w_paper, h_paper);
int: min_present_width = min(presents_xs);
int: min_present_height = min(presents_ys);
int: max_present_width = max(presents_xs);
int: max_present_height = max(presents_ys);
int: min_present_dim = min([min_present_width, min_present_height]);
int: max_present_dim = max([max_present_width, max_present_height]);
set of int: dim = 1..k;
set of int: ns = 1..n;
set of int: ns_rot = 1..2 * n;
array[dim] of int: l = [0, 0];
array[dim] of int: u = [w_paper, h_paper];
array[ns] of int: presents_xs = [presents[i, 1] | i in ns];
array[ns] of int: presents_ys = [presents[i, 2] | i in ns];
array[ns] of int: areas = [presents_xs[i] * presents_ys[i] | i in ns];
array[ns] of ns: order = sort_by(ns, [-areas[i] | i in ns]);
array[ns_rot, dim] of int: rect_size = array2d(ns_rot, dim, [get_rot(i, j, k)| i in ns, j, k in 0..1]);
array[ns_rot, dim] of int: rect_offset = array2d(ns_rot, dim, [0 | i in 1..4 * n]);
array[ns_rot] of set of ns_rot: shape = [{i}| i in ns_rot];
array[ns] of set of ns_rot: valid_shapes = [{i, i + 1}| i in ns_rot where i mod 2 != 0];

% Variables
array[ns, dim] of var 0..max_dim - min_present_dim: bl_corners;
array[ns, 1..2] of var min_present_dim..max_dim: tr_corners;
array[ns] of var 0..w_paper - min_present_dim: bl_corners_xs;
array[ns] of var 0..h_paper - min_present_dim: bl_corners_ys;
array[ns] of var 0..coord_to_value(w_paper, h_paper): bl_corners_values;
array[ns] of var min_present_dim..max_present_dim: actual_presents_xs = [actual_dim(i, 1) | i in ns];
array[ns] of var min_present_dim..max_present_dim: actual_presents_ys = [actual_dim(i, 2) | i in ns];
array[ns] of var ns_rot: kind;

% Functions
function int: coord_to_value(int: x, int: y) = x + (y * max_dim);
function int: other_axis(int: axis) = if axis == 1 then 2 elseif axis == 2 then 1 else -1 endif;
function int: get_dim(int: ind, int: axis) = if axis == 0 then presents_xs[ind] elseif axis == 1 then presents_ys[ind] else -1 endif;
function int: get_rot(int: ind, int: axis, int: rot) = if rot == 0 then get_dim(ind, axis) elseif rot == 1 then get_dim(ind, 1 - axis) else -1 endif;
function var int: coord_to_value(var int: x, var int: y) = x + (y * max_dim);
function var int: actual_dim(int: ind, int: axis) = if kind[ind] mod 2 == 0 then presents[ind, other_axis(axis)] else presents[ind, axis] endif;

% Channeling constraints
predicate bl_corners_channeling(int: i) = 
    bl_corners_xs[i] == bl_corners[i, 1] /\ 
    bl_corners_ys[i] == bl_corners[i, 2];
constraint forall(i in ns) (bl_corners_channeling(i));

predicate tr_corners_channeling(int: i) = 
    tr_corners[i, 1] == bl_corners_xs[i] + actual_presents_xs[i] /\ 
    tr_corners[i, 2] == bl_corners_ys[i] + actual_presents_ys[i];
constraint forall(i in ns) (tr_corners_channeling(i));

predicate values_channeling(int: i) = 
    bl_corners_values[i] == coord_to_value(bl_corners_xs[i], bl_corners_ys[i]);
constraint forall(i in ns) (values_channeling(i));

% Constraints
% Presents cannot overlap
constraint diffn(bl_corners_xs, bl_corners_ys, actual_presents_xs, actual_presents_ys);

% Presents should be contained inside the wrapping paper and they should be maximally stacked
constraint cumulative(bl_corners_xs, actual_presents_xs, actual_presents_ys, h_paper);
constraint cumulative(bl_corners_ys, actual_presents_ys, actual_presents_xs, w_paper);

% Reduce presents domains
constraint forall(i in ns) (
    bl_corners_xs[i] <= w_paper - actual_presents_xs[i] /\ 
    bl_corners_ys[i] <= h_paper - actual_presents_ys[i]
);
constraint forall(i in ns) (
    tr_corners[i, 1] >= actual_presents_xs[i] /\ 
    tr_corners[i, 2] >= actual_presents_ys[i]
);

% All the presents have different bottom left corners
constraint alldifferent(bl_corners_values);

% One present is always placed at the origin
constraint count_eq(bl_corners_values, 0, 1);

% Sum of all the areas of all the placed presents equal to total area
constraint sum(i in ns) (
    (tr_corners[i, 1] - bl_corners[i, 1]) * (tr_corners[i, 2] - bl_corners[i, 2])
) <= total_paper_area;
constraint sum(i in ns) (
    (tr_corners[i, 1] - bl_corners[i, 1]) * (tr_corners[i, 2] - bl_corners[i, 2])
) == total_presents_area;

% Rectangles must have valid shapes
constraint forall (obj in ns) (kind[obj] in valid_shapes[obj]);

% Non-overlap, bounding box, rotation handling 
constraint geost_bb(k, rect_size, rect_offset, shape, bl_corners, kind, l, u);

% Symmetry breaking constraints
% The biggest rectangle should be placed below the second biggest
constraint let {
    int: i = order[1], int: j = order[2]
} in lex_less([bl_corners_ys[i], bl_corners_xs[i]], [bl_corners_ys[j], bl_corners_xs[j]]);

% Rectangles with same dimensions handling
constraint forall(i in ns)(
    let {
        array[int] of int: same_dim_ind = [j | j in ns where presents_xs[j] = presents_xs[i] /\ presents_ys[j] = presents_ys[i]]
    } in 
        if length(same_dim_ind) > 1 /\ min(same_dim_ind) = i then
            forall(j in index_set(same_dim_ind) where j > 1) (
                lex_less(
                    [bl_corners_ys[same_dim_ind[j - 1]], bl_corners_xs[same_dim_ind[j - 1]]], 
                    [bl_corners_ys[same_dim_ind[j]], bl_corners_xs[same_dim_ind[j]]]
                )
            )
        else true 
        endif
);

% Search
solve:: seq_search([
    int_search([bl_corners_ys[i] | i in order], input_order, indomain_min, complete),
    int_search([bl_corners_xs[i] | i in order], input_order, indomain_min, complete)
]) satisfy;
