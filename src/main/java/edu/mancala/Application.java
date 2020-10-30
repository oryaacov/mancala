package edu.mancala;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Optional;

@SpringBootApplication
@RestController
public class Application {


    @Autowired
    private ResourceConfigs staticConfig;
    private static PrologEngine prologEngine;

    public static void main(String[] args)  {
        initProlog();
        SpringApplication.run(Application.class, args);

    }

    public static void initProlog(){
        try {
            prologEngine = PrologEngine.GetEngine();
            prologEngine.loadFiles(Utils.GetResourcePath(Arrays.asList(
                    "prolog/game_rules.pl","prolog/utils.pl","prolog/ai.pl")));
            PrologEngine.StartGame(1,2);
        }catch (Exception ex){
            System.out.println("failed to init prolog");
            System.out.println(ex);
            System.exit(0);
        }
    }

    @RequestMapping(value = "/play",method = RequestMethod.GET,produces =  MediaType.APPLICATION_JSON_VALUE)
    List<GameState> PlayMove(
            @RequestParam(value = "player",required = true) Integer player,
            @RequestParam(value = "move", required = true) Integer move) {
            //get new state from prolog engine
            List<GameState> result = new LinkedList<>();
            GameState res ;
            int nextPlayer = 1;
            do{
            res = PrologEngine.PlayMove(nextPlayer,move);
            nextPlayer=res.nextPlayer;
            result.add(res);
            }while(res.nextPlayer==2 && res.winner<0);
            return result;
    }
    @RequestMapping(value = "/start",method = RequestMethod.GET,produces =  MediaType.APPLICATION_JSON_VALUE)
    ResponseEntity StartNewGame(@RequestParam(value = "depth",required = true) Integer depth) throws Exception {
        //get new state from prolog engine
        if (depth>1) {
            PrologEngine.StartGame(1, depth);
            System.out.println(String.format("started new game with depth of %d",depth));
        }else{
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>(HttpStatus.OK);

    }

}