/*--------------------------------------------------------------------------
Project Title: Implementation of a two player singleplayer game with AI in Prolog - PrologNite
Original Authors: P.Kefalas, I.Stamatopoulou
Editor: Nikolaos Lintas, Computer Science University of Sheffield
--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------
  Initial data for a particular instance of PrologNite game
--------------------------------------------------------------------------*/

white_army([1,2,3,4,5]).
black_army([1,2,3,4,5]).

obstacles(5).

size_of_board(5).

switch_player(b,w).
switch_player(w,b).

/*--------------------------------------------------------------------------
prolognite/0: The main predicate that starts the program.
--------------------------------------------------------------------------*/
prolognite:-
	writelist([nl,'******** WHITE is computer / BLACK is human ********',nl]),
	obstacles(ObstacleNumber),
	writelist([nl,'******** INITIALISATION OBSTACLES ********',nl]),
	initialise_board([],ObstacleNumber,BoardWithObstacles),!,
	pp(BoardWithObstacles),!,
	white_army(WhiteArmy),
	black_army(BlackArmy),
	writelist([nl,'******** START OF DEPLOYMENT PHASE ********',nl]),
	deploy(w, WhiteArmy, BlackArmy,BoardWithObstacles, BoardAfterDeploy),
	writelist([nl,'******** END OF DEPLOYMENT PHASE ********',nl]),
	writelist([nl,'******** START OF DESTRUCTION PHASE ********',nl]),
	pp(BoardAfterDeploy),nl,
	destroy(w,BoardAfterDeploy, FinalBoard),!,
	writelist([nl,'******** END OF GAME ********',nl]),
	announce_winner(FinalBoard).

/*--------------------------------------------------------------------------
initailise_board/3: Generate N obstacles (XPos,YPos,x,x) in Board
--------------------------------------------------------------------------*/

initialise_board(Board,0,Board).
initialise_board(Board,N,FinalBoard):-
	random_pos(Board,XPos,YPos),
	N1 is N-1,
	initialise_board([(XPos,YPos,x,x)|Board],N1,FinalBoard).

/*--------------------------------------------------------------------------
random_pos/3: Generate random XPos YPos in
Board as long as they are not already occupied.
--------------------------------------------------------------------------*/

random_pos(Board,XPos,YPos):-
	repeat,
	random(1,6,XPos),
	random(1,6,YPos),
	not(member((XPos,YPos,_,_),Board)),
	!.

/*--------------------------------------------------------------------------
  deploy/5:
+ Who is playing (w or b)
+ The list of available armies for white
+ The list of available armies for black
+ The current Board
- The resulting board after the deployoment phase

White plays randomly. Black (user) is prompted to input their choices.
--------------------------------------------------------------------------*/

deploy(_, [], [], FinalBoard,FinalBoard):-!.

deploy(w, WhiteArmy, BlackArmy, Board, BoardAfterDeploy):-
	writelist(['******** WHITE DEPLOYS ARMY ********',nl]),
	random_pos(Board, X,Y),
	random_member(N,WhiteArmy),
	select(N,WhiteArmy,NewWhiteArmy),
	pp([(X,Y,w,N)|Board]),
	writelist(['******** WHITE CHOOSES: ',N, ' in position ', (X,Y),nl,nl]),
	deploy(b, NewWhiteArmy, BlackArmy, [(X,Y,w,N)|Board], BoardAfterDeploy).

%%%%% EXERCISE 2: INSERT YOUR CODE HERE

%% All references of white and black have been reversed
deploy(b, WhiteArmy, BlackArmy, Board, BoardAfterDeploy):-
	writelist(['******** BLACK DEPLOYS ARMY ********',nl]),
	%% the line below is the only change needed for the deploy to be succesful,
	%% which takes input from the user to specify army (X, Y, b, N) and board
	%% position N
	user_input(BlackArmy, Board, (X, Y, b, N)),
	select(N,BlackArmy,NewBlackArmy),
	pp([(X,Y,b,N)|Board]),
	writelist(['******** BLACK CHOOSES: ',N, ' in position ', (X,Y),nl,nl]),
	deploy(w, WhiteArmy, NewBlackArmy, [(X,Y,b,N)|Board], BoardAfterDeploy).

%%%%% EXERCISE 2: END OF CODE HERE
/*--------------------------------------------------------------------------
  user_input/3:
  User inputs available (free) position and available army.
--------------------------------------------------------------------------*/

user_input(Army, Board, (X,Y,b,N)):-
	input_army(N,Army),
	input_position(X,Y,Board),!.

