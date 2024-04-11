# Demo 07 - Keycloak

## Introduction
...

## Requirements
...

## Instalation

Create new project: demo_keycloak

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

Database:
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

Keycloak instance:
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
```

Keycloak route for service:
```
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

Obtain admin credentials from secret... initial-admin

Create demojs realm in GUI

Open empty workspace

git clone https://github.com/sa-mw-dach/dev_demos.git
cd dev_demos/
git checkout feature/keycloak

