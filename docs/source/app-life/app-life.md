# agentgateway Application Lifecycle


## Overview

This article analyzes the source code of the AI Agent bus gateway [agentgateway](https://github.com/agentgateway/agentgateway) and attempts to explain components and collaboration related to service lifecycle management. It covers component startup and initialization, port listeners, how termination signals propagate between components, and how graceful shutdown (drain) is implemented.

I have limited experience with Rust and especially Tokio's async style, so if you find mistakes please point them out.


## Service lifecycle


agentgateway consists of several subservices:

- admin service
- metrics server
- readiness service
- Gateway service

The last two run on the worker thread pool while the others run on the main thread. The Gateway Service performs the core workload.


```{toctree}
app-life-init.md
app-life-shutdown.md
```