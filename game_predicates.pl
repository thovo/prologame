%%%%%%%%%%%%%%%%%%%%%%%%%
% 3-6-9 Game Predicates %
%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Game Predicate:
play369(Size, Heuristic):-
	% Global Variables:
	Computer_score = 0,
	Player_score = 0,
	Turns = 0,
	% Main Game Loop
	
	create_board(Size, Board_matrix),
	draw_board(Board_matrix),
	play(Size, Heuristic, Board_matrix, Computer_score, Player_score, Turns).
	
play(Size, Heuristic, Board_matrix, Computer_score, Player_score, Turns):-
	select_move(Board_matrix, AI_move, Heuristic),
	% check_valid_move(Board_matrix, AI_move),
	
	write('Computer: Here is my move: '),
	write(AI_move),
	
	update_board(Board_matrix, AI_move, New_board),
	draw_board(New_board),
	% Board_matrix is New_board,
	
	% update_score(New_board, AI_move, New_AI_score),
	% Total_Computer_score is Computer_score + New_AI_score,
	
	show_score(Player_score, Total_Computer_score),
	Next_turn is Turns + 1,
	
	% User input part
	% ......some code....... %
	write('Make your move: '),
	read(User_move),
	
	check_valid_move(New_board, User_move),
	
	update_board(New_board, User_move, New_board2),
	draw_board(New_board2),
	% Board_matrix is New_board,
	
	% update_score(P_New_board, User_move, New_Player_score),
	% Total_Player_score is Player_score + New_Player_score,
	
	show_score(Total_Player_score, Total_Computer_score),
	
	% Check gameover condition
	Next_turn2 is Next_turn + 1,
	gameover(Size, Next_turn2),
	play(Size, Heuristic, New_board2, Computer_score, Human_score, Next_turn).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
	get_mat_max(Weight_matrix, Max),
	max_index(Weight_matrix, Max, Row, Col),
	AI_move = [Row,Col].
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
	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilities and Stub predicates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
	
max_index(Matrix, Value, Row, Col):-
  nth0(Row, Matrix, MatrixRow),
  nth0(Col, MatrixRow, Value).
	
% Stub draw_board predicate
draw_board([]):-
	write('\n-------------\n').
draw_board([H|Board_matrix]):-
	write('\n-------------\n'),
	write(H),
	draw_board(Board_matrix).
	
get_row([X,_], Board_matrix, Row):-
	X_fix is X - 1,
	nth0(X_fix, Board_matrix, Row).
	
get_col(_, [], []):- !.
get_col([_,Y], [H|Board_matrix], [HC|Col]):-
	Y_fix is Y - 1,
	nth0(Y_fix, H, HC),
	get_col([_,Y], Board_matrix, Col).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating the naive sum heuristic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
naive_sum(Board_matrix, Weight_matrix):-
	naive_sum([1,1], Board_matrix, Weight_matrix).

naive_sum([X,Y], Board_matrix, [HW|Weight_matrix]):-
	length(Board_matrix, Size),
	X =< Size,
	naive_sum_row([X,Y], Board_matrix, HW),
	Xn is X + 1,
	naive_sum([Xn,Y], Board_matrix, Weight_matrix).

naive_sum([X,Y], Board_matrix, []):-
	length(Board_matrix, Size),
	X > Size.

naive_sum_row([X,Y], Board_matrix, [H|Row_weights]):-
	length(Board_matrix, Size),
	Y =< Size,
	get_row([X,_], Board_matrix, Row),
	get_col([_,Y], Board_matrix, Col),
	sum_list(Row, Row_sum),
	sum_list(Col, Col_sum),
	max_list([Row_sum, Col_sum], H),
	Yn is Y + 1,
	naive_sum_row([X, Yn], Board_matrix, Row_weights).

naive_sum_row([X,Y], Board_matrix, []):-
	length(Board_matrix, Size),
	Y > Size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
