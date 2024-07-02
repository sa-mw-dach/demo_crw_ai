# Demo 07 - Keycloak

## Introduction
...

## Requirements
...

## Instalation & configuration of Keycloak

1) Install RHBK operator

1) Create new project: `demo_keycloak`

1) Create OpenShift resources

    Secret: 
    ```
    apiVersion: v1
    kind: Secret
    metadata:
        name: keycloak-db-secret
        type: Opaque 
    stringData: 
        username: postgres
        password: postgres
    ```

    Database & corresponding service:
    ```
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
    name: postgresql-db
    spec:
    serviceName: postgresql-db-service
    selector:
        matchLabels:
        app: postgresql-db
    replicas: 1
    template:
        metadata:
        labels:
            app: postgresql-db
        spec:
        containers:
            - name: postgresql-db
            image: postgres:latest
            volumeMounts:
                - mountPath: /data
                name: cache-volume
            env:
                - name: POSTGRES_PASSWORD
                value: postgres
                - name: PGDATA
                value: /data/pgdata
                - name: POSTGRES_DB
                value: keycloak
        volumes:
            - name: cache-volume
            emptyDir: {}
    ---
    apiVersion: v1
    kind: Service
    metadata:
    name: postgres-db
    spec:
    selector:
        app: postgresql-db
    type: LoadBalancer
    ports:
    - port: 5432
        targetPort: 5432
    ```

    Keycloak instance & route:
    ```
    apiVersion: k8s.keycloak.org/v2alpha1
    kind: Keycloak
    metadata:
    name: example-kc
    spec:
    instances: 1
    db:
        vendor: postgres
        host: postgres-db
        usernameSecret:
        name: keycloak-db-secret
        key: username
        passwordSecret:
        name: keycloak-db-secret
        key: password
    http:
        httpEnabled: true
    hostname:
        strict: false
        strictBackchannel: false
    ---
    kind: Route
    apiVersion: route.openshift.io/v1
    metadata:
    name: example-kc-route
    labels:
        app: keycloak
        app.kubernetes.io/instance: example-kc
        app.kubernetes.io/managed-by: keycloak-operator
    spec:
    to:
        kind: Service
        name: example-kc-service
    tls: null
    port:
        targetPort: http
    ```

1) Obtain admin credentials from secret... initial-admin

1) Create demojs realm using GUI

1) Set realm login settings:
    - user registration: true
    - verify email: true

## Setup email
1) Open empty workspace

1) Setup mailcatcher:
    ```
    oc project demo_keycloak
    oc new-app quay.io/sshaaf/mailcatcher --name=mailcatcher
    oc expose svc/mailcatcher --port 8080
    ```

1) Configure Keycloak accordingly

    1) Configure email of admin user in keycloak: set to admin@redhat.com

    1) Set realm email settings: 
        - From email: sender@redhat.com
        - From display name: sender
        - Host: mailcatcher
        - Port 1025

    ==> save & test connection

1) Check, if SSO works!!! 

    ==> Call http://URL/realms/demojs/account


## Installation & configuration of application
1) Clone repo
    ```
    git clone https://github.com/sa-mw-dach/dev_demos.git
    cd dev_demos/
    git checkout feature/keycloak
    ```

1) Obtain keycloak URL: `oc get route example-kc-route`

1) Adapt 2 files, adding the proper keycloak URL: 
    1) 'js-console/src/index.html' and 
    1) 'keycloak.json'

1) Execute oc commands in 'js-console/README.md' to roll out app

1) Configure keycloak for app:
    - `oc get route js-console`
    - Clients --> create and use route URL
        - Client Type: openid-connect
        - Client ID: js-console
        - Route URL: see above, using http://
        - Home URL: leave blank

1) See app in action and create one user: `user1`

## Add avatar

1) Ensure you are logged in as Admin

1) Select the user you registered with earlier, `user1`, and not the Admin user.

1) Click on attributes and add key `avatar_url` with value https://upload.wikimedia.org/wikipedia/commons/2/29/Keycloak_Logo.png

1) Click Add followed by Save.

1) Click on Client Scopes then Create and fill with
    ```
    Name: avatar
    Consent Screen Text: Avatar
    ```
    Click save

1) Click on Mappers then Create.
    ```
    Name: avatar
    Mapper Type: User Attribute
    User Attribute avatar_url
    Token Claim Name: avatar_url
    Claim JSON Type: String
    ```
    Click Save

1) Go to Clients and select js-console. Select Client Scopes and add avatar.

1) See result in app.


## Requiring consent

1) Activate in client and show result (refresh).


## GitHub

1) Click on Identity Providers

1) Select GitHub and create new item

1) Goto GitHub homepage.

    Homepage URL: http://KEYCLOAK_URL

    Authorization callback URL: http://KEYCLOAK_URL/realms/demojs/broker/github/endpoint

1) Create new client secret in GitHub

1) In Keycloak in GitHub IdP, go to Mappers and add mapper:
    ```
    Name: avatar
    Mapper Type: Attribute Importer
    Social Profile JSON Field Path: avatar_url
    User Attribute Name: avatar_url
    ```
1) Show result and login with GitHub.

