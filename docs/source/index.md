![Book Cover](./book-cover-mockup.jpg)



# Preface

## About This Book

The title of this book is "Agentgateway Insider". This is a work in progress and currently in draft form. The book focuses on a deep exploration of the Agentgateway proxy mechanisms and implementation.

### Why study Agentgateway

That's a good question. I believe AI applications are here to stay, and the infrastructure for AI applications also needs to mature. As an infrastructure engineer (not an application developer), instead of waiting for AI to replace our jobs, it's better to make AI rely on the infrastructure we build, hoping for peaceful coexistence. Gateway-type infrastructure is inevitably essential for AI governance in large enterprises.

### What this book is

The book covers: analysis of Agentgateway source code and an in-depth breakdown of its core principles and architecture. However, it is not a traditional "deep dive into xyz source code" book. I have intentionally tried to avoid pasting large amounts of source code directly into the book. Reading source code is necessary to master implementation details, but the experience of browsing source snippets in a book is often poor. Instead, this book uses source-code navigation diagrams to present the full implementation flow so readers do not get lost in fragmented code snippets and miss the big picture.

In this book I try, from the perspectives of design and implementation, to systematically explain:
- The design and implementation details of Agentgateway


The contents are my thoughts and notes after studying and using Agentgateway for some time. I've investigated several Agentgateway-related functional and performance issues, and I have browsed and debugged some of Agentgateway's code.

While researching Agentgateway I found many valuable resources online. But they are either written mainly for users without explaining implementation mechanisms, or they explain mechanisms well but lack systematization and coherence.

### What this book is not

This book is not a user manual. It does not teach how to use Agentgateway from a user's perspective, nor does it evangelize Agentgateway's features. It is not a how-to user guide.

> 🤷 : [Yet, another](https://en.wikipedia.org/wiki/Yet_another) Agentgateway User Guide?  
> 🙅 : No!


### Intended audience

This book focuses on Agentgateway's design and implementation mechanisms. It assumes readers already have some experience using Agentgateway and are interested in studying its implementation details further.

### Where to find the book

- https://agentgateway-insider.mygraphql.com
- https://agentgateway-insider.readthedocs.io
- https://agentgateway-insider.rtfd.io


### About the author

My name is Mark Zhu. I'm a middle-aged programmer with thinning hair. I'm not an Agentgateway expert — at best I'm a contributor to Agentgateway issues. I'm not an employee of any major internet company.

Why write a book despite limited ability? Because of this sentence:
> You don't need to be great to start, but you need to start to become great.

Blog: https://blog.mygraphql.com/

To help readers follow updates to the blog and this book, I created a synchronized WeChat public account: Mark的滿紙方糖言

:::{figure-md} WeChat public account: Mark的滿紙方糖言

<img src="_static/my-wechat-blog-qr.png" alt="my-wechat-blog-qr.png">

*WeChat public account: Mark的滿紙方糖言*
:::


### Contributing

If you're interested in contributing to this book, please contact me. This book is not intended as a resume filler, and I don't have that capacity. Also, this kind of non-"short-and-fast" and non-"TL;DR" book is inevitably niche.


### Dedication 💞

First, to my dear parents, for showing me how to live a happy and productive life. To my dear wife and our amazing child — thanks for all your love and patience.

### Copyleft statement

Unless otherwise stated, please credit the original source when reprinting or modifying any text or images.

### Feedback

As an open interactive book, reader feedback is important. If you find errors in the book or have suggestions, please file an issue here:  
https://github.com/labilezhu/agentgateway-insider/issues


![](wechat-reward-qrcode.jpg)

![Book Cover](./book-cover-800.jpg)


# Contents


```{toctree}
:caption: Contents
:maxdepth: 5
:includehidden:

ch0/index
codebase-overview/codebase-overview.md
app-life/app-life.md
http-proxy/http-proxy.md
mcp-proxy/mcp-proxy.md
```
