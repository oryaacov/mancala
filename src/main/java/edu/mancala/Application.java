package edu.mancala;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.beans.factory.annotation.Autowired;

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
            prologEngine.loadFile(Utils.GetResourcePath("prolog/main.pl"));
        }catch (Exception ex){
            System.out.println("failed to init prolog");
            System.out.println(ex);
            System.exit(0);
        }
    }


    @RequestMapping("/api")
    String api() {

        return "hey baby this is api";
    }
}