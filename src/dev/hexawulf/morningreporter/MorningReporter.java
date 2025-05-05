package dev.hexawulf.morningreporter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.Properties;

import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class MorningReporter {

    public static void main(String[] args) {
        // Load .env variables
        Map<String, String> env = EnvLoader.load(".env");

        StringBuilder reportContent = new StringBuilder();

        reportContent.append("=== System Report ===\n");
        reportContent.append(runScript("scripts/linuxws2_report.sh")).append("\n");

        reportContent.append("=== Network Report ===\n");
        reportContent.append(runScript("scripts/linuxws2_netreport.sh")).append("\n");

        sendEmail(
            env.get("SMTP_FROM"),
            env.get("SMTP_TO"),
            "Daily Linuxws2 Report 📋",
            reportContent.toString(),
            env
        );
    }

    private static String runScript(String scriptPath) {
        StringBuilder output = new StringBuilder();
        try {
            ProcessBuilder builder = new ProcessBuilder("/bin/bash", scriptPath);
            builder.redirectErrorStream(true);
            Process process = builder.start();

            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }

            process.waitFor();
        } catch (IOException | InterruptedException e) {
            output.append("Error running script: ").append(e.getMessage()).append("\n");
        }
        return output.toString();
    }

    private static void sendEmail(String from, String to, String subject, String body, Map<String, String> env) {
        final String username = env.get("SMTP_USERNAME");
        final String password = env.get("SMTP_PASSWORD");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", env.get("SMTP_HOST"));
        props.put("mail.smtp.port", env.get("SMTP_PORT"));

        Session session = Session.getInstance(props,
            new jakarta.mail.Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(to)
            );
            message.setSubject(subject);
            message.setText(body);

            Transport.send(message);
            System.out.println("✅ Email sent successfully!");

        } catch (MessagingException e) {
            System.err.println("❌ Email failed to send:");
            e.printStackTrace();
        }
    }
}
