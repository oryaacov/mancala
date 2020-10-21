package edu.mancala;

import org.jpl7.*;
import org.jpl7.fli.Prolog;

import java.lang.Integer;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class PrologEngine {
    private static PrologEngine _instance = null;
    private static Object object = new Object();
    private static final  String NEXT_PLAYER = "NextPlayer";
    private static final  String CURRENT_PLAYER = "CurrentPlayer";
    private static final  String BOARD = "Board";
    private static final  String WINNER = "Winner";

    public void loadFiles(List<String> paths) throws Exception {
        for (String path : paths ) {
            Atom filePath = new Atom(path);
            //String s = "consult('lib\rules.pl')";
            Query consultQuery = new Query(new Compound("consult", new Term[]{new Atom(path)}));
            if (!consultQuery.hasSolution()) {
                throw new Exception("failed to load prolog file:" + path);
            }else{
                System.out.println(path+ " loaded");
            }
        }
    }

    private PrologEngine() {
        if (System.getenv("SWI_HOME_DIR") != null ||
                System.getenv("SWI_EXEC_FILE") != null ||
                System.getenv("SWIPL_BOOT_FILE") != null) {
            String init_swi_config =
                    String.format("%s %s %s -g true -q --no-signals --no-packs",
                            System.getenv("SWI_EXEC_FILE") == null ? "swipl" :
                                    System.getenv("SWI_EXEC_FILE"),
                            System.getenv("SWIPL_BOOT_FILE") == null ? "" :
                                    String.format("-x %s", System.getenv("SWIPL_BOOT_FILE")),
                            System.getenv("SWI_HOME_DIR") == null ? "" :
                                    String.format("--home=%s", System.getenv("SWI_HOME_DIR")));
            System.out.println(String.format("\nSWIPL initialized with: %s", init_swi_config));

            JPL.setDefaultInitArgs(init_swi_config.split("\\s+"));    // initialize SWIPL engine
        } else
            System.out.println("No explicit initialization done: no SWI_HOME_DIR, SWI_EXEC_FILE, or SWIPL_BOOT_FILE defined");
        try {
            JPL.init();
        } catch (Exception ex) {
            System.out.println(ex);
            throw ex;
        }
        System.out.println("Prolog engine actual init args: " + Arrays.toString(Prolog.get_actual_init_args()));
    }

    private static GameState MapResultsToGameState(Map<String, Term> values){
        if (values==null || values.isEmpty()) {
            return null;
        }

        GameState result = new GameState();
        result.winner=values.get(WINNER).intValue();
        result.nextPlayer=values.get(NEXT_PLAYER).intValue();
        result.currentPlayer = values.get(CURRENT_PLAYER).intValue();
        Term[] board = values.get(BOARD).listToTermArray();
        result.p1Marbles = getMarblesFromBoard(board,result.currentPlayer);
        result.p2Marbles = getMarblesFromBoard(board,result.currentPlayer);
        return result;
    }
    private static List<Integer> getMarblesFromBoard(Term[] values,int currentPlayer){
        if(values==null || values.length==0){
            return null;
        }
        List<Integer> results = new LinkedList<>();
        for (int i=(currentPlayer-1)*7;i<currentPlayer*7;i++){
                results.add(values[i].intValue());
        }
        return results;
    }

    //play(1,M,NewBoard,CurrentPlayer,NextPlayer)
    public static GameState PlayMove(int player, int move) {
        Query moveQuery
                = new Query(new Compound("play", new Term[]{
                        new org.jpl7.Integer(player),new org.jpl7.Integer(move),
                        new Variable( BOARD),new Variable(CURRENT_PLAYER),
                        new Variable(NEXT_PLAYER)
                }));
        //execute the move
        Map<String, Term> result=null;
        if (moveQuery.hasSolution()) {
            result = moveQuery.oneSolution();
        }
        if (result!=null) {
            Query winnerQuery = new Query("stateWinner", new Term[]{new Variable(WINNER)});
            if (winnerQuery.hasSolution()) {
                Map temp = (winnerQuery.oneSolution());
                if (!temp.isEmpty() && temp.get(WINNER) != null) {
                   result.put(WINNER, (Term) temp.get(WINNER));
                }
            }
            System.out.println(result);
            return MapResultsToGameState(result);
        }
        return null;
    }

    public static List<GameState>  StartGame(int player, int Depth) throws Exception {
        if (player != 1 && player!=2){
            throw  new Exception("invalid player");
        }
        Query moveQuery
                = new Query(new Compound("startGame", new Term[]{
                        new org.jpl7.Integer(player),new org.jpl7.Integer(Depth),new Variable("Board")}));
        List<Map<String, Term>> results = new LinkedList<Map<String, Term>>();
        if (moveQuery.hasSolution()) {
            while (moveQuery.hasMoreSolutions()) {
                results.add(moveQuery.nextSolution());
            }
        }
        System.out.println(results);
        return null;
    }


    public static PrologEngine GetEngine() {
        if (_instance == null) {
            synchronized (object) {
                if (_instance == null) {
                    _instance = new PrologEngine();
                }
            }
        }
        return _instance;
    }

}
/*Query q4 =
                new Query(new Compound("father", new Term[]
                        {new Variable("X"), new Variable("Y")}));

        if (q4.hasSolution()) {
            while (q4.hasMoreSolutions()) {
                Map<String, Term> res = q4.nextSolution();
                System.out.println("X = " + res.get("X"));
                System.out.println("Y = " + res.get("Y"));
                System.out.println("------------");

            }
        }*/

//
//    public static List<GameState> GetNextGameStates(Integer move,Integer player) {
//        LinkedList<GameState> res = new LinkedList<GameState>();
//        GameState hardCoded1 = new GameState();
//        GameState hardCoded2 = new GameState();
//        hardCoded1.nextPlayer=1;
//        hardCoded1.p1Marbles=new LinkedList<Integer>(Arrays.asList(0,3,6,7,1,2,15));
//        hardCoded1.p2Marbels=new LinkedList<Integer>(Arrays.asList(0,0,1,9,0,0,5));
//        hardCoded1.winner=0;
//        hardCoded2.nextPlayer=2;
//        hardCoded2.p1Marbles=new LinkedList<Integer>(Arrays.asList(1,4,7,8,2,3,16));
//        hardCoded2.p2Marbels=new LinkedList<Integer>(Arrays.asList(1,1,2,10,1,1,6));
//        hardCoded2.winner=0;
//        res.add(hardCoded1);
//        res.add(hardCoded2);
//        return res;
//    }