%the hueristics approach influenced by the following article:
%https://www.cs.huji.ac.il/~ai/projects/2012/Mancala/

%the total number of seeds, {{default_hole's_seeds}}*{{num_of_holes}}*{{num_of_players}} = 4*6*2 = 48
totalSeedsCount(48).


% calculate the state heuristic by using the earner, weaker and escaper heuristics
moveHeuristic(CurrentBoard,NextBoard,Res):-
     statePlayer(P),P is 2,getCurrentPlayersScore(NextBoard,Res);
     P is 1,getOtherPlayerScore(NextBoard,Res).
%    earnerHeuristic(CurrentBoard,NextBoard,EarnerRes),
%    weakerHeuristic(CurrentBoard,NextBoard,WeakerRes),
%    escaperHeuristic(NextBoard,EscaperRes),
%
%    Res is (*(EarnerRes,1))+(*(WeakerRes,1))+(*(EscaperRes,1)).

% the earner heuristic focus on the current player Lala's seed count (aka player score)
% return the player's player Kala's seeds diff from the previous move.
earnerHeuristic(CurrentBoard,NextBoard,Res):-
    getCurrentPlayersScore(CurrentBoard,CurrentScore),
    getCurrentPlayersScore(NextBoard,NextScore),
    Res is NextScore - CurrentScore.


% the weaker heuristic focus on the current player steeling seeds from the rivel,
% and reducing is seeds amount.
% works by calculating the diff between his prev and current seed count.
weakerHeuristic(CurrentBoard,NextBoard,Res):-
    countOtherPlayerHoleSeeds(CurrentBoard,CurrentCount),
    countOtherPlayerHoleSeeds(NextBoard,NextCountCount),
    Temp is CurrentCount-NextCountCount,
    (Temp>0,Res is Temp;
    Res is 0).


% the escaper heuristic focus reducing the rivel chances of steeling the current player seeds.
% count the river seeds and devided by the total seeds count
escaperHeuristic(Board,Res):-
    countEmptyHoles(Board,0,EmptyBoards),
    Res is -1*EmptyBoards.

countEmptyHoles(_,6,0).
countEmptyHoles([Hole|Board],Index,Res):-
    NewIndex is Index+1,
    countEmptyHoles(Board,NewIndex,Temp),
    (Hole =:= 0, Res is Temp+1;
    Res is Temp).

countOtherPlayerHoleSeeds(Board,Res):-
    Board = [_,_,_,_,_,_,_,H1,H2,H3,H4,H5,H6,_],
    Res is H1+H2+H3+H4+H5+H6.



%the alpha beta algorithm
%entry when depth is bigger than zero
%Depth - is the search tree max depth
%Board - is the current game state (the current move)
%Alpha/Beta - the algoritm's alpha/beta value
%BestMove,Value - the best move and it's value which found by the alphabeta algorithm (the result).
%first alpha beta accures when a player as more than one turn we treat it as a "single move"
%and there for not changing depth,alpha and beta values.
alphabeta(Ancestor,Board, _, _, _, Val, 0,CurrentPlayer) :- % max depth of search recieved
  moveHeuristic(Ancestor, Board,Val),!.

alphabeta(_,Board, Alpha, Beta, GoodPos, Val, Depth,CurrentPlayer) :-
   Depth > 0,
   possibleMoves(Board, PosList), !,
   boundedbest(Board,PosList, Alpha, Beta, GoodPos, Val,Depth,CurrentPlayer).

%if there are no possible moves
alphabeta(Ancestor,Board, _, _, _, Val, Depth,CurrentPlayer) :-
  Depth > 0,
  moveHeuristic(Ancestor, Board, Val).

changePlayer(ChangePlayer,CurrentPlayer,NextPlayer):-
   ChangePlayer is 1,
   Temp is 1-CurrentPlayer,
   NextPlayer is abs(Temp).

boundedbest(Ancestor,[Move | MoveList], Alpha, Beta, GoodPos, GoodVal,Depth,CurrentPlayer):-
   Depth>0,
   %print('player:'),print(CurrentPlayer),nl,
   executeMove( Move, Ancestor, NewBoard, ChangePlayer),!,
   (changePlayer(ChangePlayer,CurrentPlayer,NextPlayer),
   Depth1 is Depth - 1,
   alphabeta(Ancestor,NewBoard, Alpha, Beta, _, Val,Depth1,NextPlayer),
  % print('(change player)before val:'),print(Val),nl,print('alpha:'),print(Alpha),nl,print('beta'),print(Beta),nl,
   goodenough(Ancestor,MoveList, Alpha, Beta, Move-NewBoard, Val, GoodPos, GoodVal,Depth,CurrentPlayer,NextPlayer);
   %print('(change player)after val:'),print(Val),nl,print('alpha:'),print(Alpha),nl,print('beta'),print(Beta),nl,
   alphabeta(Ancestor,NewBoard, Alpha, Beta, _, Val,Depth,CurrentPlayer),!,
   %print('(same player)before val:'),print(Val),nl,print('alpha:'),print(Alpha),nl,print('beta'),print(Beta),nl,
   goodenough(Ancestor,MoveList, Alpha, Beta, Move-NewBoard, Val, GoodPos, GoodVal,Depth,CurrentPlayer,NextPlayer)).
   %print('(same player)after val:'),print(Val),nl,print('alpha:'),print(Alpha),nl,print('beta'),print(Beta),nl.

goodenough(_,[],_,_,Move-NewBoard, Val, Move-NewBoard, Val,_,_,_):-!.

goodenough(_,_, Alpha, Beta, Move-NewBoard, Val, Move-NewBoard, Val,_,CurrentPlayer,_) :-
  CurrentPlayer is 1, Val > Beta, !;
  CurrentPlayer is 0, Val < Alpha, !.

goodenough(Ancestor,PosList, Alpha, Beta, Move-NewBoard, Val, GoodPos, GoodVal,Depth,CurrentPlayer,_) :-
   newbounds( Alpha, Beta, Move, Val, NewAlpha, NewBeta,CurrentPlayer),
   boundedbest(Ancestor,PosList, NewAlpha, NewBeta, Pos1, Val1,Depth,CurrentPlayer),
   betterof( Move-NewBoard, Val, Pos1, Val1, GoodPos, GoodVal,CurrentPlayer),!.

newbounds( Alpha, Beta, _, Val, Val, Beta,CurrentPlayer)  :-
CurrentPlayer is 1, Val > Alpha,!.

newbounds( Alpha, Beta,_, Val, Alpha, Val,CurrentPlayer)  :-
CurrentPlayer is 0, Val < Beta, !.

newbounds( Alpha, Beta, _, _, Alpha, Beta,_).

betterof( Move-NewBoard, Val, _, Val1, Move-NewBoard, Val,CurrentPlayer):-
CurrentPlayer is 1, Val > Val1, !
;
CurrentPlayer is 0, Val < Val1, !.

betterof( _, _, Move-NewBoard, Val, Move-NewBoard, Val,_):-!.                       % otherwise Pos 1 better
