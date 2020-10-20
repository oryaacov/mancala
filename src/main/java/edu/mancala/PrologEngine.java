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

    public static List<GameState> PlayMove(int move) {
        Query moveQuery
                = new Query(new Compound("play", new Term[]{new org.jpl7.Integer(move)}));
        //execute the move
        List<Map<String, Term>> results = new LinkedList<Map<String, Term>>();
        if (moveQuery.hasSolution()) {
            while (moveQuery.hasMoreSolutions()) {
                results.add(moveQuery.nextSolution());
            }
        }
        System.out.println(results);
        return null;
    }

    public static List<GameState>  StartGame(int player) throws Exception {
        if (player != 1 && player!=2){
            throw  new Exception("invalid player");
        }
        Query moveQuery
                = new Query(new Compound("startGame", new Term[]{new org.jpl7.Integer(player)}));
        //execute the move
        List<Map<String, Term>> results = new LinkedList<Map<String, Term>>();
        if (moveQuery.hasSolution()) {
            while (moveQuery.hasMoreSolutions()) {
                results.add(moveQuery.nextSolution());
            }
        }
        System.out.println(results);
        return null;
    }

    public static List<GameState> GetNextGameStates(Integer move,Integer player) {
        LinkedList<GameState> res = new LinkedList<GameState>();
        GameState hardCoded1 = new GameState();
        GameState hardCoded2 = new GameState();
        hardCoded1.nextPlayer=1;
        hardCoded1.p1Marbles=new LinkedList<Integer>(Arrays.asList(0,3,6,7,1,2,15));
        hardCoded1.p2Marbels=new LinkedList<Integer>(Arrays.asList(0,0,1,9,0,0,5));
        hardCoded1.winner=0;
        hardCoded2.nextPlayer=2;
        hardCoded2.p1Marbles=new LinkedList<Integer>(Arrays.asList(1,4,7,8,2,3,16));
        hardCoded2.p2Marbels=new LinkedList<Integer>(Arrays.asList(1,1,2,10,1,1,6));
        hardCoded2.winner=0;
        res.add(hardCoded1);
        res.add(hardCoded2);
        return res;
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