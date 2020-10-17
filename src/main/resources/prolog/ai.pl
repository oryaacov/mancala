%the total number of seeds, {{default_hole's_seeds}}*{{num_of_holes}}*{{num_of_players}} = 4*6*2 = 48
totalSeedsCount(48).

% the earner heuristic focus on the player hole's seed count
% return the player's player Kala's seeds diff from the previous move.
earnerHeuristic(CurrentBoard,NextBoard,Res):-
    getCurrentPlayersScore(CurrentBoard,CurrentScore),
    getCurrentPlayersScore(NextBoard,NextScore),
    Res is NextScore - CurrentScore.


% the weaker heuristic focus on the player steeling seeds.
% count the river seeds and devided by the total seeds count
weakerHeuristic(CurrentBoard,NextBoard,Res):-
    getCurrentPlayerMarblesCount(CurrentBoard,CurrentCount),
    getOtherPlayerMarblesCount(NextBoard,NextCountCount),
    Temp is CurrentCount-NextCountCount,
    (Temp>0,Res is Temp;
    Res is 0).


% the escaper heuristic focus on the player steeling seeds.
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



