package com.ischoolbar.programmer;
import java.io.InputStream;
import java.util.Properties;

public class AiConfig {
    private static Properties props = new Properties();

    static {
        try {
            InputStream is = AiConfig.class.getClassLoader()
                    .getResourceAsStream("ai.properties");
            props.load(is);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String getApiKey()  { return props.getProperty("ai.api.key"); }
    public static String getApiUrl()  { return props.getProperty("ai.api.url"); }
    public static String getModel()   { return props.getProperty("ai.model"); }
}