input_position(X,Y,Board):-
	repeat,
	writelist(['Select an available position (X,Y): ']),
	read((X,Y)),
	(
		(
			not(member((X,Y,_,_),Board)),
			X > 0,
			X < 6,
			Y > 0,
			Y < 6
		)->
		true;
		(writelist(['Position not available!!!',nl]),
		fail)
	).

input_army(N,Army):-
	repeat,
	writelist(['Select an Army from ', Army,' : ']),
	read(N),
	(member(N,Army)->
		true;
		(writelist(['Army not available!!!',nl]),
		fail)
	).



/*--------------------------------------------------------------------------
  destroy/3:
+ Who is playing (w or b)
+ The current Board
- The resulting board after the game is over (end of destruction phase)

White plays in random. Black requests the input from the user.
--------------------------------------------------------------------------*/

destroy(_, Board,Board):-
	threats_obstacles(w, Board, []),
	threats_enemies(w,Board,[]),
	threats_obstacles(b, Board, []),
	threats_enemies(b,Board,[]),
	!.

%%%%% EXERCISE 3: INSERT YOUR CODE HERE

%% All refereneces of white and black have been reversed
destroy(w, Board,FinalBoard):-
	writelist(['******** WHITE DESTROYS ********',nl]),
	threats_obstacles(w, Board, ThreatsObstacles),
	threats_enemies(w, Board, ThreatsPlayers),
	append(ThreatsObstacles, ThreatsPlayers, AllThreats),
	(AllThreats = [] ->
		(
			writelist([nl,'******** WHITE NOTHING TO DESTROY ********',nl,nl]),
			destroy(b,Board,FinalBoard)
		)
		;
		(
			%% Changed from user_input to random_member because it is now the
			%% computer playing and it is required that it picks a random
			%% member non-deterministically.
			random_member((X,Y,P,V)-by-_,AllThreats),
			writelist(['******** WHITE SELECTS to DESTROY: ', (X,Y,P,V),nl]),
		 	select((X,Y,P,V),Board, NewBoard),
			pp(NewBoard),
			destroy(b,NewBoard,FinalBoard)
		)
	).

%%%%% EXERCISE 3: END OF CODE HERE
destroy(b, Board,FinalBoard):-
	writelist(['******** BLACK DESTROYS ********',nl]),
	threats_obstacles(b, Board, ThreatsObstacles),
	threats_enemies(b,Board,ThreatsPlayers),
	append(ThreatsObstacles, ThreatsPlayers, AllThreats),
	(AllThreats = [] ->
		(writelist([nl,'******** BLACK NOTHING TO DESTROY ********',nl,nl]),
		destroy(w,Board,FinalBoard))
		;
		(user_choice(AllThreats,(X,Y,P,V)-by-_),
		writelist(['******** BLACK SELECTS to DESTROY: ', (X,Y,P,V),nl]),
	 	select((X,Y,P,V),Board, NewBoard),
		pp(NewBoard),
		destroy(w,NewBoard,FinalBoard))
	).


user_choice(AllThreats,(X,Y,P,V)-by-_):-
	pp_options(1,AllThreats),
	repeat,
	writelist(['Select what to destroy (number in options):']),
	read(C),
	(nth1(C,AllThreats,(X,Y,P,V)-by-_) ->
		true;
		(writelist([nl,'Such option does not exist: ', nl]),
		fail)
	).



/*--------------------------------------------------------------------------
threats_obstacles/3:

A Player threatens to destroy obstacles on the Board, to which
there is a clear horizontal or vertical shot.
--------------------------------------------------------------------------*/

threats_obstacles(Player, Board, Threats):-
	findall(Obstacle-by-ByPlayer,
			(
			member(Obstacle,Board),
			can_shoot(Player,Obstacle, Board, ByPlayer)
			),
		Threats).

can_shoot(Player,(XPosObstacle,YPosObstacle,x,x),Board,(XPosPlayer,YPosPlayer,Player,N)):-
	member((XPosPlayer,YPosPlayer,Player,N),Board),
	member(Direction,[up,down,left,right]),
	nothing_inbetween(Direction,(XPosObstacle,YPosObstacle), (XPosPlayer,YPosPlayer),Board).



/*--------------------------------------------------------------------------
nothing_inbetween/4:
There is no army or other obstacle between the Player and the threatened
obstacle in any Direction
--------------------------------------------------------------------------*/

nothing_inbetween(Direction,(XPos,YPos), (ObstacleXPos,ObstacleYPos),_):-
	nextpos(Direction,XPos,YPos, ObstacleXPos,ObstacleYPos),!.

nothing_inbetween(Direction,(XPos,YPos), (ObstacleXPos,ObstacleYPos),Board):-
	nextpos(Direction,XPos,YPos,NextImmediateX,NextImmediateY),	not(member((NextImmediateX,NextImmediateY,_,_),Board)),
	nothing_inbetween(Direction,(NextImmediateX,NextImmediateY), (ObstacleXPos,ObstacleYPos),Board).


