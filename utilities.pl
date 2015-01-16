%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilities and Stub predicates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
% Check move validity
check_valid_move(Board_matrix, [X,Y]):-
	length(Board_matrix, N),
	X =< N,
	Y =< N,
	X_fix is X - 1, % Because input starts from 1, and list index start from 0
	Y_fix is Y - 1, % Because input starts from 1, and list index start from 0
	nth0(X_fix, Board_matrix, Row),
	nth0(Y_fix, Row, Element),
	Element == 0.
	

% Create 369 game board predicate
create_board(Size, Board_matrix):-
	create_board(Size, Size, Board_matrix).
create_board(Size,1,[Board_matrix]):-
	create_list_zeros(Size, Board_matrix), !.
create_board(Size, Limit, [H|Board_matrix]):-
	Limit > 1,
	create_list_zeros(Size, H),
	NLimit is Limit - 1,
	create_board(Size, NLimit, Board_matrix). 
% Predicate to create list of zeros
create_list_zeros(1, [0]):- !.
create_list_zeros(Size, [0|List]):-
	Size > 1,
	NSize is Size - 1,
	create_list_zeros(NSize, List).

% Show the player and AI score in neat format
show_score(Player_score, Computer_score):-
	write('\n-----------------------------------------'),
	write('\n|\t\t\t\t\t|\n'),
	write('|   Player Score = '),
	write(Player_score),
	write(' | AI Score = '),
	write(Computer_score),
	write('\t|'),
	write('\n|\t\t\t\t\t|'),
	write('\n-----------------------------------------\n').

% Replace the Index of a List, by Element, and return the new list
replace(_, _, [], []).
replace(Index, Element, [H|List], [H|NList]):-
	Index > 0,
	NIndex is Index - 1,
	replace(NIndex, Element, List, NList).
replace(Index, Element, [_|List], [Element|NList]):-
	Index == 0,
	NIndex is Index - 1,
	replace(NIndex, _, List, NList).
replace(Index, _, [H|List], [H|NList]):-
	Index < 0,
	replace(Index, _, List, NList).
	
% Get maximum element from a matrix
get_mat_max([], 0).
get_mat_max([H|Matrix], Max):-
	get_mat_max(Matrix, Max),
	max_list(H, Max_H),
	Max_H < Max.
get_mat_max([H|Matrix], Max_H):-
	get_mat_max(Matrix, Max),
	max_list(H, Max_H),
	Max_H >= Max.
	
elem_index(Matrix, Value, Row, Col):-
  nth0(Row, Matrix, MatrixRow),
  nth0(Col, MatrixRow, Value).
	
% Draw_board predicate
draw_board([]):-
	write('\n\t\t===============================\n').
draw_board([H|Board_matrix]):-
	write('\n\t\t| '),
	draw_board_row(H),
	draw_board(Board_matrix).
draw_board_row([]).
draw_board_row([E|Row]):-
	write(E),
	write(' | '),
	draw_board_row(Row).
	
% Remove invalid moves from Weight Matrix, in order to avoid making invalid moves
% (Invalid moves are the moves already having stones)
remove_invalid([], [], []).
remove_invalid([H|Board_matrix], [HW|Weight_matrix], [HWF|Weight_matrix_fixed]):-
	remove_invalid_row(H, HW, HWF),
	remove_invalid(Board_matrix, Weight_matrix, Weight_matrix_fixed).
% Remove invalid moves from one row (Invalid moves are the ones already having stones)
remove_invalid_row([], [], []).
remove_invalid_row([1|Row], [_|RWeights], [-1|RWeightsFixed]):-
	remove_invalid_row(Row, RWeights, RWeightsFixed).
remove_invalid_row([0|Row], [X|RWeights], [X|RWeightsFixed]):-
	remove_invalid_row(Row, RWeights, RWeightsFixed).

% Get the row of a given cell as a list
get_row(Matrix, [X|_], Row):- %Note that the cell is [X,Y] -- Working FINE
nth1(X, Matrix, Row).

% Get the column of a given cell as a list
get_col(Matrix, [_|Y], Col):- %Note that the cell is [X,Y] %Operation: return an element from each row
nth0(0, Y, Req_col), %Get the needed column
maplist(nth1(Req_col), Matrix, Col).

