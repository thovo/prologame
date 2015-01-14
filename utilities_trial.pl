%get_row(Matrix, [X|_], Row):- %Note that the cell is [X,Y]
%nth0(X, Matrix, Row).

get_row(Matrix, [X|_], Row):- %Note that the cell is [X,Y] -- Working FINE
nth1(X, Matrix, Row).

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

%diag2_start([Matrix_len,Matrix_len],[Matrix_len,Matrix_len],Matrix_len):- !.
diag2_start([Xn,Y],[Xn,Y],Matrix_len):- 
Y =:= Matrix_len,
!.
diag2_start([1,Yn],[1,Yn],Matrix_len):- 
%Yy > Matrix_len,
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
%NewX < Matrix_len,
%NewY < Matrix_len,
get_diag2_w(Matrix, [NewX,NewY], Diag1).

get_diag2(Matrix, [X,Y], Diag1):-
%Get the start Xn,Yn
length(Matrix, Matrix_len),
diag2_start([X,Y],[Xn,Yn],Matrix_len),
%Get the column Yn
get_diag2_w(Matrix, [Xn,Yn], Diag1).

%take(1,[H|_],H):- !.
%take(N,[_|T],X):- 
%N1 is N-1, 
%take(N1,T,X).