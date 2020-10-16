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
    getOtherPlayerScore(CurrentBoard,CurrentCount),
    getOtherPlayerScore(NextBoard,NextCountCount),
    Res is NextCountCount-CurrentCount.

% the acer heuristic focus on the player steeling seeds.
% count the river seeds and devided by the total seeds count
acerHeuristic(Board,Res):-
    getOtherPlayerScore(Board,Count),
    totalSeedsCount(TotalSeeds),
    Res is Temp/TotalSeeds.

% the escaper heuristic focus on the player steeling seeds.
% count the river seeds and devided by the total seeds count
escaperHeuristic(Board,Res):-
    countEmptyHoles(Board,0,EmptyBoards),
    Res is 6-EmptyBoards.

countEmptyHoles(_,7,0).
countEmptyHoles([Hole|Board],Index,Res):-
    countEmptyHoles(Board,Index+1,Temp),
    (Hole =:= 0, Res is Temp+1;
    Res is Temp).



