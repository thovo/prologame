%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AI Player for 369 game, implementing the following heuristics
%
%	1. Max weight calculated over the max of sums of rows, columns, 
%	   forward and backwards diagonals
%	2. Max weight calculated over the leveled max of sums of rows,
%	   columns, forward and backwards diagonals 
%	3. Max weight calculated over a dynamic leveled max of sums of
%	   rows, columns, forward and backwards diagonals
%	   Dynamic means, the weights are always changing depending
%	   on the turn and the size of board.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating the naive sum heuristic (Heuristic 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
naive_sum(Board_matrix, Weight_matrix_fixed):-
	naive_sum([1,1], Board_matrix, Weight_matrix),
	remove_invalid(Board_matrix, Weight_matrix, Weight_matrix_fixed).

naive_sum([X,Y], Board_matrix, [HW|Weight_matrix]):-
	length(Board_matrix, Size),
	X =< Size,
	naive_sum_row([X,Y], Board_matrix, HW),
	Xn is X + 1,
	naive_sum([Xn,Y], Board_matrix, Weight_matrix).

naive_sum([X,_], Board_matrix, []):-
	length(Board_matrix, Size),
	X > Size.

naive_sum_row([X,Y], Board_matrix, [H|Row_weights]):-
	length(Board_matrix, Size),
	Y =< Size,
	get_row(Board_matrix, [X,_], Row),
	get_col(Board_matrix, [_,Y], Col),
	get_diag1(Board_matrix, [X,Y], Diag1),
	get_diag2(Board_matrix, [X,Y], Diag2),
	sum_list(Row, Row_sum),
	sum_list(Col, Col_sum),
	sum_list(Diag1, Diag1_sum),
	sum_list(Diag2, Diag2_sum),
	max_list([Row_sum, Col_sum, Diag1_sum, Diag2_sum], H),
	Yn is Y + 1,
	naive_sum_row([X, Yn], Board_matrix, Row_weights).

naive_sum_row([_,Y], Board_matrix, []):-
	length(Board_matrix, Size),
	Y > Size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating the leveled sum heuristic (Heuristic 2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
leveled_sum(Board_matrix, Weight_matrix_fixed):-
	leveled_sum([1,1], Board_matrix, Weight_matrix),
	remove_invalid(Board_matrix, Weight_matrix, Weight_matrix_fixed).

leveled_sum([X,Y], Board_matrix, [HW|Weight_matrix]):-
	length(Board_matrix, Size),
	X =< Size,
	leveled_sum_row([X,Y], Board_matrix, HW),
	Xn is X + 1,
	leveled_sum([Xn,Y], Board_matrix, Weight_matrix).

leveled_sum([X,_], Board_matrix, []):-
	length(Board_matrix, Size),
	X > Size.

leveled_sum_row([X,Y], Board_matrix, [Hleveled|Row_weights]):-
	length(Board_matrix, Size),
	Y =< Size,
	get_row(Board_matrix, [X,_], Row),
	get_col(Board_matrix, [_,Y], Col),
	get_diag1(Board_matrix, [X,Y], Diag1),
	get_diag2(Board_matrix, [X,Y], Diag2),
	sum_list(Row, Row_sum),
	sum_list(Col, Col_sum),
	sum_list(Diag1, Diag1_sum),
	sum_list(Diag2, Diag2_sum),
	max_list([Row_sum, Col_sum, Diag1_sum, Diag2_sum], H),
	get_weight_level(H, Hleveled),
	Yn is Y + 1,
	leveled_sum_row([X, Yn], Board_matrix, Row_weights).

leveled_sum_row([_,Y], Board_matrix, []):-
	length(Board_matrix, Size),
	Y > Size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating the dynamic leveled sum heuristic (Heuristic 3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dynamic_sum(Turns, Board_matrix, Weight_matrix_fixed):-
	dynamic_sum([1,1], Turns, Board_matrix, Weight_matrix),
	remove_invalid(Board_matrix, Weight_matrix, Weight_matrix_fixed).

dynamic_sum([X,Y], Turns, Board_matrix, [HW|Weight_matrix]):-
	length(Board_matrix, Size),
	X =< Size,
	dynamic_sum_row([X,Y], Turns, Board_matrix, HW),
	Xn is X + 1,
	dynamic_sum([Xn,Y], Turns, Board_matrix, Weight_matrix).

dynamic_sum([X,_], _, Board_matrix, []):-
	length(Board_matrix, Size),
	X > Size.

dynamic_sum_row([X,Y], Turns, Board_matrix, [DynamicW|Row_weights]):-
	length(Board_matrix, Size),
	Y =< Size,
	get_row(Board_matrix, [X,_], Row),
	get_col(Board_matrix, [_,Y], Col),
	get_diag1(Board_matrix, [X,Y], Diag1),
	get_diag2(Board_matrix, [X,Y], Diag2),
	sum_list(Row, Row_sum),
	sum_list(Col, Col_sum),
	sum_list(Diag1, Diag1_sum),
	sum_list(Diag2, Diag2_sum),
	max_list([Row_sum, Col_sum, Diag1_sum, Diag2_sum], H),
	get_dynamic_weight(Turns, Size, H, DynamicW),
	Yn is Y + 1,
	dynamic_sum_row([X, Yn], Turns, Board_matrix, Row_weights).

dynamic_sum_row([_,Y], _, Board_matrix, []):-
	length(Board_matrix, Size),
	Y > Size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicates used by the AI heuristics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the discrete weight level of a sum (used in heuristic 2)
% The levels can be changed, but they are fixed during the game
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 1,
	Weight_leveled = 1.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 2,
	Weight_leveled = 5.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 3,
	Weight_leveled = 2.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 4,
	Weight_leveled = 0.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 5,
	Weight_leveled = 7.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 6,
	Weight_leveled = 1.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 7,
	Weight_leveled = 0.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 8,
	Weight_leveled = 10.
get_weight_level(Weight, Weight_leveled):-
	Weight =:= 9,
	Weight_leveled = 1.
get_weight_level(Weight, Weight):-
	Weight < 1.

% Get the dynamic weight of a cell depending on the game turn and size (used in heuristic 3).
% The weight levels change dynamically during the game
% The current setting favours smaller scores at the game start, but favours higher scores as game advances
get_dynamic_weight(Turns, Size, Weight, Dynamic_weight):-
	get_weight_level(Weight, Weight_leveled),
	Weight =< 3,
	Dynamic_weight is (Weight_leveled / ((Turns+1)/Size)).
get_dynamic_weight(Turns, Size, Weight, Dynamic_weight):-
	get_weight_level(Weight, Weight_leveled),
	Weight > 3,
	Dynamic_weight is (Weight_leveled * ((Turns+1)/Size)).	