# Demo 05 - Personal AI Assistant for Application Development

## Introduction
A proper introduction for this demo plus a video showcasing the usage of a personal AI assistant for application development that doesn't phone home can be found [here](https://www.opensourcerers.org/?p=7567).


## Requirements
In order to be able to run the demo, the following software components need to be available and will be installed/configured in the following paragraphs:

* Red Hat OpenShift (tested on version 4.11.50)
* Red Hat OpenShift Dev Spaces (tested on version 3.9)
* Continue VS Code extension (tested on version 0.1.26)
* Local LLM Code LLama (with 13 billion parameters) via Ollama
* Optional when using GPUs:
    * NVIDIA GPU Operator (tested on version 23.6.1)
    * Node Feature Discovery Operator (tested on version 4.11.0) 


## Installation of Continue in OpenShift Dev Spaces
[Continue](https://continue.dev) describes itself as "an open-source autopilot for software development". It is an IDE Extension and brings the power of ChatGPT and other Larga-Language Models (LLM) to VS Code. In this section, Continue is installed in OpenShift Dev Spaces in a way that supports on-prem air-gapped usage.

Please note that the installation of VS code extensions can be automated using [devfiles](https://devfile.io/), as is showcased also below.

Basically the instructions for installing Continue in an on-prem air-gapped environment are followed, as can be found [here](https://continue.dev/docs/walkthroughs/running-continue-without-internet). 

1) Open OpenShift Dev Spaces & create an "Empty Workspace" (this will use the Universal Developer Image, [UDI](https://github.com/devfile/developer-images)).

1) Download the VS Code extension [here](https://open-vsx.org/extension/Continue/continue) (download "Linux x64") and use it directly in OpenShift Dev Spaces, if internet connection is available, or store it in your artifact store of choice, from which you have access in OpenShift.

1) In OpenShift Dev Spaces, go to the extensions menu at the left, click on the three dots at the top of the "Extensions" page and select "Install from VSIX". Now select the previously downloaded Continue VSIX file (e.g. `Continue.continue-0.1.26@linux-x64.vsix`) and hit "ok".

1) Since the AI assistent shall run in an air-gapped environment, a "Continue Server" needs to be run locally. 

    For experimentation purposes, the Continue server is in the following run locally inside the UDI container. Please note that in a productive developer environment, one would run the Continue server in an automated way for example in a container attached to one's workspace.

    - First go to the Continue VS Code extension settings and select "Manually Running Server". Then restart the OpenShift Dev Spaces workspace.

    - Next, inside the OpenShift Dev Spaces workspace, open a terminal and then download the Continue server (with version 0.1.73 that fits to the Continue extension version 0.1.26) from PyPI and run it using 
        ```
        pip install continuedev==0.1.73
        python -m continuedev
        ```

1) [Optional] Test Continue, if an internet connection is available.

    As default, Continue comes with a GPT4 Free Trial model that connects to OpenAI using Continue's API key. Thus Continue is ready to be used, in case an internet connection is available.

    [This page](https://continue.dev/docs/how-to-use-continue) contains information on how to use Continue and can be used to test Continue's capabilities.


## Adapt Continue to use a local LLM

Since the ultimate goal of this demo is to have a personal AI assistant for application development in a private on-prem air-gapped environment, the next step is to use a local LLM within Continue.

When looking into the [documentation](https://continue.dev/docs/customization/models), multiple local models can be used with Continue. For the demo at hand, the Ollama framework is used as interface to Continue, which is able to run the local LLMs as described [here](https://github.com/jmorganca/ollama#model-library) and [here](https://ollama.ai/library). 

The Ollama web server that provides communication with the local LLMs is deployed in OpenShift as follows:

1) Inside the OpenShift Dev Spaces workspace, open a terminal and clone the following git repo: `https://github.com/sa-mw-dach/dev_demos.git`

1) In the terminal, login to OpenShift and go to the namespace/project, where the OpenShift Dev Spaces workspace is running (e.g. "user1-devspaces").

1) Deploy the resources for the Ollama web server (i.e. a PVC for the Ollama data, a deployment comprising the Ollama web server in a container as well as a service that provides access to the web server) in the proper namespace/project as mentioned above by calling

    ```
    oc apply -f /projects/dev_demos/demos/05_ai_assistant/ollama-deployment.yaml
    ```

    Note that here a container image from docker.io is pulled. In an air-gapped environment, one needs to pull this image from the container image registry of choice that is available from within the OpenShift cluster.

1) Now download the local LLM "codellama:13b" into the Ollama web server by opening a terminal in the OpenShift Dev Spaces workspace and executing

    ```
    curl -X POST http://ollama:11434/api/pull -d '{"name": "codellama:13b"}'
    ```

    This pull requires the Ollama web server to have an internet connection. In an air-gapped environment, create a new container image where the desired LLMs are inside and use this container image in the `ollama-deployment.yaml`.

1) Lastly, the local LLM needs to be incorporated into Continue. Thus go to Continue's config.py (`~/.continue/config.py`) and add the Ollama web server as described [here](https://continue.dev/docs/reference/Models/ollama) by adding

    ```python
    from continuedev.libs.llm.ollama import Ollama

    ...

    config = ContinueConfig(
        ...
        models=Models(
            default=Ollama(
                model="codellama:13b",
                server_url="http://ollama:11434"
            )
        )
    )
    ```

    An example of an entire `~/.continue/config.py` file can be found [here](config.py).

    This concludes the steps to incorporate a local LLM into Continue and OpenShift Dev Spaces and yields the personal AI assistant for application development in a private on-prem air-gapped environment that can be used as described on [this page](https://continue.dev/docs/how-to-use-continue).


## Alternative: Use local LLM directly within OpenShift Dev Spaces
Instead of deploying the Ollama web server directly in OpenShift as described in the previous paragraph, it can also be deployed in the OpenShift Dev Spaces workspace. By using the devfile provided [here](devfile.yaml) for creating a new workspace, the following two conatiners are being started:

`udi`: A container based on the Universal Developer Image as described above, which hosts the Continue server and is used for all other developement tasks as well (like applying terminal commands).

`ollama`: A container based on the [Ollama container image](https://hub.docker.com/r/ollama/ollama) that comprises the Ollama web server and is additonally configured to leverage GPUs by setting `nvidia.com/gpu: 1` in the container's resource request. Due to that configuration in the devfile, the ollama container (and therewith the entire pod) is being deployed on an OpenShift worker node that hosts a GPU, which significantly accelerates the inference step of the local LLM and hence tremendously improves the performance of the personal AI assistant for developers.

Please note that when running the Ollama web server directly withing a workspace using the [devfile.yaml](devfile.yaml), the basic installation and configuration steps as described in the other paragraphs of this page remain the same, despite that the resources defined in `ollama-deplyoment.yaml` (see previous paragrah) don't need to be deployed to OpenShift separately.
