# Development environment setup and configuration

This guide recommends Visual Studio Code as the primary tool for reading and debugging the code. Using a VS Code development container is recommended because this repository already includes a `.devcontainer.json`. Running the development environment inside a container ensures consistent dependencies, toolchains, and versions across machines, reducing setup and coordination overhead.

(diagram-vscode-code-link-setup)=
## Source diagrams linking to VS Code source
As mentioned in {ref}`/ch0/index.md:interactive-book`, the diagrams in this book include an anchor icon (⚓) that you can double-click to jump to the corresponding source location in your local VS Code workspace. This provides a seamless navigation experience between diagrams and code.

Due to a limitation of the Draw.io VS Code extension, Draw.io files must be placed at a path in the workspace that matches the paths expected by the diagrams. I keep the diagrams and resource files used in this book in the `pub-diy` repository.

1. Install the Draw.io VS Code extension: https://marketplace.visualstudio.com/items\?itemName\=hediet.vscode-drawio

2. Clone the `pub-diy` repository:

```bash
cd ~/
git clone https://github.com/labilezhu/pub-diy.git
```

All diagrams and assets for the book live under the `ai/agentgateway/ag-dev` directory in that repository.

3. Mount the `pub-diy` repository into the development container

Update the Agentgateway repository's `.devcontainer.json` to mount your local `pub-diy` folder into the container, for example:

```json
{
    "image": "mcr.microsoft.com/devcontainers/rust:latest",
    "mounts": [
        "source=/home/your_home/pub-diy,target=/workspaces/agentgateway/diy-log,type=bind,consistency=cached"
    ]
}
```

This mounts `pub-diy` at `/workspaces/agentgateway/diy-log` inside the container. After updating `.devcontainer.json`, run "Rebuild Container" in VS Code. The diagrams and assets will then be available at `/workspaces/agentgateway/diy-log/ai/agentgateway/ag-dev` inside the container.


## Building agentgateway

Agentgateway includes a web management UI at `agentgateway/ui`. The UI must be built separately and requires `npm`. See `ui/README.md` for details. If you are using the VS Code dev container, install npm and build the UI inside the container:

```bash
sudo apt update
sudo apt install npm

npm install
```

## Debugging agentgateway

VS Code will generate a `launch.json` entry similar to the following:

```json
        {
            "type": "lldb",
            "request": "launch",
            "name": "Debug executable 'agentgateway'",
            "cargo": {
                "args": [
                    "build",
                    "--bin=agentgateway",
                    "--package=agentgateway-app",
                    "--features",
                    "agentgateway/ui"
                ],
                "filter": {
                    "name": "agentgateway",
                    "kind": "bin"
                }
            },
            "args": ["--file", "/workspaces/agentgateway/examples/basic/labile-config.yaml"],
            "cwd": "${workspaceFolder}",
        },
```

Note the `--features` flag in the Cargo configuration: this is analogous to conditional compilation flags in other languages. Enabling the `agentgateway/ui` feature activates UI-related code. For example, the following code in `crates/agentgateway/src/app.rs` only runs when the UI feature is enabled:

```rust
    #[cfg(feature = "ui")]
    admin_server.set_admin_handler(Arc::new(crate::ui::UiHandler::new(config.clone())));
    #[cfg(feature = "ui")]
    info!("serving UI at http://{}/ui", config.admin_addr);
```
