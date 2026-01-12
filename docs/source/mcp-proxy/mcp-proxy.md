# Proxying MCP

As a key protocol in the AI Agent ecosystem, MCP support is one of Agentgateway’s core capabilities. This article documents my experience and observations while proxying MCP traffic with Agentgateway. It is also a summary of lessons learned after spending several days debugging why my browser could not connect to the Agentgateway MCP endpoint.

The official [Agentgateway documentation](https://agentgateway.dev/docs/) does describe how to configure MCP, but at the moment the content is fairly “hello world”–level. In practice, most of my exploration involved reading the Agentgateway source code and relevant standards, including specifications related to W3C and MCP. In some cases, I also had to use Chrome DevTools to debug JavaScript and network traffic.



```{toctree}
mcp-proxy-conf/mcp-proxy-conf.md
```




