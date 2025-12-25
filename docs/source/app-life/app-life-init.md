# agentgateway service initialization flow


## Initialization flow

Below I describe the initialization flow and the thread model. The main thread types are:

- main thread — thread name: agentgateway
- main spawn thread — thread name: agentgateway
- agentgateway workers — thread name format: agentgateway-N


:::{figure-md}
:class: full-width

<img src="agentgateway.drawio.svg" alt="Figure: Agentgateway initialization flow">

*Figure: Agentgateway initialization flow*  
:::
*[Open in Draw.io](https://app.diagrams.net/?ui=sketch#Uhttps%3A%2F%2Fagentgateway-insider.mygraphql.com%2Fzh_CN%2Flatest%2F_images%2Fagentgateway.drawio.svg)*


Reading Rust code that uses Tokio and async can be a bit overwhelming for Rust newcomers. Fortunately I previously learned Go and its goroutines, which makes the concepts easier to grasp. Each OS thread can have a [tokio::runtime::Runtime](https://docs.rs/tokio/1.47.1/tokio/runtime/index.html) bound to its thread-local context (similar to a scheduler with a thread pool). The key is to focus on the code that performs `spawn` operations.