/*--------------------------------------------------------------------------
threats_enemies/3:

A Player threatens a number of enemies to which there is a clear horizontal
or vertical shot provided the Player's sum of armies is bigger.
--------------------------------------------------------------------------*/

%%%%% QUESTION 1: THIS IS WHERE THE mystery_predicate IS DEFINED AND USED

threats_enemies(Player,Board,Threats):-
	switch_player(Player,OtherPlayer),
	findall((X,Y,OtherPlayer,N)-by-Enemies,
			(
			 member((X,Y,OtherPlayer,N),Board),
			 search_enemies((X,Y,OtherPlayer,N), Player, Board, Enemies),
			 outnumber(Enemies,N)
			 ),
		Threats).

search_enemies((X,Y,OtherPlayer,N), Player, Board, Enemies):-
	findall(Enemy,
		 	(
			member(Direction,[left,right,up,down]),
			mystery_predicate(Direction,(X,Y,OtherPlayer,N), Player, Board, Enemy)
			),
		Enemies).

mystery_predicate(Direction,(XPos,YPos,_,_),OtherPlayer, Board, (NextPosX,NextPosY,OtherPlayer,N)):-
	nextpos(Direction, XPos, YPos, NextPosX, NextPosY),
	member((NextPosX,NextPosY,OtherPlayer,N),Board),!.

mystery_predicate(Direction,(XPos,YPos,Player,_),OtherPlayer, Board, N):-
	nextpos(Direction, XPos, YPos, NextPosX, NextPosY),
	not(member((NextPosX,NextPosY,x,x),Board)),
	not(member((NextPosX,NextPosY,Player,_),Board)),
	mystery_predicate(Direction,(NextPosX,NextPosY,Player,_),OtherPlayer, Board,N).

/*--------------------------------------------------------------------------
 nextpos/5:
 According to the direction (left, right, up, down), it finds the neighbouring
 position on the board in the given direction.
--------------------------------------------------------------------------*/
nextpos(left, XPos, YPos, NextPosX, YPos):-
	NextPosX is XPos-1,
	NextPosX > 0.
nextpos(right, XPos, YPos, NextPosX, YPos):-
	NextPosX is XPos+1,
	NextPosX < 6.
nextpos(down, XPos, YPos, XPos, NextPosY):-
	NextPosY is YPos-1,
	NextPosY > 0.
nextpos(up, XPos, YPos, XPos, NextPosY):-
	NextPosY is YPos+1,
	NextPosY < 6.


%%%%% EXERCISE 5: INSERT YOUR CODE HERE

%% An algorithm was devised for this  part which is explained in the report in
%% detail.

%% In all instances both Next positions change, which means arguments have to
%% be changed accordingly as well to NextXPos, NextPosY.
nextpos(down_right, XPos, YPos, NextXPos, NextPosY):-
	%% both Nexts have to increment or decrement according to the algorithm, in
	%% all instances of this predicate.
	NextPosY is YPos - 1,
	NextXPos is XPos + 1,
	%% and whenever either operation occurs we must ensure that we are within
	%% the bounds of the board for every instace of this predicate.
	NextPosY > 0,
	NextXPos < 6.

nextpos(up_right, XPos, YPos, NextXPos, NextPosY):-
	NextPosY is YPos + 1,
	NextXPos is XPos + 1,
	NextPosY < 6,
	NextXPos < 6.

nextpos(down_left, XPos, YPos, NextXPos, NextPosY):-
	NextPosY is YPos - 1,
	NextXPos is XPos - 1,
	NextPosY > 0,
	NextXPos > 0.

nextpos(up_left, XPos, YPos, NextXPos, NextPosY):-
	NextPosY is YPos + 1,
	NextXPos is XPos - 1,
	NextPosY < 6,
	NextXPos > 0.

/*--------------------------------------------------------------------------
outnumber/2:
+ the list of armies to be compared
+ the specific army strength to be compared

Given a list of positions that contain armies and the value of one
opponent's army, the predicate succeeds if the list of armies outnumbers
the opponents army.
--------------------------------------------------------------------------*/

%%%%% EXERCISE 4: INSERT YOUR CODE HERE

%% this predicate takes a ListOfArmies and an ArmyStrength
outnumber(ListOfArmies, ArmyStrength):-
	%% then it uses the auxiliary count predicate to get the sum of the
	%% ListOfArmies strength
	count(_,ListOfArmies,SumOfStrength),
	%% lastly, it compares if that SumOfStrength is greater than this specific
	%% soldiers strength, if so it return true.
	SumOfStrength > ArmyStrength.

