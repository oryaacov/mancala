initBoard([4,4,4,4,4,4,0,4,4,4,4,4,4,0],[4,4,4,4,4,4,0,4,4,4,4,4,4,0],0,0).
board([G11,G12,G13,G14,G15,G16,F1,G26,G25,G24,G23,G22,G21,F2],[G21,G22,G23,G24,G25,G26,F2,G16,G15,G14,G13,G12,G11,F1],F1,F2).
winner(F1,F2,W):-
    F1>F2,W is 1;
    F2>F1,W is 2;
    F1=F2,W is 0.
%changeTurns(Current,Next):-
 %   Current is 1, Next is 0;
  %  Current is 0, Next is 1.
changeTurns(1,0).
changeTurns(0,1).

getPlayerBoard(Board,Current,B):-
    Current is 1,Board == board(B,_,_,_);
    Current is 0, Board == board(_,B,_,_).

posibleMoves(Board,Current,Ms):-
    getPlayerBoard(Board,Current,B),
    getMoves(B,Ms,1).
getMoves([G|Gs],[M|Ms],T):-
    T=<6,G\=0,M is T,
    T1 is T+1,
    getMoves(Gs,Ms,T1).
getMoves(_,_,7).

addSeeds(N,[B|Bs],[G|nGs]):-
    G is B+1,
    N1 is N-1,
    addSeeds(N1,Bs,nGs).
addSeeds(0,_,_).

getCurrentPlayersSum(Board,Sum):-
    Board == [_,_,_,_,_,_,Sum,_,_,_,_,_,_,_].
getOtherPlayerSum(Board,Sum):-
    Board == [_,_,_,_,_,_,_,_,_,_,_,_,_,Sum].
%Index should be mod 14
getAmountInIndex([B|Board],Index,Res):-
    I is Index-1,getAmountInIndex(Board,I,Res).
getAmountInIndex([B|_],_,0,B).


%get player spesific board (via getPlayerBoard)
%ChangeTurn = 0 player will have another turn ChangeTurn = 1 need to change player.
%didn't take care of rounds yes. 
executeMove(Move,[B|Bs],Index,[G|NewBoard],ChangeTurn):-
    Move\=0,
    M is Move-1,
    G is B,
    I is Index+1,
    executeMove(M,Bs,I,NewBoard);
    addSeeds(B,Bs,NewBoard),
    (Index = 7, ChangeTurn is 0,NewBoard is Bs);
    (getAmountInIndex(,Index+7,0),ChangeTurn is 1, /*take care of updating the final amount and zero out the other players hole*/
    ) ;
    ChangeTurn is 1, NewBoard is Bs).
    
    

    