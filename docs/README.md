# Writing with Typst

We propose hereafter a quick guide to help write a document using **Typst**.

![Typst](typst.svg)

> [!NOTE]
> **Typst** uses a concise markup language inspired by **Markdown** to provide a wide range of formatting options.

## Text Formatting
* **Bold Text:** Surround your text with single asterisks `*bold*`.
* **Emphasis (Italics):** Surround your text with single underscores `_emphasis_`.
* **Headings:** Use equal signs `=` followed by a space at the beginning of a line. The number of `=` symbols determines the heading level _(e.g., `= Heading 1`, `== Heading 2`)_.

## Creating Lists
* **Unordered Lists:** Use a hyphen `-` followed by a space for each list item.
* **Ordered Lists:** Use a plus sign `+` followed by a space for each list item.

## Code Snippets
* **Inline Code:** Enclose the code within single backticks (\`).
* **Code Blocks:** Use triple backticks (\`\`\`) followed by the programming language to enable syntax highlighting.

```typ
```lang
"Hello from `lang`!"
`` `
```

## Inserting Objects

### Images
Use the following syntax to insert an image and reference it in the text:

```typ
#figure(
  image("IMAGE_NAME.EXT", width: 100%),
  caption: [IMAGE_CAPTION],
) <fig:LABEL>

As seen in @fig:LABEL, the image is rendered beautifully.
```

### Tables
Use the following syntax to construct a table and reference it in the text:

```typ
#figure(
  table(
    columns: 4,
    [Row 1], [a], [b], [c],
    [Row 2], [1], [2], [3],
  ),
  caption: [Results],
) <tab:LABEL>

@tab:LABEL displays some results.
```
