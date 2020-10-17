%init the board with the default game values. ([P1_BOARD_VIEW,P2_BOARD_VIEW],F1,F2)
%-------------Checked-------------------
initBoard([4,4,4,4,4,4,0,4,4,4,4,4,4,0],[4,4,4,4,4,4,0,4,4,4,4,4,4,0],0,0).
%assign the var ([P1_BOARD_VIEW,P2_BOARD_VIEW],F1,F2) as board
%-------------Checked-------------------
board([G11,G12,G13,G14,G15,G16,F1,G26,G25,G24,G23,G22,G21,F2],[G21,G22,G23,G24,G25,G26,F2,G16,G15,G14,G13,G12,G11,F1],F1,F2).
%get the winner of the game
%-------------Checked-------------------
winner(F1,F2,W):-
    F1>F2,W is 1;
    F2>F1,W is 2;
    F1=F2,W is 0.
%change the turn from P2 to P1
%-------------Checked-------------------
changeTurns(2,1).
%change the turn from P1 to P2
%-------------Checked-------------------
changeTurns(1,2).

%assign the board by the play board view (clockwise)
getPlayerBoard(CurrentBoard,NextBoard):-
    board(CurrentBoard,NextBoard,_,_).

%return all of the possible moves (work for both users)
%-------------Checked-------------------
possibleMoves(Board,PossibleMoves):-
    getMoves(Board,PossibleMoves,1).

%sub function of posibleMoves
%G = the number of seeds inside a "Guma"
%M = "Move"
%T = temp counter, that count up to 6 which is the number of Gs at the user board
%-------------Checked-------------------
getMoves([G|Gs],[M|Ms],T):-
    T=<6,
    (G\=0,M is T,
    T1 is T+1,
    getMoves(Gs,Ms,T1));
    (G==0, T1 is T+1,
    getMoves(Gs,[M|Ms],T1)).
%return the results
getMoves(_,[],7).

%add the seeds from the current "guma" into all of the others
%N = the number of seeds in the current "guma"
%-------Problem with circle------------
addSeeds(N,[B|Bs],[G|NGs]):-
    N>0,G is B+1,
    N1 is N-1,
    addSeeds(N1,Bs,NGs) .
addSeeds(N,_,L):-
    N > 0, addSeeds(N,L,[]).
addSeeds(0,Bs,Bs).

%return the current scored seeds (the player which is playing in the current turn)
%--------------Checked------------------
getCurrentPlayersScore(Board,Sum):-
    Board = [_,_,_,_,_,_,Sum,_,_,_,_,_,_,_].
%return the rival scored seeds (the player which isn't playing in the current turn)
%--------------Checked------------------
getOtherPlayerScore(Board,Sum):-
    Board = [_,_,_,_,_,_,_,_,_,_,_,_,_,Sum].

%return the current player holes seed count (the player which is playing in the current turn)
%--------------Checked------------------
getCurrentPlayerMarblesCount(Board,Sum):-
    Board = [Hole1,Hole2,Hole3,Hole4,Hole5,Hole6,_,_,_,_,_,_,_,_],
    Sum is Hole1+Hole2+Hole3+Hole4+Hole5+Hole6.
%return the rival holes seed count (the player which isn't playing in the current turn)
%--------------Checked------------------
getOtherPlayerMarblesCount(Board,Sum):-
    Board = [_,_,_,_,_,_,_,Hole1,Hole2,Hole3,Hole4,Hole5,Hole6,_],
    Sum is Hole1+Hole2+Hole3+Hole4+Hole5+Hole6.

%return the amount of seeds "Guma"'s index
%Index should be mod 14
%--------------Checked------------------
getAmountInIndex([_|Board],Index,Res):-
    I is Index-1,getAmountInIndex(Board,I,Res).
getAmountInIndex([B|_],1,B).

%Applying end of game rules (currently counting the unfinished player seeds and add them into his sum)
%start T with 1
%we will send the other player's board we know the other one is empty.
endGameSequence([B|Bs],Sum,T):-
    T=<7,
    S is B+Sum,
    T1 is T+1,
    endGameSequence(Bs,S,T1).


%Move - the current move choosen by the alpha beta algorithm
%B - The "Goma"s
%Index - the current index
%G
%get player spesific board (via getPlayerBoard)
%ChangeTurn = 0 player will have another turn ChangeTurn = 1 need to change player.
%didn't take care of rounds yes.
executeMove(Move,[B|Bs],Index,[G|NewBoard],ChangeTurn):-
    Move\=0,
    M is Move-1,
    G is B,
    %G "next" B "current"
    I is Index+1,
    executeMove(M,Bs,I,NewBoard);
    addSeeds(B,Bs,NewBoard),
    (Index = 7, ChangeTurn is 0,NewBoard is Bs);
%    (getAmountInIndex(,Index+7,0),ChangeTurn is 1, /*take care of updating the final amount and zero out the other players hole*/
%    ) ;
    ChangeTurn is 1, NewBoard is Bs).

%Can we randomize this?
chooseFirstPlayer(1).
%should be Alpha-Beta
chooseMove([M|_],Move):-
    Move is M.
 %startGame predicate: start with first player(random?) possibleMoves,
 %for now choose the first move and execute move. according to ChangeTurn we will change turn and change the player and board
 %continue as before.we will continue like this until there is no more moves (ms =[]) , run end sequence and check who is the winner.
startGame:-
         chooseFirstPlayer(P),initBoard(Board,_,_,_),play(P,Board).
play(P,Board):-
    possibleMoves(Board,Moves),
    (   (Moves = [],endGameSequence(Board,Sum,1));
    ( chooseMove(Moves,M),executeMove(M,Board,1,NewBoard,ChangeTurn),
        ((      changeTurn is 1,getPlayerBoard(NewBoard,Next),changeTurns(P,P1),play(P1,Next));
         (   play(P,NewBoard))))).





