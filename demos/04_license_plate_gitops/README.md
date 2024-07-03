# Demo 04 - Integrating an AI/ML model into an application

## Introduction
The fourth demo of this series is again based on the "Red Hat OpenShift Data Science Workshop - Licence plate recognition"[^license_plate_desc] and shows some aspects of integrating an AI/ML model into an app using pipelines and a GitOps approach.

## Requirements
In order to be able to run the demo, the following requirements need to be fullfilled:
* Red Hat OpenShift (tested on version 4.12)
* Red Hat OpenShift Dev Spaces (tested on version 3.8)
* Red Hat OpenShift Pipelines (tested on version 1.10.4)
* Red Hat OpenShift GitOps (tested on version 1.8.3)
* Optional when using GPUs: NVIDIA GPU Operator (tested on version 23.6.1) & NFD (tested on version 4.11.0) 

## First steps
1) Open OpenShift Dev Spaces & create an "Empty Workspace" (this will use the Universal Developer Image, UDI)
1) Inside the newly created workspace, open a terminal and clone the following git repo: `https://github.com/sa-mw-dach/dev_demos.git`
1) Inside the terminal, login to OpenShift

**Important note**: If modifications want to be done on the repo in order to test modifying the model or application later, the repo `https://github.com/sa-mw-dach/dev_demos.git` needs to be forked and the changes need to be done there, eventually also creating a dediated branch inside the forked repo. Additionally, in the entire code base in folder `demos/04_license_plate_gitops` the URL and branch (main) of the original repo need to be replaced by the URL and branch of the forked repo.

## Create a container image of the AI/ML model
In the following, the license plate model is baked into a container image and stored in the OpenShift-internal integrated container image registry.

Working directory for the following steps is `demos/04_license_plate_gitops/a_model/`.

1) Familiarize yourself with the `src` folder, which comprises some slightly modified version of the "Red Hat OpenShift Data Science Workshop - Licence plate recognition"[^license_plate_desc]. 

1) **IMPORTANT FOR WORKSHOP**

    Do a search & replace, searching for `gitops-demo` and replacing it with `userXXX-gitops-demo` in the entire repo!

1) Create an OpenShift project/namespace `gitops-demo` and switch to it by executing
    ```
    oc apply -f pipeline/model-1-namespace.yaml
    oc project gitops-demo
    ```

1) Create a Persistent Volume Claim (PVC), which will be needed later for executing the pipeline:
    ```
    oc apply -f pipeline/model-2-pvc.yaml
    ```

1) Now the pipeline for creating an image out of the model can be added to OpenShift Pipelines by
    ```
    oc apply -f pipeline/model-3-pipeline.yaml
    ```
    Go to the OpenShift Console and you can find the newly added pipeline `model-pipeline` under `Pipelines` in the left navigation bar.

1) In order to create the image go the newly created pipeline and start it. As parameters choose a version tag, e.g. `v1` and select the PersistentVolumeClaim that has been added before.

    The image with the model from the `src` of the git repo can now be found under the Administration View --> Builds --> ImageStreams. When selecting the name of the image `licenseplate` in the list, one can find the image tags at the bottom of the page.

1) Now the model itself or simply some version variable (for demonstration purposes) can be modified in the `src` folder. Afterwards the code is commited and pushed to the repo (for that you need to have the repo being forked as is explained above). Then the pipeline can be run again using a new version tag, e.g. `v2`. 

    When going to the `licensplate` repo under View --> Builds --> ImageStreams, one can see both images with the respective tags. 


## Rollout the application with the AI/ML model
Having multiple versions of an AI/ML model doesn't mean that all models are going to be deployed to all environments. On the contrary, when developing and operating an application that is enriched with an AI/ML model, one wants to explicitly specify which version of the model is used in which environment. This can conveniently be done using a GitOps approach, which will be demonstrated in this section.

Working directory for the following steps is `demos/04_license_plate_gitops/b_app/`.

1) Familiarize yourself with the `src` folder, which comprises the code for the "application", which is simply a Flask app that sends a request to the license plate model with a test image `Cars374.png`.

1) Switch to the `openshift-gitops` project/namespace and add the GitOps application that will deploy the demo application, containg the web server for the license plate model (`licenseplate`) and the web server that sends a test request to the model (`application`) and outputs it.

    ```
    oc project openshift-gitops
    oc apply -f gitops/app.yaml
    ```

    Note that the GitOps app is created in the `openshift-gitops` project/namespace and the application is deployed in the `gitops-demo` project/namespace.

1) Login to OpenShift GitOps (ArgoCD) and see the GitOps application as it's syncing the git repo and deploying the manifests in the `manifests` folder to the OpenShift cluster.

1) In the OpenShift console, go to Developer View --> Topology and inspect the two items of the newly created application, i.e. the `licenseplate` and `application` deployments. When clicking on the arrow at the top right of the `application` deployment, a new browser tab opens an one can see the start page of the demo app, showing the jsons string `{"app status":"ok"}`.

    Now add to the URL a `/test` string and go to that address. The resulting json string will look like `{"model version":"v1", "THE_PREDICTION_OF_THE_MODEL"}`, if `v1` is the version tag used.

1) Assume that the second version of the model with version tag `v2` has been validated and shall be incorporated in the application. Go to file `manifests/model-1-deployment.yaml`, where the model to be used in the application is defined. Search for the image tag `v1` and replace it with `v2`.

    After commiting and pushing this change to the git repo, OpenShift GitOps will compare the version tag inside the git repo with the deployment in the OpenShift Cluster and detect a change. Subsequently, it modifes the Cluster configuration so that it matches the definitions in the git repo. Meaning that the version `v2' of the model will be incorporated into the app.

    Now go again to the app URL `/test`. The resulting json string will look like `{"model version":"v2", "THE_PREDICTION_OF_THE_MODEL"}`, i.e. showing the second version of the license plate model as was desired.


[^license_plate_desc]: https://rh-aiservices-bu.github.io/licence-plate-workshop/
