# Markdown Standards

This document defines the markdown standards for Agent OS project documentation.

## Configuration

All markdown files must conform to the rules defined in `.markdownlint.json`:

- **Line Length**: Maximum 100 characters per line (excluding code blocks, tables, and headings)
- **File Endings**: All files must end with exactly one newline character
- **List Formatting**: Lists must be surrounded by blank lines
- **Code Block Formatting**: Fenced code blocks must be surrounded by blank lines

## Writing Guidelines

### Line Length (MD013)

Keep lines under 100 characters for better readability and version control diffs:

```markdown
✅ Good:
This is a properly formatted line that stays under the 100-character limit and wraps nicely
when needed.

❌ Bad:
This is a very long line that exceeds the 100-character limit and makes the document harder to read and maintain in version control systems.
```

### Lists (MD032)

Always add blank lines around lists:

```markdown
✅ Good:
Here is some text before the list.

- First item
- Second item  
- Third item

Here is some text after the list.

❌ Bad:
Here is some text before the list.
- First item
- Second item
Here is some text after the list.
```

### Code Blocks (MD031)

Surround fenced code blocks with blank lines:

```markdown
✅ Good:
Here is some explanatory text.

```bash
echo "This is properly formatted"
```

More explanatory text follows.

❌ Bad:
Here is some explanatory text.

```bash
echo "This needs blank lines around it"
```

More explanatory text follows.

### Trailing Spaces (MD009)

Remove trailing whitespace from lines:

```markdown
✅ Good:
This line has no trailing spaces.

❌ Bad:
This line has trailing spaces.   
```

### File Endings (MD047)

All markdown files must end with exactly one newline character.

## Validation

Use `markdownlint-cli2` to validate markdown files:

```bash
# Check all markdown files
markdownlint-cli2 '**/*.md'

# Check specific file
markdownlint-cli2 README.md

# Auto-fix issues (where possible)
markdownlint-cli2 --fix '**/*.md'
```

## Integration

- All markdown files should be validated before commit
- CI/CD pipelines should include markdown linting
- Editor configurations should enforce these standards automatically

## Tools and Extensions

### VS Code Extensions

- **markdownlint** - Real-time markdown validation
- **Prettier** - Auto-formatting with markdown support

### Editor Settings

Configure your editor to:

- Show line length rulers at 100 characters
- Highlight trailing whitespace
- Auto-trim trailing spaces on save
- Insert final newline on save
