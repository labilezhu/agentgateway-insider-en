---
typora-root-url:/home/labile/agentgateway-insider/docs/source
to-be-english: true
---

# Interactive Reading Book

(interactive-book)=
## Interactive Book

At this point in human development, I think the definition of a "book" should be expanded. As technical knowledge becomes more complex, interactive and electronic presentation methods may be better suited for deep learning of complex technical topics. Put another way: when you're getting started you want abstraction and simplification; when you go deeper you want to clarify internal relationships.

This is not a "deep dive into xyz source code" kind of book. In fact, I've made every effort to avoid pasting large amounts of source code directly into the text. Reading source is an essential step to grasp implementation details, but browsing source inside a book is usually a poor experience. A navigation diagram for the code is often more useful.

Most of my writing time is spent drawing rather than writing. So this book is meant to be read on a computer where the diagrams can be interacted with. A phone is mostly just a way to attract readers.
The diagrams here are generally complex—not simple PPT-style charts—so they are not well-suited for printing. Instead, I make the diagrams interactive for readers:

- Most original diagrams are created in Draw.io and saved as SVG files: `*.drawio.svg`.

For complex diagrams, open them in Draw.io:
- Some images include a "Open in Draw.io" link so you can view them more interactively in your browser:
  - Icons with 🔗 link to online documentation and source code lines.
  - Icons with ⚓ link (on double-click) to local VS Code source files. See the {ref}`diagram-vscode-code-link-setup` section for details.
  - Icons with 💡 or 🛈 show hover popups with additional information, such as configuration snippets.

If you prefer not to use Draw.io, viewing the SVG directly also works:
- Right-click the image in your browser and choose "Open image in new tab". For large SVGs, press the middle mouse button to drag and pan.
- SVG images contain clickable links that can take you to the referenced source pages or documentation, sometimes down to specific lines.
- Some SVGs have layout issues, especially where code blocks are embedded. In those cases, open the diagram in Draw.io.

```{hint}
 - Open large diagrams in Draw.io. Diagrams contain many links to components, configuration items, and metrics; some links point to GitHub source lines.
 - Dual monitors (one for the diagram, one for the docs) are the ideal reading setup. If you're on a phone, this book may not be a good fit 🤦
```

## Writing Style

This text is not intended for print and is not official documentation, so the tone is conversational. If you're expecting a very formal book, you might be disappointed. Conversational does not mean careless.
This is my first book and I don't have professional proofreading, so if you find mistakes please file a GitHub issue.

## Diagram Style

Industry diagrams such as architecture and flowcharts generally fall into two styles:
- Neat and polished: attention to aesthetics and color; each diagram limits complexity and abstracts wherever possible. This style is common in PPTs and printed books.
- Engineer-style: detailed and matter-of-fact, only abstracting when the complexity exceeds what can be understood on a single plane. These diagrams are less tidy and reflect engineering culture; they're common in technical electronic docs.

This book uses both styles, but the latter is more common.













