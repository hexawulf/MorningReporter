package dev.hexawulf.morningreporter;

import java.io.*;
import java.util.*;

public class EnvLoader {

    public static Map<String, String> load(String filename) {
        Map<String, String> env = new HashMap<>();

        try (InputStream input = EnvLoader.class.getClassLoader().getResourceAsStream(filename)) {
            if (input == null) {
                System.err.println("❌ Could not find " + filename + " in classpath!");
                return env;
            }

            BufferedReader reader = new BufferedReader(new InputStreamReader(input));
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.startsWith("#") || !line.contains("=")) continue;
                String[] parts = line.split("=", 2);
                env.put(parts[0].trim(), parts[1].trim());
            }
        } catch (IOException e) {
            System.err.println("❌ Error loading .env: " + e.getMessage());
        }

        return env;
    }
}
