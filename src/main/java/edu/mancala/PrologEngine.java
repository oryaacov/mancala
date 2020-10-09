package edu.mancala;

import org.jpl7.*;
import org.jpl7.fli.Prolog;

import java.util.Arrays;
import java.util.Map;

public class PrologEngine {
    private static PrologEngine _instance = null;
    private static Object object = new Object();

    public void loadFile(String path) throws Exception {
        System.out.println(path);
        Atom filePath = new Atom(path);
        //String s = "consult('lib\rules.pl')";
        Query consult_query
                = new Query(new Compound( "consult",new Term[]{new Atom(path)}));

        boolean consulted = consult_query.hasSolution();

        if (!consulted) {
            throw new Exception("failed to load prolog file:"+path);
        }
        Query q4 =
                new Query(new Compound("father", new Term[]
                        { new Variable("X"), new Variable("Y")}));

        if (q4.hasSolution()){
            while ( q4.hasMoreSolutions() ){
                Map<String, Term> res= q4.nextSolution();
                System.out.println( "X = " + res.get("X"));
                System.out.println( "Y = " + res.get("Y"));
                System.out.println( "------------");

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
        }
        catch (Exception ex){
            System.out.println(ex);
            throw ex;
        }
        System.out.println("Prolog engine actual init args: " + Arrays.toString(Prolog.get_actual_init_args()));
    }



    public static PrologEngine GetEngine(){
        if (_instance == null) {
            synchronized (object) {
                if (_instance == null) {
                    _instance  = new PrologEngine();
                }
            }
        }
        return _instance;
    }

}