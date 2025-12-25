# Http Proxy Main Flow

Essentially, Agentgateway is an HTTP Proxy, but it adds support for AI (LLM/MCP/A2A) stateful protocols on top of HTTP. Therefore, analyzing the main flow of the HTTP Proxy layer is analyzing the main flow of Agentgateway.

## Http Proxy Analysis Example

### Agentgateway Configuration File

The Http Proxy main flow analyzed in this section is based on the following Agentgateway configuration file

https://github.com/labilezhu/pub-diy/blob/main/ai/agentgateway/ag-dev/devcontainer-config.yaml
```yaml
config:  
  logging:
    level: debug
    fields:
      add:
        span.name: '"openai.chat"'
        # openinference.span.kind: '"LLM"'
        llm.system: 'llm.provider'
        llm.params.temperature: 'llm.params.temperature'
        # By default, prompt and completions are not sent; enable them.
        request.headers: 'request.headers'
        request.body: 'request.body'
        request.response.body: 'response.body'

        llm.completion: 'llm.completion'
        llm.input_messages: 'flattenRecursive(llm.prompt.map(c, {"message": c}))'
        gen_ai.prompt: 'flattenRecursive(llm.prompt)'
        llm.output_messages: 'flattenRecursive(llm.completion.map(c, {"role":"assistant", "content": c}))'
  adminAddr: "0.0.0.0:15000"  # Try specifying the full socket address

  tracing:
    otlpEndpoint: http://tracing:4317
    # otlpProtocol: http
    randomSampling: true
    clientSampling: true
    fields:
      add:
        span.name: '"openai.chat"'
        # openinference.span.kind: '"LLM"'
        llm.system: 'llm.provider'
        llm.params.temperature: 'llm.params.temperature'
        # By default, prompt and completions are not sent; enable them.
        request.headers: 'request.headers'
        request.body: 'request.body'
        request.response.body: 'response.body'

        llm.completion: 'llm.completion'
        llm.input_messages: 'flattenRecursive(llm.prompt.map(c, {"message": c}))'
        gen_ai.prompt: 'flattenRecursive(llm.prompt)'
        llm.output_messages: 'flattenRecursive(llm.completion.map(c, {"role":"assistant", "content": c}))'
binds:
- port: 3100
  listeners:
  - routes:
    - policies:
        urlRewrite:
          authority: #also known as “hostname”
            full: dashscope.aliyuncs.com
          # path:
          #   full: "/compatible-mode/v1"
        requestHeaderModifier:
          set:
            Host: "dashscope.aliyuncs.com" #force set header because "/compatible-mode/v1/models: passthrough" auto set header to 'api.openai.com' by default
        backendTLS: {}
        backendAuth:
          key: "sk-abc"

      backends:
      - ai:
          name: qwen-plus
          hostOverride: dashscope.aliyuncs.com:443
          provider:
            openAI: 
              model: qwen-plus
          policies:
            ai:
              routes:
                /compatible-mode/v1/chat/completions: completions
                /compatible-mode/v1/models: passthrough
                "*": passthrough

- port: 3101
  listeners:
  - routes:
    - policies:
        cors:
          allowOrigins:
            - "*"
          allowHeaders:
            - mcp-protocol-version
            - content-type
            - cache-control
        requestHeaderModifier:
          add:
            Authorization: "Bearer abc"            
      backends:
      - mcp:
          targets:
          - name: home-assistant
            mcp:
              host: http://192.168.1.68:8123/api/mcp           
```


### Triggering an LLM Request

```bash
curl -v http://localhost:3100/compatible-mode/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "any-model-name",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'  
```

Response:

```
* Host localhost:3100 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:3100...
* Connected to localhost (::1) port 3100
* using HTTP/1.x
> POST /compatible-mode/v1/chat/completions HTTP/1.1
> Host: localhost:3100
> User-Agent: curl/8.14.1
> Accept: */*
> Content-Type: application/json
> Content-Length: 104
> 
* upload completely sent off: 104 bytes
< HTTP/1.1 200 OK
< vary: Origin,Access-Control-Request-Method,Access-Control-Request-Headers, Accept-Encoding
< x-request-id: 120e5847-3394-923c-a494-8eb9f81cb36e
< x-dashscope-call-gateway: true
< content-type: application/json
< server: istio-envoy
< req-cost-time: 873
< req-arrive-time: 1766635349727
< resp-start-time: 1766635350601
< x-envoy-upstream-service-time: 873
< date: Thu, 25 Dec 2025 04:02:30 GMT
< transfer-encoding: chunked
< 
* Connection #0 to host localhost left intact
{"model":"qwen-plus","usage":{"prompt_tokens":10,"completion_tokens":20,"total_tokens":30,"prompt_tokens_details":{"cached_tokens":0}},"choices":[{"message":{"content":"Hello! ٩(◕‿◕｡)۶ How can I assist you today?","role":"assistant"},"finish_reason":"stop","index":0,"logprobs":null}],"object":"chat.completion","created":1766635351,"system_fingerprint":null,"id":"chatcmpl-120e5847-3394-923c-a494-8eb9f81cb36e"}
```

### HTTP Proxy Main Flow Diagram


#### 1. L4 Connection Accept Flow

By debugging in VS Code, you can observe the main HTTP Proxy flow as shown below:

:::{figure-md}
:class: full-width

<img src="agentgateway-httpproxy.drawio.svg" alt="图：Http Proxy 主流程">

*Figure: HTTP Proxy Main Flow*
:::
*[Open with Draw.io](https://app.diagrams.net/?ui=sketch#Uhttps%3A%2F%2Fagentgateway-insider.mygraphql.com%2Fzh_CN%2Flatest%2F_images%2Fagentgateway-httpproxy.drawio.svg)*

> *Nodes marked with the ⚓ icon can be double-clicked to jump to the local VS Code source code. See the {ref}`diagram-vscode-code-link-setup` section.*




As shown, the main HTTP proxy logic resides in the `Gateway` struct. There are two key spawn points:
1. In `Gateway::run()`, a `Gateway::run_bind()` async future is spawned for each listening port. This task is responsible for listening on the port and `accept`ing new connections.
2. After `Gateway::run_bind()` accepts a new connection, it spawns a `Gateway::handle_tunnel()` async future for each connection. This task is responsible for handling all events for that connection.
  - If the tunnel protocol of the connection is `Direct` (i.e., a direct connection), it calls `Gateway::proxy_bind()` and hands it over to the HTTPProxy module for processing.

#### 2. L7 HTTP Layer Flow

1. `Gateway::proxy()` invokes the HTTP Server module from `hyper-util` to read and parse HTTP request headers. After parsing is complete, it calls back into `HTTPProxy::proxy()`.

#### 3. L8 AI Proxy Route Layer

1. `HTTPProxy::proxy_internal()` executes various policies and routing logic, eventually invoking `HTTPProxy::attempt_upstream()` to make a call to the upstream (which, under the current configuration, is the LLM AI Provider backend).

#### 4. Upstream (Backend) Call

1. `HTTPProxy::make_backend_call()` uses the HTTP Client module from `hyper-util` to construct and send an HTTP request to the upstream. This includes connection pool management logic.