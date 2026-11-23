package com.ischoolbar.programmer;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class ChatServlet extends HttpServlet {

    /** 连接超时（毫秒） */
    private static final int CONNECT_TIMEOUT = 10000;
    /** 读取超时（毫秒），大模型生成较慢，给足时间 */
    private static final int READ_TIMEOUT = 60000;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        // 避免被浏览器或代理缓存
        response.setHeader("Cache-Control", "no-store");

        // ---------- 1. 读取前端传来的 body ----------
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String body = sb.toString().trim();

        // body 为空或格式不对时直接返回，避免后面 substring 越界
        if (body.isEmpty() || !body.startsWith("{") || !body.endsWith("}")) {
            writeReply(response, "请求格式有误，请重试。");
            return;
        }

        // ---------- 2. 组装转发给大模型的请求体 ----------
        // 前端传的是 {"messages":[...]}，砍掉首字符后拼到 model 字段后面
        String payload = "{\"model\":\"" + escapeJson(AiConfig.getModel())
                + "\",\"stream\":false," + body.substring(1);

        // ---------- 3. 调用大模型 ----------
        HttpURLConnection conn = null;
        String rawResponse;
        try {
            conn = (HttpURLConnection) new URL(AiConfig.getApiUrl()).openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setConnectTimeout(CONNECT_TIMEOUT);
            conn.setReadTimeout(READ_TIMEOUT);
            conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
            conn.setRequestProperty("Accept", "application/json");
            conn.setRequestProperty("Authorization", "Bearer " + AiConfig.getApiKey());

            try (OutputStream os = conn.getOutputStream()) {
                os.write(payload.getBytes(StandardCharsets.UTF_8));
                os.flush();
            }

            int code = conn.getResponseCode();
            // 4xx / 5xx 时错误信息在 errorStream 里，不能直接读 inputStream
            InputStream is = (code >= 200 && code < 300)
                    ? conn.getInputStream()
                    : conn.getErrorStream();

            StringBuilder result = new StringBuilder();
            if (is != null) {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(is, StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = br.readLine()) != null) {
                        result.append(line);
                    }
                }
            }
            rawResponse = result.toString();

            if (code < 200 || code >= 300) {
                // 打印出来方便排查（Key 失效、模型名错误、余额不足等）
                System.err.println("[ChatServlet] 大模型返回异常 code=" + code
                        + " body=" + rawResponse);
                writeReply(response, "抱歉，AI 服务暂时不可用（" + code + "），请稍后再试。");
                return;
            }
        } catch (IOException e) {
            System.err.println("[ChatServlet] 调用大模型失败: " + e.getMessage());
            e.printStackTrace();
            writeReply(response, "抱歉，网络连接失败，请稍后再试。");
            return;
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }

        // ---------- 4. 解析出 content ----------
        String reply = extractContent(rawResponse);
        if (reply == null || reply.trim().isEmpty()) {
            System.err.println("[ChatServlet] 未能解析出 content，原始返回=" + rawResponse);
            reply = "抱歉，暂时没有匹配到合适的房间，您可以换个说法再试试。";
        }

        // ---------- 5. 输出（完整转义，避免 Bad control character） ----------
        writeReply(response, reply);
    }

    /**
     * 统一输出 {"reply":"..."}，保证是合法 JSON
     */
    private void writeReply(HttpServletResponse response, String reply) throws IOException {
        String json = "{\"reply\":\"" + escapeJson(reply) + "\"}";
        response.getWriter().write(json);
    }

    /**
     * 从大模型返回的 JSON 中取出 choices[0].message.content
     * 兼容 content 为字符串的常见 OpenAI 格式
     */
    private String extractContent(String text) {
        if (text == null) return null;

        // 优先按标准结构定位 message 之后的 content
        int msgIdx = text.indexOf("\"message\"");
        int searchFrom = (msgIdx != -1) ? msgIdx : 0;
        int idx = text.indexOf("\"content\"", searchFrom);
        if (idx == -1) {
            idx = text.indexOf("\"content\"");   // 兜底：全局再找一次
        }
        if (idx == -1) return null;

        // 跳过 content 后面的冒号和空白，找到起始引号
        int p = idx + "\"content\"".length();
        while (p < text.length()
                && (text.charAt(p) == ':' || Character.isWhitespace(text.charAt(p)))) {
            p++;
        }
        if (p >= text.length() || text.charAt(p) != '"') return null;

        // 从起始引号后开始，处理转义字符，找到未转义的结束引号
        StringBuilder content = new StringBuilder();
        for (int i = p + 1; i < text.length(); i++) {
            char c = text.charAt(i);
            if (c == '\\' && i + 1 < text.length()) {
                char next = text.charAt(i + 1);
                switch (next) {
                    case 'n':  content.append('\n'); break;
                    case 'r':  content.append('\r'); break;
                    case 't':  content.append('\t'); break;
                    case 'b':  content.append('\b'); break;
                    case 'f':  content.append('\f'); break;
                    case '"':  content.append('"');  break;
                    case '\\': content.append('\\'); break;
                    case '/':  content.append('/');  break;
                    case 'u':
                        // unicode 转义形式，后面跟 4 位十六进制数字
                        if (i + 5 < text.length()) {
                            try {
                                content.append((char) Integer.parseInt(
                                        text.substring(i + 2, i + 6), 16));
                                i += 5;
                            } catch (NumberFormatException e) {
                                content.append(next);
                            }
                        } else {
                            content.append(next);
                        }
                        break;
                    default:   content.append(next);
                }
                i++;   // 跳过已处理的转义字符
            } else if (c == '"') {
                break;   // 遇到未转义的引号，字符串结束
            } else {
                content.append(c);
            }
        }
        return content.toString();
    }

    /**
     * 把普通字符串转成合法的 JSON 字符串字面量内容。
     * 反斜杠必须最先处理，这里用逐字符扫描天然保证顺序。
     * 修复点：原代码漏掉了换行、回车、制表符等控制字符，
     *        导致前端 JSON.parse 抛出 Bad control character 错误。
     */
    private static String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '"':  sb.append("\\\""); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                case '\b': sb.append("\\b");  break;
                case '\f': sb.append("\\f");  break;
                default:
                    // 其余控制字符（0x00-0x1F、0x7F）用 unicode 转义形式输出
                    if (c <= 0x1F || c == 0x7F) {
                        sb.append(String.format("\\u%04X", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }
}