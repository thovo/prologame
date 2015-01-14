%%%%%%%%%%%%%%%%%%%%%%%%%
% 3-6-9 Game Predicates %
%%%%%%%%%%%%%%%%%%%%%%%%%
:- include('utilities.pl').
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
	
	write('Computer: Here is my move: '),
	write(AI_move),
	
	update_board(Board_matrix, AI_move, New_board),
	draw_board(New_board),
	% Board_matrix is New_board,
	
	% update_score(New_board, AI_move, New_AI_score),
	% Total_Computer_score is Computer_score + New_AI_score,
	
	show_score(Player_score, Total_Computer_score),
	Next_turn is Turns + 1,
	gameover(Size, Next_turn),
	
	% User input part
	% ......some code....... %
	write('Enter your move as a list of [X,Y]. (Don\'t forget the period!)\n'),
	write('Make your move: '),
	read(User_move),
	
	check_user_move(New_board, User_move, Valid_move),
	
	update_board(New_board, Valid_move, New_board2),
	draw_board(New_board2),
	% Board_matrix is New_board,
	
	% update_score(P_New_board, User_move, New_Player_score),
	% Total_Player_score is Player_score + New_Player_score,
	
	show_score(Total_Player_score, Total_Computer_score),
	
	% Check gameover condition
	Next_turn2 is Next_turn + 1,
	gameover(Size, Next_turn2),
	play(Size, Heuristic, New_board2, Computer_score, Human_score, Next_turn2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating the naive sum heuristic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
naive_sum(Board_matrix, Weight_matrix_fixed):-
	naive_sum([1,1], Board_matrix, Weight_matrix),
	remove_invalid(Board_matrix, Weight_matrix, Weight_matrix_fixed).

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

naive_sum_row([X,Y], Board_matrix, []):-
	length(Board_matrix, Size),
	Y > Size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%