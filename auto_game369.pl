%%%%%%%%%%%%%%%%%%%%%%%%%
% 3-6-9 Game Predicates %
%%%%%%%%%%%%%%%%%%%%%%%%%
:- include('utilities.pl').
:- include('AI_player.pl').
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Game Predicate:
auto_play369(Size, Heuristic1, Heuristic2):-
	% Global Variables:
	Computer_score = 0,
	Player_score = 0,
	Turns = 0,
	% Main Game Loop	
	create_board(Size, Board_matrix),
	draw_board(Board_matrix),
	play(Size, Heuristic1, Heuristic2, Board_matrix, Computer_score, Player_score, Turns).

% Recursive play predicate that updates global variables and implements
% one game turn procedure
play(Size, Heuristic1, Heuristic2, Board_matrix, Computer_score, Player_score, Turns):-
	% Always begin with AI player.
	select_move(Board_matrix, AI_move, 1, Turns),
	
	% Display AI move
	write('AI 1: Here is my move: '),
	write(AI_move),
	
	% Update the game board with AI move, and draw the updated one
	update_board(Board_matrix, AI_move, New_board),
	draw_board(New_board),
	
	% Update the AI score, and add to the global AI score variable
	update_score(New_board, AI_move, New_AI_score),
	Total_AI_score is Computer_score + New_AI_score,
	
	% Display both Player and AI new scores
	show_score(Player_score, Total_AI_score),
	% Next turn for human player to play
	Next_turn is Turns + 1,
	% Check if this turn is the last turn
	gameover(Size, Next_turn),
	
	% Get human player move
	select_move(New_board, AI_move2, 3, Next_turn),
	
	% Display AI move
	write('AI 2: Here is my move: '),
	write(AI_move2),
	
	% Update the game board with Player move, and draw the updated one
	update_board(New_board, AI_move2, New_board2),
	draw_board(New_board2),
	
	% Update the Player score, and add to the global Player score variable
	update_score(New_board2, AI_move2, New_Player_score),
	Total_Player_score is Player_score + New_Player_score,
	
	% Display both Player and AI new scores
	show_score(Total_Player_score, Total_AI_score),
	
	% write('\nEnter any character to continue...\n'),
	% read(C),
	
	% Next turn for AI to play
	Next_turn2 is Next_turn + 1,
	% Check if this turn is the last turn
	gameover(Size, Next_turn2),
	
	% Call the new game round with the updated global variables
	play(Size, Heuristic1, Heuristic2, New_board2, Total_AI_score, Total_Player_score, Next_turn2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicates used by the game loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Gameover predicate:
gameover(Size, Turns):-
	Turns < Size*Size.
gameover(Size, Turns):-
	Turns =:= Size*Size,
	write('\t\tGame Over!'),
	fail.

% Select AI move predicate
select_move(Board_matrix, AI_move, Heuristic, _):-
	Heuristic =:= 1,
	naive_sum(Board_matrix, Weight_matrix),
	get_mat_max(Weight_matrix, Max), !, 
	elem_index(Weight_matrix, Max, Row, Col), !,
	Row_fixed is Row + 1,
	Col_fixed is Col + 1,
	AI_move = [Row_fixed,Col_fixed].
select_move(Board_matrix, AI_move, Heuristic, _):-
	Heuristic =:= 2,
	leveled_sum(Board_matrix, Weight_matrix),
	get_mat_max(Weight_matrix, Max), !, 
	elem_index(Weight_matrix, Max, Row, Col), !,
	Row_fixed is Row + 1,
	Col_fixed is Col + 1,
	AI_move = [Row_fixed,Col_fixed].
select_move(Board_matrix, AI_move, Heuristic, Turns):-
	Heuristic =:= 3,
	dynamic_sum(Turns, Board_matrix, Weight_matrix),
	get_mat_max(Weight_matrix, Max), !, 
	elem_index(Weight_matrix, Max, Row, Col), !,
	Row_fixed is Row + 1,
	Col_fixed is Col + 1,
	AI_move = [Row_fixed,Col_fixed].
	
% Repeat user input until valid move and return the valid one
check_user_move(Board_matrix, [X,Y], [X,Y]):-
	check_valid_move(Board_matrix, [X,Y]), !.
check_user_move(Board_matrix, _, User_move):-
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