%For the get_diag1 function of the (X,Y) cell:
% 	Once:
%		- Substract from both X,Y -1 till one of them reaches ZERO --> (Xn,Yn)
%		- This is the start point for this diagonal (Xn,Yn)
%	Then:
%		- Get the column Yn
%		- Get the element Xn from this column (Z)
%		- Increase Xn and Yn by +1.
%		- Make sure that Xn and Yn doesn't exceed the dimensions of the matrix (N x N).
%		- Concatenate the "Z" into one list.

% Get the backward diagonal of a given cell as a list
diag1_start([1,1],[1,1],_):- !.
diag1_start([Xn,1],[Xn,1],_):- !.
diag1_start([1,Yn],[1,Yn],_):- !.

diag1_start([X,Y],[Xx,Yy],Matrix_len):-
X > 1,
Y > 1,
Xn is X-1,
Yn is Y-1,
diag1_start([Xn,Yn],[Xx,Yy],Matrix_len).

get_diag1_w(Matrix,[X,_], []):- 
length(Matrix, Matrix_len),
X > Matrix_len, !. 

get_diag1_w(Matrix,[_,Y], []):- 
length(Matrix, Matrix_len),
Y > Matrix_len, !. 

get_diag1_w(Matrix, [X,Y], [Req_element|Diag1]):-
%Get the needed column
get_col(Matrix, [X,Y], Col), 
%Get the element Xn from this column (Z)
nth1(X, Col, Req_element), %Get the needed column
%Increase the X and Y indices
NewX is X+1,
NewY is Y+1,
get_diag1_w(Matrix, [NewX,NewY], Diag1).

get_diag1(Matrix, [X,Y], Diag1):-
%Get the start Xn,Yn
length(Matrix, Matrix_len),
diag1_start([X,Y],[Xn,Yn],Matrix_len),
%Get the column Yn
get_diag1_w(Matrix, [Xn,Yn], Diag1).

%For the get_diag2 function of the (X,Y) cell:
% 	Once:
%		- Substract from both X,Y +1 till one of them reaches Matrix_len-1 --> (Xn,Yn)
%		- This is the start point for this diagonal (Xn,Yn)
%	Then:
%		- Get the column Yn
%		- Get the element Xn from this column (Z)
%		- Increase Xn and Yn by -1.
%		- Make sure that Xn and Yn doesn't exceed the dimensions of the matrix (N x N).
%		- Concatenate the "Z" into one list.

% Get the forward diagonal of a given cell as a list
diag2_start([Xn,Y],[Xn,Y],Matrix_len):- 
Y =:= Matrix_len, !.
diag2_start([1,Yn],[1,Yn],_):- !.

diag2_start([X,Y],[Xx,Yy],Matrix_len):-
X > 1,
Y < Matrix_len,
Xn is X-1,
Yn is Y+1,
diag2_start([Xn,Yn],[Xx,Yy],Matrix_len).

get_diag2_w(Matrix,[X,_], []):- 
length(Matrix, Matrix_len),
X > Matrix_len, !. 

get_diag2_w(_,[_,Y], []):- 
Y < 1, !. 

get_diag2_w(Matrix, [X,Y], [Req_element|Diag1]):-
%Get the needed column
get_col(Matrix, [X,Y], Col), 
%Get the element Xn from this column (Z)
nth1(X, Col, Req_element), %Get the needed column
%Adjust the X and Y indices
NewX is X+1,
NewY is Y-1,
get_diag2_w(Matrix, [NewX,NewY], Diag1).

get_diag2(Matrix, [X,Y], Diag1):-
%Get the start Xn,Yn
length(Matrix, Matrix_len),
diag2_start([X,Y],[Xn,Yn],Matrix_len),
%Get the column Yn
get_diag2_w(Matrix, [Xn,Yn], Diag1).

% Scoring function to score a certain row, col, or diagonal
% Give (Score = 1, for 3 stones) (Score = 2, for 6 stones) (Score = 1, for 9 stones)
scoring(Dim, 0):-
	sum_list(Dim, Sum),
	Sum =\= 3,
	Sum =\= 6,
	Sum =\= 9, !.
scoring(Dim, Dim_score):-
	sum_list(Dim, Sum),
	Sum =:= 3, !,
	Dim_score = 1.
scoring(Dim, Dim_score):-
	sum_list(Dim, Sum),
	Sum =:= 6, !,
	Dim_score = 2.
scoring(Dim, Dim_score):-
	sum_list(Dim, Sum),
	Sum =:= 9, !,
	Dim_score = 3.