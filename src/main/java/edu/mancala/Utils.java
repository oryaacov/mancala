package edu.mancala;

import java.io.File;

public class Utils {
    public static  String GetResourcePath(String resource){
        ClassLoader classLoader = Application.class.getClassLoader();
        File file = new File(classLoader.getResource(resource).getFile());
        return file.getPath();

    }
}
