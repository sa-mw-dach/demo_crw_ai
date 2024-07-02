Running on Openshift

oc new-build --name js-console --binary --strategy source --image-stream httpd
oc start-build js-console --from-dir demos/07_keycloak/js-console/src --follow
oc new-app --image-stream=js-console:latest
oc expose svc/js-console

Then secure the resulting route and set TLS termination to edge.
