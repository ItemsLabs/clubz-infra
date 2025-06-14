# Repository Structure

- **deploy/**
  - **docker/**
    - start.sh
  - **fanclash-admin/**
    - deployment_qa.yaml
    - ingress_qa.yaml
    - service.yaml
    - servicenew.yaml
  - **fanclash-api/**
    - deployment_qa.yaml
    - ingress_qa.yaml
    - service.yaml
  - **fanclash-event-processor/**
    - deployment_qa.yaml
  - **fcm-pusher/**
    - deployment_qa.yaml
  - **rabbitmp-publisher/**
    - deployment_qa.yaml
- **local-dev/**
  - docker-compose.admin.yaml
  - docker-compose.api.yaml
  - docker-compose.db.yaml
  - docker-compose.event.yaml
- README.md

---

# README.md

# laliga-infra

## Local development

### Requirements

- [Docker](https://docs.docker.com/install/)

And all the `laliga` projects in the same directory where this project is

```bash
- (gameon.app folder)
|- laliga-infra
|- laliga-matchfantasy-admin
|- laliga-matchfantasy-api
|- <etc...>
```

### Setup

Make sure you copy all the `.env.*.example` files and remove the `.example` from
the name.

in the `.env.admin` file you have to complete `FCM_CREDENTIALS` with the json:

```json
{
    "type": "service_account",
    ...
    "universe_domain": "googleapis.com"
}
```

make it one line and sorround it with single quotes and put it on the `.env.admin` file:

```env
FCM_CREDENTIALS='{"type": "service_account","project_id": "laliga- ... .com"}'
```

Alternatively, modify the file `laliga-matchfantasy-admin/mobile_api/settings/base.py`
line with:

```python
    # init fcm
    firebase_admin.initialize_app(credentials.Certificate(json.loads(FCM_CREDENTIALS)))
```

Comment it out and you can run without worrying about this.

## Running the deployment

Everything should be automated by the makefile available on the root folder for
local development, just run:

```bash
make
```

Alternatively, you can also make sure it builds first, if needed (just running
`make` should build already):

```bash
make build
```

And then run (attached) it:

```bash
make run
```

If you need to change a ENV var and you need to do the whole restart, just use:

```bash
make restart
```

All the possibilities are described in the `makefile` itself if you're curious.

### Notes

For the admin project you might need to allow permissions on the `.sh` file:

```bash
chmod +x /<path-to-your-directory-with-the-projects>/laliga-matchfantasy-admin/deploy/docker/start.sh
```

---

## File: `README.md`
- **File Size:** 1765 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** README cleanup

```
# laliga-infra

## Local development

### Requirements

- [Docker](https://docs.docker.com/install/)

And all the `laliga` projects in the same directory where this project is

```bash
- (gameon.app folder)
|- laliga-infra
|- laliga-matchfantasy-admin
|- laliga-matchfantasy-api
|- <etc...>
```

### Setup

Make sure you copy all the `.env.*.example` files and remove the `.example` from
the name.

in the `.env.admin` file you have to complete `FCM_CREDENTIALS` with the json:

```json
{
    "type": "service_account",
    ...
    "universe_domain": "googleapis.com"
}
```

make it one line and sorround it with single quotes and put it on the `.env.admin` file:

```env
FCM_CREDENTIALS='{"type": "service_account","project_id": "laliga- ... .com"}'
```

Alternatively, modify the file `laliga-matchfantasy-admin/mobile_api/settings/base.py`
line with:

```python
    # init fcm
    firebase_admin.initialize_app(credentials.Certificate(json.loads(FCM_CREDENTIALS)))
```

Comment it out and you can run without worrying about this.

## Running the deployment

Everything should be automated by the makefile available on the root folder for
local development, just run:

```bash
make
```

Alternatively, you can also make sure it builds first, if needed (just running
`make` should build already):

```bash
make build
```

And then run (attached) it:

```bash
make run
```

If you need to change a ENV var and you need to do the whole restart, just use:

```bash
make restart
```

All the possibilities are described in the `makefile` itself if you're curious.

### Notes

For the admin project you might need to allow permissions on the `.sh` file:

```bash
chmod +x /<path-to-your-directory-with-the-projects>/laliga-matchfantasy-admin/deploy/docker/start.sh
```

```

## File: `deploy/docker/start.sh`
- **File Size:** 442 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
#!/bin/bash
set -e

if [ "$1" = "server" ]; then
  python manage.py migrate
  python manage.py createcachetable
  python manage.py collectstatic
  gunicorn -b :8000 mobile_api.wsgi --timeout 240
else

  if [ "$1" = "celery-worker" ]; then
    celery -A mobile_api worker -l info
  else

    if [ "$1" = "celery-beat" ]; then
      celery -A mobile_api beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    fi

  fi

fi

```

## File: `deploy/fanclash-admin/deployment_qa.yaml`
- **File Size:** 3820 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Point to DO

```
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: qa
  name: mobile-api
  labels:
    app: mobile-api
    purpose: api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mobile-api
  template:
    metadata:
      labels:
        app: mobile-api
        purpose: api
      spec:
        containers:
        - name: mobile-api
          image: registry.digitalocean.com/gameon-ams3/laliga-matchfantasy-admin:43221d3
          imagePullPolicy: IfNotPresent
          args: ["server"]
          ports:
          - containerPort: 8000
          envFrom:
          - configMapRef:
              name: fanclash-config
          - configMapRef:
              name: mobile-api-config
          - configMapRef:
              name: rmq-config
          - configMapRef:
              name: redis-config
          - secretRef:
              name: fcm-creds
          - secretRef:
              name: opta-feed-creds
          - secretRef:
              name: ortec-creds
          - secretRef:
              name: db-creds
          - secretRef:
              name: rmq-creds
          env:
          - name: DD_SERVICE_NAME
            value: "mobile-api"
          readinessProbe:
            httpGet:
              path: /readiness
              port: 8000
            initialDelaySeconds: 20
            timeoutSeconds: 5
            periodSeconds: 10
            successThreshold: 1
            failureThreshold: 3
          resources:
            requests:
              cpu: "10m"
          volumeMounts:
          - name: kube-api-access-tnndf
            readOnly: true
            mountPath: /var/run/secrets/kubernetes.io/serviceaccount

        - name: celery-worker
          image: registry.digitalocean.com/gameon-ams3/laliga-matchfantasy-admin:43221d3
          imagePullPolicy: IfNotPresent
          args: ["celery-worker"]
          envFrom:
          - configMapRef:
              name: fanclash-config
          - configMapRef:
              name: mobile-api-config
          - configMapRef:
              name: rmq-config
          - configMapRef:
              name: redis-config
          - secretRef:
              name: fcm-creds
          - secretRef:
              name: opta-feed-creds
          - secretRef:
              name: ortec-creds
          - secretRef:
              name: db-creds
          - secretRef:
              name: rmq-creds
          env:
          - name: DD_SERVICE_NAME
            value: "celery-worker"
          volumeMounts:
          - name: kube-api-access-tnndf
            readOnly: true
            mountPath: /var/run/secrets/kubernetes.io/serviceaccount

        - name: celery-beat
          image: registry.digitalocean.com/gameon-ams3/laliga-matchfantasy-admin:43221d3
          imagePullPolicy: IfNotPresent
          args: ["celery-beat"]
          envFrom:
          - configMapRef:
              name: fanclash-config
          - configMapRef:
              name: mobile-api-config
          - configMapRef:
              name: rmq-config
          - configMapRef:
              name: redis-config
          - secretRef:
              name: fcm-creds
          - secretRef:
              name: opta-feed-creds
          - secretRef:
              name: ortec-creds
          - secretRef:
              name: db-creds
          - secretRef:
              name: rmq-creds
          env:
          - name: DD_SERVICE_NAME
            value: "celery-beat"
          volumeMounts:
          - name: kube-api-access-tnndf
            readOnly: true
            mountPath: /var/run/secrets/kubernetes.io/serviceaccount

        volumes:
        - name: kube-api-access-tnndf
          projected:
            sources:
            - serviceAccountToken:
                path: token
                expirationSeconds: 7200
                audience: api
```

## File: `deploy/fanclash-admin/ingress_qa.yaml`
- **File Size:** 1579 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  namespace: qa
  name: "fanclash-admin-ingress"
  labels:
    app: "mobile-api"
    app: "fanclash-api"
    app: "fanclash-api-ws"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
#    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/ingress.allow-http: "true"
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-east-1:736790963086:certificate/d13a002a-ffa6-4b0b-b538-eefba25bbf99
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: https
    service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "ssl"
    service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "3600"
spec:
  # forward all requests to nginx-ingress-controller
  rules:
  - host: fanclash.staging.gamebuild.co
    http:
      paths:
      - path: /admin
        backend:
          serviceName: mobile-api
          servicePort: 80
      - path: /
        backend:
          serviceName: mobile-api
          servicePort: 80

      - path: /api
        backend:
          serviceName: fanclash-api
          servicePort: 80

      - path: /api/ws
        backend:
          serviceName: fanclash-api-ws
          servicePort: 80
```

## File: `deploy/fanclash-admin/service.yaml`
- **File Size:** 205 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
apiVersion: v1
kind: Service
metadata:
  namespace: qa
  name: mobile-api
  labels:
    app: mobile-api
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8000
  selector:
    app: mobile-api
```

## File: `deploy/fanclash-admin/servicenew.yaml`
- **File Size:** 1092 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
# Source: ingress-nginx/templates/controller-service.yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '60'
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true'
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
  labels:
    helm.sh/chart: ingress-nginx-2.0.3
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.32.0
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    - name: https
      port: 443
      protocol: TCP
      targetPort: http
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
```

## File: `deploy/fanclash-api/deployment_qa.yaml`
- **File Size:** 4222 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
apiVersion: apps/v1
kind: Deployment
metadata:
  #namespace: qa
  name: fanclash-api
  labels:
    app: fanclash-api
    purpose: api
    tags.datadoghq.com/env: "dev"
    tags.datadoghq.com/service: "fanclash-api"
    tags.datadoghq.com/version: "latest"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fanclash-api
  minReadySeconds: 15
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: fanclash-api
        purpose: api
        tags.datadoghq.com/env: "qa"
        tags.datadoghq.com/service: "fanclash-api"
        tags.datadoghq.com/version: "latest"
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - mobile-api
                topologyKey: "kubernetes.io/hostname"
      containers:
        - name: fanclash-api
          image: 736790963086.dkr.ecr.us-east-1.amazonaws.com/fanclash-api:latest
          # This setting makes nodes pull the docker image every time before starting the pod. This is useful when debugging, 
          # but should be turned off in production.
          imagePullPolicy: Always
          env:
            - name: ENV_NAME
              value: "qa"
            - name: DD_AGENT_HOST
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: DD_ENV
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['tags.datadoghq.com/env']
            - name: DD_SERVICE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['tags.datadoghq.com/service']
            - name: DD_VERSION
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['tags.datadoghq.com/version']
            - name: DATABASE_NAME
              value: "fanclash"
            - name: DATABASE_USER
              valueFrom:
                secretKeyRef:
                 name: db-creds
                 key: DATABASE_USER
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                 name: db-creds
                 key: DATABASE_PASSWORD
            - name: DATABASE_HOST
              valueFrom:
                secretKeyRef:
                 name: db-creds
                 key: DATABASE_HOST
            - name: RMQ_PASSWORD
              valueFrom:
                secretKeyRef:
                 name: rabbitmq
                 key: RMQ_PASSWORD
            - name: PORT
              value: "8000"
            - name: FCM_CREDENTIALS
              valueFrom:
                secretKeyRef:
                  name: fcm-creds
                  key: FCM_CREDENTIALS
            - name: STATSD_HOST
              value: "telegraf.monitoring.svc"
            - name: STATSD_PORT
              value: "8125"
            - name: TZ
              value: "UTC"
            - name: AMQP_GAMES_EXCHANGE
              value: "games"
            - name: RMQ_HOST
              value: "rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local"
            - name: RMQ_PORT
              value: "5672"
            - name: RMQ_VHOST
              value: "ufl"
            - name: RMQ_USER
              valueFrom:
                secretKeyRef:
                 name: rabbitmq
                 key: RMQ_USER
            - name: RMQ_PASSWORD
              valueFrom:
                secretKeyRef:
                 name: rabbitmq
                 key: RMQ_PASSWORD
            - name: RMQ_GAME_UPDATES_EXCHANGE
              value: "game_updates"
            - name: RMQ_FCM_EXCHANGE
              value: "fcm"
          ports:
            - containerPort: 8000
          readinessProbe:
            httpGet:
              path: /readiness
              port: 8000
            initialDelaySeconds: 5
            timeoutSeconds: 5
          resources:
            requests:
              cpu: 200m
```

## File: `deploy/fanclash-api/ingress_qa.yaml`
- **File Size:** 1229 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  #namespace: qa
  name: "fanclash-ingress"
  labels:
    app: "fanclash-api"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    # nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/ingress.allow-http: "true"

    # kubernetes.io/ingress.class: "alb"
    # alb.ingress.kubernetes.io/scheme: "internet-facing"
    # alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:736790963086:certificate/15f645a7-3a81-4bc3-b9b1-77436d4d169a
    # alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80,"HTTPS": 443}]'

    # alb.ingress.kubernetes.io/healthcheck-path: "/"
    # alb.ingress.kubernetes.io/success-codes: "200,404,400"
spec:
  rules:
  - host: fanclash-api.staging.gamebuild.co
    http:
      paths:
        - path: /
          backend:
            serviceName: fanclash-api
            servicePort: 80

        - path: /api
          backend:
            serviceName: fanclash-api
            servicePort: 80

        - path: /api/ws
          backend:
            serviceName: fanclash-api-ws
            servicePort: 80
```

## File: `deploy/fanclash-api/service.yaml`
- **File Size:** 665 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
apiVersion: v1
kind: Service
metadata:
  #namespace: qa
  name: fanclash-api
  labels:
    app: fanclash-api
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8000
  selector:
    app: fanclash-api
---
apiVersion: v1
kind: Service
metadata:
  #namespace: qa
  name: fanclash-api-combined
  labels:
    app: fanclash-api-combined
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8000
  selector:
    purpose: api
---
apiVersion: v1
kind: Service
metadata:
  #namespace: qa
  name: fanclash-api-ws
  labels:
    app: fanclash-api-ws
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8000
  selector:
    app: fanclash-api
```

## File: `deploy/fanclash-event-processor/deployment_qa.yaml`
- **File Size:** 2414 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
apiVersion: apps/v1
kind: Deployment
metadata:
  #namespace: qa
  name: ufl-event-processor
  labels:
    app: ufl-event-processor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ufl-event-processor
  template:
    metadata:
      labels:
        app: ufl-event-processor
    spec:
      containers:
      - name: processor
        image: 736790963086.dkr.ecr.us-east-1.amazonaws.com/fanclash-event-processor:latest
        # This setting makes nodes pull the docker image every time before starting the pod. This is useful when debugging, 
        # but should be turned off in production.
        imagePullPolicy: IfNotPresent
        env:
            - name: DATABASE_NAME
              value: "fanclash"
            - name: DATABASE_USER
              valueFrom:
                secretKeyRef:
                 name: db-creds
                 key: DATABASE_USER
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                 name: db-creds
                 key: DATABASE_PASSWORD
            - name: DATABASE_HOST
              valueFrom:
                secretKeyRef:
                 name: db-creds
                 key: DATABASE_HOST
            - name: RMQ_HOST
              value: "rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local"
            - name: RMQ_PORT
              value: "5672"
            - name: RMQ_VHOST
              value: "ufl"
            - name: RMQ_USER
              valueFrom:
                secretKeyRef:
                 name: rabbitmq
                 key: RMQ_USER
            - name: RMQ_PASSWORD
              valueFrom:
                secretKeyRef:
                 name: rabbitmq
                 key: RMQ_PASSWORD
            - name: RMQ_MATCH_EVENT_EXCHANGE
              value: "match_event"
            - name: RMQ_PROCESSOR_QUEUE
              value: "match_event:processor"
            - name: RMQ_FCM_EXCHANGE
              value: "fcm"
            - name: RMQ_GAMES_EXCHANGE
              value: "games"
            - name: RMQ_GAMES_LISTENER_QUEUE
              value: "games:event_processor"
            - name: RMQ_SYSTEM_EXCHANGE
              value: "system"
            - name: RMQ_SYSTEM_LISTENER_QUEUE
              value: "system:event_processor"
            - name: RMQ_GAME_UPDATES_EXCHANGE
              value: "game_updates"
        resources:
          requests:
            cpu: 10m

```

## File: `deploy/fcm-pusher/deployment_qa.yaml`
- **File Size:** 1308 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fcm-pusher
  #namespace: qa
  labels:
    app: fcm-pusher
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fcm-pusher
  template:
    metadata:
      labels:
        app: fcm-pusher
    spec:
      containers:
      - name: fcm-pusher
        image: 736790963086.dkr.ecr.us-east-1.amazonaws.com/fanclash-fcm-pusher:latest
        imagePullPolicy: IfNotPresent
        envFrom:
          - secretRef:
              name: fcm-creds
        env:
          - name: RMQ_HOST
            value: "rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local"
          - name: RMQ_PORT
            value: "5672"
          - name: RMQ_VHOST
            value: "ufl"
          - name: RMQ_USER
            valueFrom:
              secretKeyRef:
                name: rabbitmq
                key: RMQ_USER
          - name: RMQ_PASSWORD
            valueFrom:
              secretKeyRef:
                name: rabbitmq
                key: RMQ_PASSWORD
          - name: RMQ_FCM_EXCHANGE
            value: "fcm"
          - name: RMQ_FCM_PUSHER_QUEUE
            value: "fcm:pusher"
          - name: WORKER_COUNT
            value: "20"
          - name: PREFETCH_COUNT
            value: "100"
        resources:
          requests:
            cpu: 10m
```

## File: `deploy/rabbitmp-publisher/deployment_qa.yaml`
- **File Size:** 2247 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** Update code formatting

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ufl-rabbitmq-publisher
  #namespace: qa
  labels:
    app: ufl-rabbitmq-publisher
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ufl-rabbitmq-publisher
  template:
    metadata:
      labels:
        app: ufl-rabbitmq-publisher
    spec:
      containers:
      - name: ufl-rabbitmq-publisher
        image: 736790963086.dkr.ecr.us-east-1.amazonaws.com/fanclash-rabbitmq-publisher:latest
        # This setting makes nodes pull the docker image every time before starting the pod. This is useful when debugging, 
        # but should be turned off in production.
        imagePullPolicy: IfNotPresent
        env:
          - name: DATABASE_NAME
            value: "fanclash"
          - name: DATABASE_USER
            valueFrom:
              secretKeyRef:
                name: db-creds
                key: DATABASE_USER
          - name: DATABASE_PASSWORD
            valueFrom:
              secretKeyRef:
                name: db-creds
                key: DATABASE_PASSWORD
          - name: DATABASE_HOST
            valueFrom:
              secretKeyRef:
                name: db-creds
                key: DATABASE_HOST
          - name: RMQ_HOST
            value: "rabbitmq-0.rabbitmq-headless.rabbitmq.svc.cluster.local"
          - name: RMQ_PORT
            value: "5672"
          - name: RMQ_VHOST
            value: "ufl"
          - name: RMQ_USER
            valueFrom:
              secretKeyRef:
                name: rabbitmq
                key: RMQ_USER
          - name: RMQ_PASSWORD
            valueFrom:
              secretKeyRef:
                name: rabbitmq
                key: RMQ_PASSWORD
          - name: RMQ_EXCHANGES
            value: "match_event,fcm,games,system,game_updates"
          - name: RMQ_FCM_EXCHANGE
            value: "fcm"
          - name: RMQ_FCM_PUSHER_QUEUE
            value: "fcm:pusher"
          - name: WORKER_COUNT
            value: "20"
          - name: PREFETCH_COUNT
            value: "100"
          - name: FCM_CREDENTIALS
            valueFrom:
              secretKeyRef:
                name: fcm-creds
                key: FCM_CREDENTIALS
        resources:
          requests:
            cpu: 10m
```

## File: `local-dev/docker-compose.admin.yaml`
- **File Size:** 1085 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** make file update for the docker compose  newer versions

```
services:
  admin:
    restart: "no"
    build:
      context: ../../laliga-matchfantasy-admin
      dockerfile: ../laliga-matchfantasy-admin/Dockerfile
    command: ["server"]
    depends_on:
      postgres:
        condition: service_healthy
    env_file:
      - .env.admin
    ports:
      - '${ADMIN_PORT}:8000'
    volumes:
      - ../../laliga-matchfantasy-admin:/app
  celery-worker:
    restart: "no"
    build:
      context: ../../laliga-matchfantasy-admin
      dockerfile: ../laliga-matchfantasy-admin/Dockerfile
    command: [ "celery-worker" ]
    depends_on:
      postgres:
        condition: service_healthy
    env_file:
      - .env.admin
    ports:
      - '5555:5555'
    volumes:
      - ../../laliga-matchfantasy-admin:/app
  celery-beat:
    restart: "no"
    build:
      context: ../../laliga-matchfantasy-admin
      dockerfile: ../laliga-matchfantasy-admin/Dockerfile
    command: [ "celery-beat" ]
    depends_on:
      postgres:
        condition: service_healthy
    env_file:
      - .env.admin
    volumes:
      - ../../laliga-matchfantasy-admin:/app
```

## File: `local-dev/docker-compose.api.yaml`
- **File Size:** 1070 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** make file update for the docker compose  newer versions

```
services:
  rabbitmq-publisher:
    restart: "no"
    build:
      context: ../../laliga-matchfantasy-rabbitmq-publisher
      dockerfile: ../laliga-matchfantasy-rabbitmq-publisher/Dockerfile
    env_file:
      - .env.api
    depends_on:
      postgres:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    # ports:
    #   - '${HOST_API_PORT}:${API_PORT}'
    # healthcheck:
    #   test: ["executable", "arg"]
    #   interval: 2s
    #   timeout: 3s
    #   retries: 10
    #   start_period: 3s
    volumes:
        - ../../laliga-matchfantasy-rabbitmq-publisher:/app
  api-server:
    restart: "no"
    build:
      context: ../../laliga-matchfantasy-api
      dockerfile: ../laliga-matchfantasy-api/Dockerfile
    env_file:
      - .env.api
    depends_on:
      postgres:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
      rabbitmq-publisher:
        condition: service_started
    ports:
      - '${HOST_API_PORT}:${API_PORT}'
    volumes:
        - ../../laliga-matchfantasy-api:/app
```

## File: `local-dev/docker-compose.db.yaml`
- **File Size:** 2492 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** make file update for the docker compose  newer versions

```
services:
  postgres:
    restart: always
    image: timescale/timescaledb:latest-pg16
    command: ["postgres", "-c", "log_statement=all"]
    env_file:
      - .env.db
    ports:
      - '${POSTGRES_EXTERNAL_PORT}:${POSTGRES_INTERNAL_PORT}'
    logging:
      options:
        max-size: 10m
        max-file: '3'
    healthcheck:
      test:
        [
          'CMD-SHELL',
          'pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}',
        ]
      interval: 2s
      timeout: 3s
      retries: 10
      start_period: 3s
    volumes:
      - ./postgres/data:/var/lib/postgresql/data
      - ./scripts/db/init.sql:/docker-entrypoint-initdb.d/init.sql
  redis:
    restart: unless-stopped
    image: redis:7-alpine
    env_file:
      - .env.db
    ports:
      - '${REDIS_PORT}:6379'
    healthcheck:
      test: ['CMD', 'redis-cli', '--raw', 'incr', 'ping']
      interval: 2s
      timeout: 3s
      retries: 10
      start_period: 3s
    command: redis-server --save "" --appendonly no --requirepass ${REDIS_PASSWORD}
    volumes:
      - ./redis:/data
  rabbitmq:
    restart: unless-stopped
    image: rabbitmq:3-management
    env_file:
      - .env.db
    ports:
      - '${RABBITMQ_PORT}:5672'              # RabbitMQ
      - '${RABBITMQ_MANAGEMENT_PORT}:15672'  # Management interface
    healthcheck:
      test: ["CMD", "rabbitmqctl", "status"]
      interval: 2s
      timeout: 3s
      retries: 10
      start_period: 3s
    volumes:
      - ./rabbitmq/data:/var/lib/rabbitmq
      - ./rabbitmq/log:/var/log/rabbitmq
  # pgbouncer:
  #   restart: always
  #   image: edoburu/pgbouncer:latest
  #   env_file:
  #     - .env.db
  #   ports:
  #     - '${PGBOUNCER_PORT}:${PGBOUNCER_PORT}'
  #   environment:
  #     # - DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres/${POSTGRES_DB}?sslmode=disable
  #     - DB_USER=${POSTGRES_USER}
  #     - DB_PASSWORD=${POSTGRES_PASSWORD}
  #     - DB_HOST=postgres
  #     - DB_PORT=${POSTGRES_INTERNAL_PORT}
  #     - DB_NAME=${POSTGRES_DB}
  #     - POOL_MODE=session
  #     - MAX_CLIENT_CONN=100
  #     - DEFAULT_POOL_SIZE=20
  #     - LISTEN_PORT=${PGBOUNCER_PORT}
  #     - AUTH_TYPE=plain # for some reason even though you put md5 here, it still uses plain, pgbouncer bug?
  #   depends_on:
  #     postgres:
  #       condition: service_healthy
  #   healthcheck:
  #     test: ["CMD", "pg_isready", "-h", "postgres"]
  #     interval: 30s
  #     timeout: 30s
  #     retries: 5
  #     start_period: 40s
```

## File: `local-dev/docker-compose.event.yaml`
- **File Size:** 503 bytes
- **Last Modified:** Tue Apr 22 2025 10:28:31 GMT-0500 (Peru Standard Time)
- **Last Commit:** make file update for the docker compose  newer versions

```
services:
  event-processor:
    restart: "no"
    build:
      context: ../../laliga-matchfantasy-event-processor
      dockerfile: ../laliga-matchfantasy-event-processor/Dockerfile
    env_file:
      - .env.event
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    ports:
      - '${HOST_EVENT_PORT}:${EVENT_PORT}'
    volumes:
      - ../../laliga-matchfantasy-event-processor:/app
```
