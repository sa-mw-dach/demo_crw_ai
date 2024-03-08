# Demo 05 - Personal AI Assistant for Application Development

## Introduction
A proper introduction for this demo plus a video showcasing the usage of a personal AI assistant for application development that doesn't phone home can be found [here](https://www.opensourcerers.org/?p=7567).


## Requirements
In order to be able to run the demo, the following software components need to be available and will be installed/configured in the following paragraphs:

* Red Hat OpenShift (tested on version 4.11.57)
* Red Hat OpenShift Dev Spaces (tested on version 3.10.1)
* Continue VS Code extension (tested on version 0.9.79)
* Local LLM Code LLama (with 13 billion parameters) via Ollama
* Optional when using GPUs:
    * NVIDIA GPU Operator (tested on version 23.9.1)
    * Node Feature Discovery Operator (tested on version 4.11.0) 


## Installation of Continue in OpenShift Dev Spaces
[Continue](https://continue.dev) describes itself as "an open-source autopilot for software development". It is an IDE Extension and brings the power of ChatGPT and other Larga-Language Models (LLM) to VS Code. In this section, Continue is installed in OpenShift Dev Spaces in a way that supports on-prem air-gapped usage.

Please note that the installation of VS code extensions can be automated using [devfiles](https://devfile.io/), as is showcased also below.

Basically the instructions for installing Continue in an on-prem air-gapped environment are followed, as can be found [here](https://continue.dev/docs/walkthroughs/running-continue-without-internet). 

1) Open OpenShift Dev Spaces & create an "Empty Workspace" (this will use the Universal Developer Image, [UDI](https://github.com/devfile/developer-images)).

1) Download the VS Code extension [here](https://open-vsx.org/extension/Continue/continue) (download "Linux x64") and use it directly in OpenShift Dev Spaces, if internet connection is available, or store it in your artifact store of choice, from which you have access in OpenShift.

1) In OpenShift Dev Spaces, go to the extensions menu at the left, click on the three dots at the top of the "Extensions" page and select "Install from VSIX". Now select the previously downloaded Continue VSIX file (e.g. `Continue.continue-0.1.26@linux-x64.vsix`) and hit "ok".

1) [Optional] Test Continue, if an internet connection is available.

    As default, Continue comes with free trial models, such as GPT-4 Vision, GPT-3.5-Turbo, Gemini Pro and Codellama 70b, that connect to the vendor's model server using Continue's API key. Thus Continue is ready to be used, in case an internet connection is available.

    [This page](https://continue.dev/docs/how-to-use-continue) contains information on how to use Continue and can be used to test Continue's capabilities.


## Adapt Continue to use a local LLM

Since the ultimate goal of this demo is to have a personal AI assistant for application development in a private on-prem air-gapped environment, the next step is to use a local LLM within Continue.

When looking into the [documentation](https://continue.dev/docs/model-setup/select-model), multiple local models can be used with Continue. For the demo at hand, the Ollama framework is used as interface to Continue, which is able to run the local LLMs as described [here](https://github.com/jmorganca/ollama#model-library) and [here](https://ollama.ai/library). 

The Ollama web server that provides communication with the local LLMs is deployed in OpenShift as follows:

1) Inside the OpenShift Dev Spaces workspace, open a terminal and clone the following git repo: `https://github.com/sa-mw-dach/dev_demos.git`

1) In the terminal, login to OpenShift and go to the namespace/project, where the OpenShift Dev Spaces workspace is running (e.g. "user1-devspaces").

1) Deploy the resources for the Ollama web server (i.e. a PVC for the Ollama data, a deployment comprising the Ollama web server in a container as well as a service that provides access to the web server) in the proper namespace/project as mentioned above by calling

    ```
    oc apply -f /projects/dev_demos/demos/05_ai_assistant/ollama-deployment.yaml
    ```

    Note that here a container image from docker.io is pulled. In an air-gapped environment, one needs to pull this image from the container image registry of choice that is available from within the OpenShift cluster.

    If the pod cannot be rolled out, please check the logs of the corresponding ReplicaSet. It may be that your namespace has a LimitRange configured with a maximum cpu or memory usage that is too low.

1) Now download the local LLM "codellama:13b" into the Ollama web server by opening a terminal in the OpenShift Dev Spaces workspace and executing

    ```
    curl -X POST http://ollama:11434/api/pull -d '{"name": "codellama:13b"}'
    ```

    This pull requires the Ollama web server to have an internet connection. In an air-gapped environment, create a new container image where the desired LLMs are inside and use this container image in the `ollama-deployment.yaml`.

1) Lastly, the local LLM needs to be incorporated into Continue. Thus go to Continue's config.json (`~/.continue/config.json`) and add the Ollama web server as described [here](https://continue.dev/docs/reference/Model%20Providers/ollama) by adding

    ```yaml
    {
    "models": [
        ...
        {
        "title": "CodeLlama-13b",
        "model": "codellama:13b",
        "apiBase": "http://ollama:11434",
        "provider": "ollama"
        }
    ],
    ...
    }
    ```

    This concludes the steps to incorporate a local LLM into Continue and OpenShift Dev Spaces and yields the personal AI assistant for application development in a private on-prem air-gapped environment that can be used as described on [this page](https://continue.dev/docs/how-to-use-continue).


## Alternative: Use local LLM directly within OpenShift Dev Spaces
Instead of deploying the Ollama web server directly in OpenShift as described in the previous paragraph, it can also be deployed, along with the Continue extension itself, easily and conveniently in an OpenShift Dev Spaces workspace. 

1) Copy the content of the `devspaces` folder into the root folder of a git repository of your choice.
1) Adapt the [devfile](devspaces/devfile.yaml) in your own git repo to point to the proper location of the continue-config.json: `/projects/YOUR_REPO_NAME/continue-config.json`.

By using the devfile in your own git repo for creating a new workspace, the Continue extension is automatically installed and configured upon start of the workspace and the following two containers are being included:

`udi`: A container based on the Universal Developer Image as described above, which is used for all developement tasks (like applying terminal commands).

`ollama`: A container based on the [Ollama container image](https://hub.docker.com/r/ollama/ollama) that comprises the Ollama web server and is additonally configured to leverage GPUs by setting `nvidia.com/gpu: 1` in the container's resource request. Due to that configuration in the devfile, the ollama container is being deployed within the workspace pod on the OpenShift cluster that hosts a GPU, which significantly accelerates the inference step of the local LLM and hence tremendously improves the performance of the personal AI assistant for developers. Also, the codellama-13b model is being pulled automatically and can be immediately used from within Continue.

Note that running a LLM in your own OpenShift cluster is mostly only fun, if you are using a GPU. If no GPU is available, please refer to LLMs with lower resource requirements (see [here](https://github.com/jmorganca/ollama#model-library)).
