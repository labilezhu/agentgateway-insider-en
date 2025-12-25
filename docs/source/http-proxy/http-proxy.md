# Http Proxy 主流程

本质上说， Agentgateway 是一个 HTTP Proxy ，只是在 HTTP 之上增加了对 AI(LLM/MCP/A2A) 状态化协议的支持。所以分析 HTTP Proxy 层的主流程，就是分析 Agentgateway 的主流程。

## Http Proxy 分析示例

### Agentgateway 配置文件

本节分析的 Http Proxy 主流程，基于以下 Agentgateway 配置文件

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


### 触发 LLM 请求
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

返回：
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

### Http Proxy 主流程图


#### 1. L4 连接 accept 流程图

通过 vscode Debug ，可以看到 Http Proxy 主流程如下图所示：

:::{figure-md}
:class: full-width

<img src="agentgateway-httpproxy.drawio.svg" alt="图：Http Proxy 主流程">

*图：Http Proxy 主流程*  
:::
*[用 Draw.io 打开](https://app.diagrams.net/?ui=sketch#Uhttps%3A%2F%2Fagentgateway-insider.mygraphql.com%2Fzh_CN%2Flatest%2F_images%2Fagentgateway-httpproxy.drawio.svg)*

> *图中带 ⚓ 图标，双击链接到本地 vscode 的源码。见 {ref}`diagram-vscode-code-link-setup` 一节*




可见，主要的 http proxy 逻辑放在 `Gateway` 结构体中。其中有两个关键 spawn 点：
1. `Gateway::run()` 中，为每个监听端口 spawn 一个 `Gateway::run_bind()` async future。这个任务负责监听端口，`accept` 新连接。
2. `Gateway::run_bind()` 在 `accept` 新连接后，每个连接 spawn 一个 `Gateway::handle_tunnel()` async future。 这个任务负责处理每个连接的所有事件。
  - 如果连接的 tunnel 协议是 `Direct`(即直接连接) ，就调用  `Gateway::proxy_bind()` 交由 HTTPProxy 模块处理 。


#### 2. L7 HTTP 层流程

1. `Gateway::proxy()` 调用  `hyper-util` 的 HTTP Server 模块，读取和解释 HTTP 请求头。解释完成后回调 到 `HTTPProxy::proxy()`


#### 3. L8 AI Proxy Route 层

1. `HTTPProxy::proxy_internal()` 执行各种 Policy 和 Route 。直到 `HTTPProxy::attempt_upstream()` 向 upstream(在当前配置下是 LLM AI Provider backend) 发起调用。


#### 4. Upstream(backend) call

1. `HTTPProxy::make_backend_call()` 调用  `hyper-util` 的 HTTP Client 模块，构建并发送 HTTP 请求到 upstream。其中有连接池的管理逻辑。
