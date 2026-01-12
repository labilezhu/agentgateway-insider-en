# Configuring MCP Proxying

As a key protocol in the AI Agent ecosystem, MCP support is one of Agentgateway’s core capabilities. This article documents my experience and observations while proxying MCP traffic with Agentgateway. It is also a summary of lessons learned after spending several days debugging why my browser could not connect to the Agentgateway MCP endpoint.

The official [Agentgateway documentation](https://agentgateway.dev/docs/) does describe how to configure MCP, but at the moment the content is fairly “hello world”–level. In practice, most of my exploration involved reading the Agentgateway source code and relevant standards, including specifications related to W3C and MCP. In some cases, I also had to use Chrome DevTools to debug JavaScript and network traffic.

> This article is adapted from the “MCP Proxy Configuration” chapter of my open-source book *Agentgateway Insider*, with additional editing and expansion. For more detailed discussion, please refer to the book.

## Basic MCP Configuration

### STDIO MCP Proxy

Many MCP tools only support running via STDIO. As a proxy and protocol transformer, Agentgateway can adapt such locally bound STDIO MCP tools into Streamable MCP services that can be accessed remotely. Even when everything runs on the same machine, this capability is extremely useful in containerized or virtualized environments, where direct STDIO access is impractical.

A classic example is the Prometheus MCP tool [prometheus-mcp-server](https://github.com/pab1it0/prometheus-mcp-server), which can only run locally via STDIO. Once proxied through Agentgateway, remote AI agents can invoke it via the Streamable MCP protocol.

```yaml
config:

binds:
- port: 3101
  listeners:
  - name: mcp-listener
    hostname: your-host
    routes:
    - name: prometheus
      matches:
      - path:
          pathPrefix: "/mcp/prometheus"
      policies:
        csrf:
          additionalOrigins:
            - http://your-web-ui-host-origin/
        cors:
          allowOrigins:
            - "*"
          allowHeaders:
            - "*"
            - mcp-protocol-version
            - content-type
            - cache-control
            - Accept
            - mcp-session-id
          allowCredentials: true
          allowMethods: ["GET", "POST", "OPTIONS"]
          maxAge: 100s
          exposeHeaders:
          - "*"
          - mcp-session-id
      backends:
      - mcp:
          targets:
          - name: prometheus
            stdio:
              cmd: docker
              args: ["run","-i","--rm","-e","PROMETHEUS_URL=http://192.168.1.74:9090","ghcr.io/pab1it0/prometheus-mcp-server:latest"]
```

The `cors` and `csrf` sections will be discussed in detail later. For now, the key part is the backend configuration, which is relatively straightforward.

The `pathPrefix` here enables multiplexing: under the same bind port, different URL paths are routed to different MCP backend servers.

### Streamable MCP Proxy

```yaml
config:

binds:
- port: 3101
  listeners:
  - name: mcp-listener
    hostname: your-host
    routes:
    - name: home-assistant-route
      matches:
      - path:
          pathPrefix: "/mcp/home-assistant"
      policies:
        csrf:
          additionalOrigins:
            - http://your-web-ui-host-origin/
        cors:
          allowOrigins:
            - "*"
          allowHeaders:
            - "*"
            - mcp-protocol-version
            - content-type
            - cache-control
            - Accept
            - mcp-session-id
          allowCredentials: true
          allowMethods: ["GET", "POST", "OPTIONS"]
          maxAge: 100s
          exposeHeaders:
          - "*"
          - mcp-session-id
        requestHeaderModifier:
          add:
            Authorization: "Bearer fake"
      backends:
      - mcp:
          targets:
          - name: home-assistant
            mcp:
              host: http://192.168.1.68:8123/api/mcp
```

Compared to an STDIO-based MCP server, the main difference here is the additional `Authorization: Bearer fake` header. This relates to MCP authentication, which I have not yet studied in depth and plan to explore further in the future.

## Security Settings That Affect Access

There is a saying: 

> Just because you do not take an interest in politics doesn't mean politics won't take an interest in you. 
>
> -- [Pericles](https://www.goodreads.com/quotes/19444-just-because-you-do-not-take-an-interest-in-politics)

The same applies to digital security. Even if you do not actively think about security policies, they may still block your access. Many systems apply restrictive defaults, and Agentgateway’s MCP proxy is no exception. I personally ran into this and spent several days debugging before identifying the root cause.

> Note: I am not a security expert, and my understanding of frontend technologies is limited. The configurations below are intended for development environments only. Use them with caution in production.

### CORS Configuration

> https://agentgateway.dev/docs/configuration/security/cors/

Many chat-agent style web applications, due to MCP server reachability and OAuth flows that require browser participation, access MCP servers directly from the browser rather than via a backend service. In such cases, CORS (Cross-Origin Resource Sharing)  must be considered. This applies to tools like the MCP Inspector as well as Agentgateway’s built-in Playground.

If you are new to frontend development, it helps to understand what CORS is. From a backend developer’s perspective, CORS is a browser-enforced security mechanism that controls cross-origin HTTP requests. The rules are declared by the server using specific HTTP headers, but enforcement happens entirely in the browser.

#### What Is an Origin?

> Origin: https://developer.mozilla.org/en-US/docs/Glossary/Origin

An `Origin` is defined by the `scheme` (protocol), `hostname` (domain), and `port` of a URL. Two resources share the same Origin only if all three match. Many web operations are restricted to same-origin access unless explicitly relaxed via CORS.

#### What Is CORS?

> CORS: https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS

CORS is a browser security mechanism that allows servers to declare which Origins are permitted to access resources. Importantly, CORS rules are enforced by browsers, not by servers. If a request bypasses the browser and is sent directly to the server—for example, using curl—the server will not enforce CORS restrictions, which can be confusing during debugging.

Common preflight request headers include:

- Origin
- Access-Control-Request-Method
- Access-Control-Request-Headers

Relevant response headers include:

- Access-Control-Allow-Origin
- Access-Control-Allow-Methods
- Access-Control-Allow-Headers
- Access-Control-Max-Age
- Access-Control-Allow-Credentials
- Access-Control-Expose-Headers

#### Agentgateway CORS Configuration

Here is the documentation of Agentgateway's CORS configuaration:

> https://agentgateway.dev/docs/configuration/security/cors/

```yaml
cors:
  allowOrigins:
    - "*"
  allowHeaders:
    - "*"
    - mcp-protocol-version
    - content-type
    - cache-control
    - Accept
    - mcp-session-id
  allowCredentials: true
  allowMethods: ["GET", "POST", "OPTIONS"]
  maxAge: 100s
  exposeHeaders:
  - "*"
  - mcp-session-id
```

### CSRF Configuration

#### What Is CSRF?

> https://developer.mozilla.org/en-US/docs/Web/Security/Attacks/CSRF

CSRF (Cross-Site Request Forgery) is a broad concept, but Agentgateway uses only a small subset of related mechanisms.

#### Agentgateway CSRF Configuration

> https://agentgateway.dev/docs/configuration/security/csrf/

```yaml
csrf:
  additionalOrigins:
    - http://your-web-ui-host-origin/
```

Although the Agentgateway documentation may appear complex, in practice the key requirement is simply to include the cross-site origin in `additionalOrigins`.