%%%%% EXERCISE 4: END OF CODE HERE
/*--------------------------------------------------------------------------
pp/2:Initial number and List
it prints out numbered items of the list line-by-line starting from imitial number
--------------------------------------------------------------------------*/

pp_options(_,[]).
pp_options(N,[H|T]):-
	writelist([N,'. ', H,nl]),
	N1 is N+1,
	pp_options(N1,T).

/*--------------------------------------------------------------------------
pp/1:+Board
it prints out the board after each move. It works only for a 5x5 board
--------------------------------------------------------------------------*/

pp(Board):-
%	cls,
	nl,write('--|----+----+----+----+----|'),
	member(Y,[5,4,3,2,1]),
	nl, write(Y), write(' |'),
	member(X,[1,2,3,4,5]),
	display_square(Board,X,Y),
	fail.
pp(_):-
	!,
	nl,write('  | 1  | 2  | 3  | 4  | 5  |'),!,nl,
	nl,!.

% To diplay -- as empty squares while all others normally

display_square(Board,5,Y):-
	not(member((5,Y,_,_),Board)),!,
	writelist(['    |']),!,
	nl,write('--|----+----+----+----+----|'),!.
display_square(Board,5,Y):-
	member((5,Y,W,C),Board),!,
	string_concat(W,C,S),
	writelist([' ',S,' |']),!,
	nl,write('--|----+----+----+----+----|'),!.
display_square(Board,X,Y):-
	X\=5,
	not(member((X,Y,_,_),Board)),!,
	writelist(['    |']),!.
display_square(Board,X,Y):-!,
	X\=5,
	member((X,Y,W,C),Board),!,
	string_concat(W,C,S),
	writelist([' ',S,' |']),!.

/*------------------------------------------------------------------------
announce_winner/1: +List
Given a list Board, it counts the sum of armies and finds the difference.
Then, it announces the winner or the draw.
------------------------------------------------------------------------*/

announce_winner(Board):-
	count(w,Board,WhiteSum),
	count(b,Board,BlackSum),
	compare(WhiteSum,BlackSum,Winner, Difference),
	writelist(['The winner is ', Winner, ' by ', Difference,nl]),!.

count(_,[],0).
count(Player,[(_,_,Player,N)|Rest], Sum):-
	count(Player,Rest,RestSum),!,
	Sum is RestSum+N.
count(Player,[_|Rest], Sum):-
	count(Player,Rest,Sum).

compare(N,N,'no one. It is a draw',0).
compare(WS,BS,w,D):- WS>BS, D is WS-BS,!.
compare(WS,BS,b,D):- WS<BS, D is BS-WS,!.

/*------------------------------------------------------------------------
writelist/1: +List
Prints all the elements of the input list
------------------------------------------------------------------------*/
writelist([]):-!.
writelist([nl|R]):-
	nl,!,
	writelist(R).
writelist([H|T]):-
	write(H),!,
	writelist(T).

/*------------------------------------------------------------------------
cls/0: clears the screen
------------------------------------------------------------------------*/
cls :-  put(27), put("["), put("2"), put("J").


/*------------------------------------------------------------------------
  SOME TEST BOARDS AFTER FULL DEPLOYMENT
------------------------------------------------------------------------*/

board_test1([ (4,5,b,4), (1,3,w,5), (5,2,b,2), (4,2,w,3), (1,1,b,1), (1,5,w,1), (3,5,b,3), (3,3,w,4), (5,4,b,5), (2,2,w,2), (1,4,x,x), (3,4,x,x), (1,2,x,x), (2,3,x,x), (4,3,x,x)]).
board_test2([ (4,5,b,2), (1,2,w,3), (5,5,b,3), (2,1,w,5), (5,1,b,4), (3,5,w,1), (1,4,b,1), (2,3,w,4), (4,2,b,5), (2,4,w,2), (4,3,x,x), (5,3,x,x), (4,1,x,x), (3,3,x,x), (4,4,x,x)]).
board_test3([ (5,1,b,3), (1,1,w,1), (4,3,b,1), (5,3,w,5), (2,1,b,4), (3,4,w,2), (5,2,b,2), (2,2,w,3), (3,1,b,5), (3,2,w,4), (4,4,x,x), (5,5,x,x), (2,5,x,x), (4,5,x,x), (1,3,x,x)]).
board_test4([ (4,2,b,2), (1,1,w,4), (5,4,b,1), (1,4,w,3), (2,3,b,3), (2,4,w,5), (3,3,b,5), (4,1,w,2), (4,3,b,4), (5,1,w,1), (1,5,x,x), (1,2,x,x), (2,2,x,x), (1,3,x,x), (2,5,x,x)]).
