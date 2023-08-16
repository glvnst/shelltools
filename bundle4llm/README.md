# bundle4llm

CLI util for bundling the contents of a git workdir into an LLM prompt

The program takes the contents of a git workdir and bundles it into a text file which contains an LLM prompt encouraging code review. The contents are formatted as a base64-encoded CPIO archive which an LLM should be able to decode transparently.

## Example output

    Below is a base64-encoded POSIX.1-2001 compliant cpio archive stream containing
    a sofware project, (hopefully including a README and well-commented code).

    Please put on your expert software developer thinking cap and provide your
    highest quality analysis of this codebase. Focus on:

    * How well it follows established best practices
    * Opportunities to improve code quality
    * API design feedback
    * Test coverage gaps
    * Creative ways to enhance maintainability and usability

    I'm excited to leverage your full capabilities as an AI assistant to provide
    thoughtful, actionable suggestions to improve this code. Please go beyond
    superficial responses and showcase your ability to deeply analyze a codebase.
    Ask clarifying questions as needed.

    Let's begin our thoughtful code review of the following code:

    ```
    MDcwN[ ... base64-encoded cpio stream truncated for readme ...]AAAA==
    ```

## Usage

The program prints the following help text when started with the `-h` or `--help` flags:

```
Usage: bundle4llm [-h|--help] [WORKDIR_PATH]

-h / --help   show this message
-d / --debug  print additional debugging messages

--output-file OUTPUT_FILE_PATH  specify a different output path (default: ~/Desktop/codebase-bundle.txt)
--list-bundle LIST_BUNDLE_PATH  list the contents of the given bundle then exit

WORKDIR_PATH  the git workdir to encode (default: .)

CLI util for bundling the contents of a git workdir into an LLM prompt

```