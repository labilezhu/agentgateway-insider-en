![Book Cover](./docs/source/book-cover-mockup.jpg)

# Foreword

```{warning}
This book is a work in progress and currently only a draft.
```

## Book Overview

### What this book is not

This book is not a user manual. It is not written to teach how to use Agentgateway from a beginner's perspective. It will not extol Agentgateway's features nor provide step-by-step usage guides. There are already many excellent books, articles, and official docs that cover those topics.

> 🤷 : [Yet, another](https://en.wikipedia.org/wiki/Yet_another) Agentgateway User Guide?
> 🙅 : No!


### What this book is

In this book I attempt, from the perspectives of design and implementation, to systematically explore:
- Agentgateway's design philosophy and implementation architecture.
- Key functional implementation flows of Agentgateway.
- How Agentgateway uses async Rust and third-party libraries such as `tokio` and `hyper` for building an asynchronous network proxy server.

The contents are my personal notes and reflections after studying and using Agentgateway for some time. I am not an expert nor an Agentgateway committer (although I'm working toward that). I'm not an employee of a large tech company — just someone who has read and debugged parts of the Agentgateway codebase.

While researching Agentgateway I found many valuable resources online. Either they focus on users and omit implementation details, or they explain internals well but lack systematic coverage and continuity. This book aims to help fill that gap.

### Intended readers
This book focuses on Agentgateway's design and implementation mechanisms. It assumes readers already have some experience using Agentgateway.

### Where to access the book
- https://agentgateway-insider.mygraphql.com
- https://agentgateway-insider.readthedocs.io
- https://agentgateway-insider.rtfd.io


### About the author
My name is Mark Zhu, a middle-aged programmer with thinning hair.

Blog: https://blog.mygraphql.com/


### Important: Style, presentation, and interactive reading

Interactive book

Most of my writing effort went into creating diagrams rather than prose. The correct way to read this book is on a computer so you can interact with the images; mobile is mainly for quick reference.

The diagrams are often complex and not suitable for simple printouts, but they are interactive:

- Many original diagrams are created as Draw.io SVG files: `*.drawio.svg`.

For complex diagrams it's recommended to open them with draw.io:
- Some images include a "open with draw.io" link for richer interactivity in the browser.
- Hovering over certain underlined text in images shows tooltips with additional information, such as configuration snippets.

If you prefer not to use draw.io, you can still view the raw SVG:
- To view a large SVG comfortably, right-click the image in your browser and choose "Open image in new tab." For large SVGs, press the middle mouse button to pan freely.
- SVG images may contain clickable links that jump directly to related source code or documentation, sometimes down to exact line numbers.


### Language style
This book is not intended for print publication nor as an official document, so the tone is conversational. If you expect a solemn, formal textbook you may be disappointed. Conversational does not mean imprecise.


### Contributing
If you're interested in contributing, please contact me. This book isn't meant to be a resume-builder and will remain a niche, in-depth work rather than a short TL;DR guide.


### Dedication
First, to my dear parents, for showing me how to live a happy and productive life. To my dear wife and our amazing kid — thanks for all your love and patience.


### Copyleft notice
If you redistribute or modify the text or images, please credit the original source.
