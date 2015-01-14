%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilities and Stub predicates %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Gameover predicate:
gameover(Size, Turns):-
	Turns < Size*Size.
	% fail.	
gameover(Size, Turns):-
	Turns =:= Size*Size,
	write('Game Over!'),
	show_score(Human_score, Computer_score),
	fail.
	
% Select AI move predicate
select_move(Board_matrix, AI_move, Heuristic):-
	Heuristic =:= 1,
	naive_sum(Board_matrix, Weight_matrix),
	get_mat_max(Weight_matrix, Max),!,
	elem_index(Weight_matrix, Max, Row, Col), !,
	Row_fixed is Row + 1,
	Col_fixed is Col + 1,
	AI_move = [Row_fixed,Col_fixed].
select_move(Board_matrix, AI_move, Heuristic):-
	Heuristic =:= 2,
	leveled_sum(Board_matrix, Weight_matrix),
	get_mat_max(Weight_matrix, AI_move).
select_move(Board_matrix, AI_move, Heuristic):-
	Heuristic =:= 3,
	dynamic_leveled_sum(Board_matrix, Weight_matrix),
	get_mat_max(Weight_matrix, AI_move).
	
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
	
% Repeat user input until valid move and return the valid one
check_user_move(Board_matrix, [X,Y], [X,Y]):-
	check_valid_move(Board_matrix, [X,Y]), !.
check_user_move(Board_matrix, [X,Y], User_move):-
	repeat,
	write('Please enter a valid move: '),
	read(User_move),
	(check_valid_move(Board_matrix, User_move), ! ; fail).

% Update Board predicate (Put stone in the selected position)
update_board(Board_matrix, [X,Y], New_board):-
	X_fix is X - 1, % Because input starts from 1, and list index start from 0
	Y_fix is Y - 1, % Because input starts from 1, and list index start from 0
	nth0(X_fix, Board_matrix, Row),
	replace(Y_fix, 1, Row, New_Row),
	replace(X_fix, New_Row, Board_matrix, New_board).
	
% Update score predicate
update_score(Board_matrix, Move, Score):-
	% Getting the row, col, diagonals which a point belongs to
	get_row(Board_matrix, Move, Row),
	get_col(Board_matrix, Move, Col),
	get_diag1(Board_matrix, Move, Diag1),
	get_diag2(Board_matrix, Move, Diag2),
	% Score each of them
	scoring(Row, Row_score),
	scoring(Col, Col_score),
	scoring(Diag1, Diag1_score),
	scoring(Diag2, Diag2_score),
	% Total the score of the move
	Score is Row_score + Col_score + Diag1_score + Diag2_score.
	% Don't forget to update the Global Variable (Computer_score or Human_score)
	% by adding the Score variable to them.
	

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

% show_score stub predicate
show_score(Player_score, Computer_score).

% Replace the Index of a List, by Element, and return the new list
replace(_, _, [], []).
replace(Index, Element, [H|List], [H|NList]):-
	Index > 0,
	NIndex is Index - 1,
	replace(NIndex, Element, List, NList).
replace(Index, Element, [H|List], [Element|NList]):-
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
	write('\n-------------\n').
draw_board([H|Board_matrix]):-
	write('\n-------------\n'),
	write(H),
	draw_board(Board_matrix).

	
% Remove invalid moves from Weight Matrix, in order to avoid making invalid moves
remove_invalid([], [], []).
remove_invalid([H|Board_matrix], [HW|Weight_matrix], [HWF|Weight_matrix_fixed]):-
	remove_invalid_row(H, HW, HWF),
	remove_invalid(Board_matrix, Weight_matrix, Weight_matrix_fixed).
	
remove_invalid_row([], [], []).
remove_invalid_row([1|Row], [X|RWeights], [-1|RWeightsFixed]):-
	remove_invalid_row(Row, RWeights, RWeightsFixed).
remove_invalid_row([H|Row], [X|RWeights], [X|RWeightsFixed]):-
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
%	Note:
%		- If this works, the get_diag2 should be something similar.

% Get the backward diagonal of a given cell as a list
diag1_start([1,1],[1,1],_):- !.
diag1_start([Xn,1],[Xn,1],_):- 
!.
diag1_start([1,Yn],[1,Yn],_):- 
!.

diag1_start([X,Y],[Xx,Yy],Matrix_len):-
X > 1,
Y > 1,
Xn is X-1,
Yn is Y-1,
diag1_start([Xn,Yn],[Xx,Yy],Matrix_len).

get_diag1_w(Matrix,[X,Y], []):- 
length(Matrix, Matrix_len),
X > Matrix_len,
!. 

get_diag1_w(Matrix,[X,Y], []):- 
length(Matrix, Matrix_len),
Y > Matrix_len,
!. 

get_diag1_w(Matrix, [X,Y], [Req_element|Diag1]):-
%Get the needed column
get_col(Matrix, [X,Y], Col), 
%Get the element Xn from this column (Z)
nth1(X, Col, Req_element), %Get the needed column
%Increase the X and Y indices
NewX is X+1,
NewY is Y+1,
length(Matrix, Matrix_len),
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
%	Note:
%		- If this works, the get_diag2 should be something similar.

% Get the forward diagonal of a given cell as a list
diag2_start([Xn,Y],[Xn,Y],Matrix_len):- 
Y =:= Matrix_len,
!.
diag2_start([1,Yn],[1,Yn],Matrix_len):- 
!.

diag2_start([X,Y],[Xx,Yy],Matrix_len):-
X > 1,
Y < Matrix_len,
Xn is X-1,
Yn is Y+1,
diag2_start([Xn,Yn],[Xx,Yy],Matrix_len).

get_diag2_w(Matrix,[X,Y], []):- 
length(Matrix, Matrix_len),
X > Matrix_len,
!. 

get_diag2_w(Matrix,[X,Y], []):- 
length(Matrix, Matrix_len),
Y < 1,
!. 

get_diag2_w(Matrix, [X,Y], [Req_element|Diag1]):-
%Get the needed column
get_col(Matrix, [X,Y], Col), 
%Get the element Xn from this column (Z)
nth1(X, Col, Req_element), %Get the needed column
%Adjust the X and Y indices
NewX is X+1,
NewY is Y-1,
length(Matrix, Matrix_len),
get_diag2_w(Matrix, [NewX,NewY], Diag1).

get_diag2(Matrix, [X,Y], Diag1):-
%Get the start Xn,Yn
length(Matrix, Matrix_len),
diag2_start([X,Y],[Xn,Yn],Matrix_len),
%Get the column Yn
get_diag2_w(Matrix, [Xn,Yn], Diag1).