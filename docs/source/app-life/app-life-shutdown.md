# agentgateway shutdown process


## Introduction

If you asked me to implement a reverse HTTP proxy, what would be the hardest or most complex design problem? Thread model? Protocol parsing? Flow-control buffers? I think the hardest part is graceful shutdown (drain), and even supporting hot restarts while connections stay alive.

Like most application code that focuses on error handling, a proxy spends a lot of its complexity on graceful shutdown. To understand shutdown you need to understand:

- what the core components or subservices are
- how components or subservices are initialized
- how components or subservices perform graceful shutdown (drain)

These aspects are central to understanding the service lifecycle. Below we analyze them.


## Shutting down the service


When shutting down the service, you must notify all subservices. agentgateway makes heavy use of Rust channels to communicate between asynchronous futures.


1. `app.rs > Bound::wait_termination(self)` is the service shutdown entry point and is responsible for notifying subservices.
2. It receives the OS `SIGTERM` signal.
3. It triggers the graceful shutdown (drain) flow: `start_drain_and_wait()` sends a message to `Signal(DrainTrigger)`.

4. Subservices watch `Watch(DrainWatcher)` and, on receiving the message from `Signal(DrainTrigger)`, perform their drain operations (for example, notifying HTTP connections to close).
5. After a subservice completes its drain operations it sends feedback to `Signal(DrainTrigger)`.
6. Once all subservices have sent feedback, the overall service can stop.


The following diagram shows this flow in detail:


:::{figure-md}
:class: full-width

<img src="agentgateway-channels.drawio.svg" alt="Figure: agentgateway application lifecycle collaboration">

*Figure: agentgateway application lifecycle collaboration*  
:::
*[Open in Draw.io](https://app.diagrams.net/?ui=sketch#Uhttps%3A%2F%2Fagentgateway-insider.mygraphql.com%2Fzh_CN%2Flatest%2F_images%2Fagentgateway-channels.drawio.svg)*


## Closing notes

I have studied Envoy Proxy's C++ code in depth. Envoy heavily uses OOP and polymorphism with event-driven callbacks to decouple component subsystems. That design makes the code verbose and terminology-heavy; it sometimes has a Java-like feel.

agentgateway, and its reference design project [Istio ztunnel](https://github.com/istio/ztunnel) (both projects share contributors and company ties), use Tokio + Rust async which is closer in feel to Go goroutines. See the Reddit discussion: [How Tokio works vs go-routines?](https://www.reddit.com/r/rust/comments/12c2mfx/how_tokio_works_vs_goroutines/).

From a code-reading perspective, Tokio + Rust async is simpler and more pragmatic, and can be easier to approach — assuming you understand Rust async and Tokio basics.


### Why study agentgateway

That's a good question. I believe AI applications are here and their infrastructure must evolve. As an infrastructure engineer (not an application developer), instead of waiting for AI to replace my role, I prefer to make AI depend on my work so we can coexist. Gateway-style infrastructure will be essential for AI governance at large organizations.



