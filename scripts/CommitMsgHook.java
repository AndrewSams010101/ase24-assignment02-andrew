import java.io.*;
import java.util.regex.*;
import java.util.*;
// my first comment
public class CommitMsgHook {

    private static final String DEFAULT_TYPE_REGEX = "(feat|fix|chore|docs|style|refactor|test|build|ci|perf)";
    private static final String CUSTOM_TYPE_REGEX = "^[a-zA-Z0-9-]+$";
    private static final String SCOPE_REGEX = "^[a-zA-Z0-9-]+$"; // Valid scope format: alphanumeric, hyphen
    private static final String FOOTER_REGEX = "^(BREAKING CHANGE:|Reviewed-by:|Fixes:).*";
    private static final Set<String> customTypes = new HashSet<>(); // Set to store custom commit types

    public static void main(String[] args) {
        try {
            if (args.length != 1) {
                System.out.println("Usage: java CommitMsgHook <commit-msg-file>");
                System.exit(1);  // Exit with error status if the argument is incorrect
            }

            File commitMsgFile = new File(args[0]);
            String commitMessage = readCommitMessage(commitMsgFile);

            // Load custom types from config file
            loadCustomCommitTypes();

            // Debugging: print commit message read
            System.out.println("Commit message read: " + commitMessage);

            validateCommitMessage(commitMessage);
            System.out.println("Commit message is valid.");
            System.exit(0);  // Exit with success status if the message is valid
        } catch (Exception e) {
            // Debugging: print error message
            System.out.println("Error: " + e.getMessage());
            System.exit(1);  // Exit with error status if there is an issue
        }
    }

    private static String readCommitMessage(File commitMsgFile) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(commitMsgFile));
        StringBuilder stringBuilder = new StringBuilder();
        String sentences;
        while ((sentences = reader.readLine()) != null) {
            stringBuilder.append(sentences).append("\n");
        }
        return stringBuilder.toString().trim();
    }

    private static void validateCommitMessage(String commitMessage) throws Exception {
        if (commitMessage.isEmpty()) {
            throw new Exception("Commit message is empty.");
        }

        // Check the header (type: scope)
        Pattern headerPattern = Pattern.compile("^(\\w+)(\\((.*?)\\))?:\\s*(.*)$");
        Matcher headerMatcher = headerPattern.matcher(commitMessage.split("\n")[0]);
        if (!headerMatcher.matches()) {
            throw new Exception("Invalid commit message header: " + commitMessage.split("\n")[0]);
        }

        String type = headerMatcher.group(1);
        String scope = headerMatcher.group(3);
        String description = headerMatcher.group(4);

        // Reject commit message with '!' but no description
        if (type.contains("!") && description.trim().isEmpty()) {
            throw new Exception("Invalid commit message body: " + commitMessage.split("\n")[0]);
        }

        // Validate type: check against both default types and custom types
        if (!type.matches(DEFAULT_TYPE_REGEX) && !customTypes.contains(type)) {
            throw new Exception("Invalid commit message header: " + commitMessage.split("\n")[0]);
        }

        // Validate scope (optional but if present, needs to match the regex)
        if (scope != null && !scope.matches(SCOPE_REGEX)) {
            throw new Exception("Invalid commit message header: " + commitMessage.split("\n")[0]);
        }

        // Reject commit message without description
        if (description == null || description.trim().isEmpty()) {
            throw new Exception("Invalid commit message body: " + commitMessage.split("\n")[0]);
        }

        // Validate commit body (must start with a blank line if present)
        String[] commitLines = commitMessage.split("\n");
        boolean bodyStartsWithBlankLine = commitLines.length > 1 && commitLines[1].trim().isEmpty();
        if (commitLines.length > 1 && !bodyStartsWithBlankLine) {
            throw new Exception("Commit body must start with a blank line.");
        }

        // Validate footers
        validateFooters(commitMessage);

        // Additional checks for 'BREAKING CHANGE' footer
        if (commitMessage.contains("BREAKING CHANGE") && !commitMessage.matches(".*BREAKING CHANGE:.*")) {
            throw new Exception("Invalid footer format or missing required footer.");
        }
    }

    private static void loadCustomCommitTypes() throws IOException {
        File configFile = new File(".git/hooks/scripts/commit-types.config");
        if (configFile.exists()) {
            BufferedReader reader = new BufferedReader(new FileReader(configFile));
            String sentences;
            while ((sentences = reader.readLine()) != null) {
                String trimmedSentence = sentences.trim();
                if (!trimmedSentence.isEmpty() && trimmedSentence.matches(CUSTOM_TYPE_REGEX)) {
                    customTypes.add(trimmedSentence);
                } else if (!trimmedSentence.isEmpty()) {
                    System.out.println("Skipping invalid custom commit type: " + trimmedSentence);
                }
            }
        }
    }

    private static void validateFooters(String commitMessage) throws Exception {
        String[] MultilineSentences = commitMessage.split("\n");
        for (String sentence : MultilineSentences) {
            if (sentence.startsWith("BREAKING CHANGE:") && !sentence.contains(":")) {
                throw new Exception("Invalid footer format or missing required footer.");
            }
            if (!sentence.matches(FOOTER_REGEX) && sentence.contains(":")) {
                throw new Exception("Invalid footer format or missing required footer.");
            }
        }
    }
}
