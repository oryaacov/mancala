:- dynamic(state/4).
%init the board with the default game values. ([P1_BOARD_VIEW,P2_BOARD_VIEW],F1,F2)
%-------------Checked-------------------
initBoard([4,4,4,4,4,4,0,4,4,4,4,4,4,0],[4,4,4,4,4,4,0,4,4,4,4,4,4,0],0,0).
%assign the var ([P1_BOARD_VIEW,P2_BOARD_VIEW],F1,F2) as board
%-------------Checked-------------------
board([G1,G2,G3,G4,G5,G6,F1,G8,G9,G10,G11,G12,G13,F2],[G8,G9,G10,G11,G12,G13,F2,G1,G2,G3,G4,G5,G6,F1],F1,F2).
%get the winner of the game
%-------------Checked-------------------
winner(F1,F2,W):-
    F1>F2,W is 1;
    F2>F1,W is 2;
    F1=F2,W is 0.

winnerB(Board,W):-
    board(Board,_,F1,F2),winner(F1,F2,W).
%change the turn from P2 to P1
%-------------Checked-------------------
changeTurns(2,1).
%change the turn from P1 to P2
%-------------Checked-------------------
changeTurns(1,2).

%assign the board by the play board view (clockwise)
%---------------Checked-----------------------------
getNextPlayerBoard(CurrentBoard,NextBoard):-
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

%calculate how many seeds needs to be added to each Guma on the board
%N = the number of seeds in the current "guma"
%------------Checked---------------------
calcSeeds(N,Board,Index,NewBoard):-
    Div is N div 14,
    Mod is N mod 14,
    addSeeds(Div,Mod,Board,Index,NewBoard).
%add the seeds from the current "guma" into all of the others
%Add2All = How many to add to all the "Gumot".
%AddOne2 = Add one seed to "Gumot" 1 to AddOne2 index.
%-------------Checked--------------------------
addSeeds(Add2All,AddOne2,[G|Gs],Index,[NG|NGs]):-
    ((AddOne2 > 0,Index =< 0,NG is G+Add2All+1);
    (AddOne2 =< 0,Index =< 0,NG is G+Add2All);
    (AddOne2 > 0,Index > 0,NG is G+Add2All);
    (AddOne2 =< 0,Index > 0,NG is G+Add2All-1)),
    Add is AddOne2-1,
    I is Index-1,
    addSeeds(Add2All,Add,Gs,I,NGs).
addSeeds(_,_,[],_,[]).

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
getAmountInIndex([B|_],1,Res):-
    Res is B.
getAmountInIndex([_|Board],Index,Res):-
    I is Index-1,getAmountInIndex(Board,I,Res).

%make zero in index
%--------------Checked------------------
zeroInIndex([B|Board],Index,[B|NewBoard]):-
    I is Index-1,zeroInIndex(Board,I,NewBoard).
zeroInIndex([_|Board],1,[0|Board]).

%Index is 14/7
updateFinal([B|Board],Sum2Add,Index,[B|NewBoard]):-
    I is Index-1,updateFinal(Board,Sum2Add,I,NewBoard).
updateFinal([F|Board],Sum2Add,1,[NF|Board]):-
    NF is F + Sum2Add.

%Applying end of game rules (currently counting the unfinished player seeds and add them into his sum)
%start T with 1
%we will send the other player's board we know the other one is empty.
%---needs to be checked-------
endGameSequence([B|Bs],Sum,T):-
    T=<7,
    S is B+Sum,
    T1 is T+1,
    endGameSequence(Bs,S,T1).
endGameSequence(_,0,7).
endGame(Board,NewBoard):-
    endGameSequence(Board,Sum,1),updateFinal(Board,Sum,14,NewBoard).

%Move - the current move choosen by the alpha beta algorithm
%Index - the current index
%ChangeTurn = 0 player will have another turn ChangeTurn = 1 need to change player.
%---needs to be checked-------
executeMove(Move,Board,UpdatedBoard,ChangeTurn):-
    getAmountInIndex(Board,Move,Amnt),
    calcSeeds(Amnt,Board,Move,NewBoard),
    ((S is Move + Amnt,S = 7, ChangeTurn is 0,UpdatedBoard is NewBoard);
    (getAmountInIndex(NewBoard,Move,1),ChangeTurn is 1, zeroInIndex(NewBoard,Move+8,UpdatedBoard)) ;
    (ChangeTurn is 1,UpdatedBoard is NewBoard)).

%Can we randomize this?
chooseFirstPlayer(1).
%should be Alpha-Beta
chooseMove([M|_],Move):-
    Move is M.
 %startGame predicate: start with first player(random?) possibleMoves,
 %for now choose the first move and execute move. according to ChangeTurn we will change turn and change the player and board
 %continue as before.we will continue like this until there is no more moves (ms =[]) , run end sequence and check who is the winner.
startGame:-
         chooseFirstPlayer(P),initBoard(Board,_,_,_),assert(state(Board,Board,-1,1)),play(P,Board).
%---needs to be checked-------
play(P,Board):-
    possibleMoves(Board,Moves),
    ((Moves = [],getNextPlayerBoard(Board,Next),endGame(Next,New),winnerB(New,W),retractall(state(_,_,_,_)),assert(state(Board,Board,W,W)));
    ( chooseMove(Moves,M),executeMove(M,Board,NewBoard,ChangeTurn),
        ((ChangeTurn is 1,getNextPlayerBoard(NewBoard,Next),changeTurns(P,P1),
          retractall(state(_,_,_,_)),assert(state(NewBoard,Next,-1,P1)),play(P1,Next));
         (play(P,NewBoard))))).



