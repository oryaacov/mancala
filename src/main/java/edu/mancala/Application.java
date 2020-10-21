package edu.mancala;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
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
            PrologEngine.StartGame(1,5);
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
            System.out.println(String.format("player:%d move:%d",player,move));
            return Arrays.asList(PrologEngine.PlayMove(1,move));
    }

}