package edu.mancala;

import java.io.File;
import java.util.LinkedList;
import java.util.List;

public class Utils {
    public static List<String> GetResourcePath(List<String> resources){
        List<String> result = new LinkedList<>();
        for (String resource:resources) {
            ClassLoader classLoader = Application.class.getClassLoader();
          result.add(new File(classLoader.getResource(resource).getFile()).getPath());
        }
        return result;
    }
}
