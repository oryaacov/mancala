%the hueristics approach influenced by the following article:
%https://www.cs.huji.ac.il/~ai/projects/2012/Mancala/

%the total number of seeds, {{default_hole's_seeds}}*{{num_of_holes}}*{{num_of_players}} = 4*6*2 = 48
totalSeedsCount(48).


% calculate the state heuristic by using the earner, weaker and escaper heuristics
moveHeuristic(CurrentBoard,NextBoard,Res):-
    earnerHeuristic(CurrentBoard,NextBoard,EarnerRes),
    weakerHeuristic(CurrentBoard,NextBoard,WeakerRes),
    escaperHeuristic(NextBoard,EscaperRes),
    Res is (*(EarnerRes,1))+(*(WeakerRes,1))+(*(EscaperRes,1)).

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
    getCurrentPlayerMarblesCount(CurrentBoard,CurrentCount),
    getOtherPlayerMarblesCount(NextBoard,NextCountCount),
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


%the alpha beta algorithm
%entry when depth is bigger than zero
%Depth - is the search tree max depth
%Board - is the current game state (the current move)
%Alpha/Beta - the algoritm's alpha/beta value
%BestMove,Value - the best move and it's value which found by the alphabeta algorithm (the result).
alpha_beta( Depth,_, Board, Alpha, Beta, Move, Value ) :-
    possibleMoves(Board, Moves),
    not(isEmpty(Moves)), !,
    NewDepth is Depth - 1,
    NewAlpha is -Beta,
    NewBeta is -Alpha,
    evaluate_and_choose( Moves, Board, NewDepth, NewAlpha, NewBeta, nil, ( Move, Value )).

alpha_beta( 0,Ancestor, Board, _, _, _, Value ) :-
  moveHeuristic(Ancestor, Board, Value).


evaluate_and_choose([ Move | Moves ], Board, Depth, Alpha, Beta, Move1, BestMove ) :-
    move( Move, Board, NewBoard ),
    alpha_beta(Depth, Board, NewBoard, Alpha, Beta, Move1, Value ),
    NewValue is -Value,
    cutoff( Move, NewValue, Depth, Alpha, Beta, Moves, Board, Move1, BestMove ).

evaluate_and_choose( [], _, _, _, _, Move, ( Move, _ )).

cutoff(Move, Value, _, _, Beta, _, _, _, (Move, Value)) :-
    Value >= Beta.

cutoff(Move, Value, Depth, Alpha, Beta, Moves, Position, _, BestMove) :-
    Alpha < Value,
    Value < Beta,
    evaluate_and_choose(Moves, Position, Depth, Value, Beta, Move, BestMove).

cutoff(_, Value, Depth, Alpha, Beta, Moves, Position, PotMove, BestMove) :-
    Value =< Alpha,
    evaluate_and_choose(Moves, Position, Depth, Alpha, Beta, PotMove, BestMove).