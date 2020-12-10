# Proyecto final de Sistemas distribuidos | Counter app deployed in Kubernetes


## Integrantes
**[John Sebastian Urbano Lenis](https://github.com/SebastianUrbano/) -----> A00292788**

**[German Carvajal](https://github.com/German2404) -----> A00134280**

**[Jhan Carlos Diaz Vidal](https://github.com/CarlosIVI/) -----> A00310560**

**[Mateo Matta López](https://github.com/MateoMatta) -----> A00310540**




### Tabla de contenido
1. [Introducción](#introducción)
1. [Objetivo](#objetivo)
1. [Requerimientos y Dependencias](#requerimientos-y-dependencias)
1. [Instalación](#instalación)
1. [Aplicación Desarrollada En Python](#aplicación-desarrollada-en-python)
1. [Contenedor Docker](#contenedor-docker)
1. [Chart de Helm](#chart-de-helm)
1. [Script de automatización](#script-de-automatización)


### Introducción
Kubernetes es una plataforma open source creada originalmente por Google que automatiza las operaciones de los contenedores de Linux. Esta disminuyes la cantidad de procesos manuales relacionados en la escalabilidad e implementación de aplicativos dentro de contenedores.

### Objetivo
El siguiente proyecto realizará la creación de un contador, el cual será un servicio simple qué será puesto en marcha haciendo uso de la automatización para provisionar paquetes necesarios, configuraciones y luego desplegarlo en un clúster de Kubernetes.

### Requerimientos y Dependencias
•	Docker
•	Consola Linux de Kubernetes Cluster en Google Cloud Platfom
•	GitHub
•	Lenguaje de programación y scripting
•	Helm
•	Flask
•	Python

### Instalación

### Aplicación Desarrollada En Python
En el bloque de código que se muestra, se encuentra el código para construir aplicación de mensaje de bienvenida y contador de visitas, desarrollada en Python.  Esta aplicación se puede desplegar al realizar un contenedor Docker, dentro del cual se crea el API REST con el framework Flask. Esta construirá los endpoints que ayudarán a comunicarse con las funciones de esta.

Configuración implementación de funciones de aplicación Python, archivo app.py

    from flask import Flask
    from redis import Redis
    import os

    app = Flask(__name__)
    redis = Redis(host=os.environ.get('REDISAPP_SERVICE_HOST'), port=6379)

    @app.route('/')
    def hello():
        count = redis.incr('hits')
        return 'Hello World! I have been seen {} times.\n'.format(count)

    @app.route('/health')
    def health():
        return 'Microservice a is ready!'

    if __name__ == "__main__":
        app.run(host="0.0.0.0", port=8000, debug=True)



### Contenedor Docker

Archivo Docker Dockerfile que ejecuta la aplicación del contador de Python.

    FROM python:3.4-alpine
    ADD . /code
    WORKDIR /code
    RUN pip install -r requirements.txt
    CMD ["python", "app.py"]

Archivo de requerimientos requirements.txt del contenedor de Docker para ejecutar la aplicación desarrollada en Python.

    redis
    flask

### Chart de Helm
Helm es una herramienta que ayuda a gestionar aplicaciones de Kubernetes. Ayuda a manejar los Kubernetes haciendo uso de cartas de navegación (Charts). Esta ayuda a definiar, instalizar y actualizar aplicaciones de Kubernetes. Se mostrará a continuación los archivos y configuraciones necesarios para desplegar la aplicación de este proyecto.

Definición del Deployment de Kubernetes y redireccionamiento del servicio usando NodePort dentro del archivo deployment.yaml
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ .Values.name}}
    spec:
      strategy:
        type: Recreate
        rollingUpdate: null   
      selector:
        matchLabels:
          app: {{ .Values.name}}
      template:
        metadata:
          labels:
            app: {{ .Values.name}}
          annotations:
            releaseTime: {{ dateInZone "2006-01-02 15:04:05Z" (now) "UTC"| quote }}
        spec:
          containers:
          - name: {{ .Values.name}}
            image: german2404/counter:latest
            imagePullPolicy: Always
            ports:
              - containerPort: 8000
            livenessProbe:
              httpGet:
               path: /health
               port: 8000
              initialDelaySeconds: 5
              periodSeconds: 5
            readinessProbe:
              httpGet:
               path: /health
               port: 8000
              initialDelaySeconds: 5
              periodSeconds: 5
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ .Values.name}}
    spec:
      type: NodePort
      ports:
      - name: http
        port: 8000
        targetPort: 8000
      selector:
        app: {{ .Values.name}}


Descripción del chart en el archivo Chart.yaml

    apiVersion: v1
    name: sd-project
    description: A Helm chart for ds final project

    # A chart can be either an 'application' or a 'library' chart.
    #
    # Application charts are a collection of templates that can be packaged into versioned archives
    # to be deployed.
    #
    # Library charts provide useful utilities or functions for the chart developer. They're included as
    # a dependency of application charts to inject those utilities and functions into the rendering
    # pipeline. Library charts do not define any templates and therefore cannot be deployed.
    type: application

    # This is the chart version. This version number should be incremented each time you make changes
    # to the chart and its templates, including the app version.
    # Versions are expected to follow Semantic Versioning (https://semver.org/)
    version: 0.1.0

    # This is the version number of the application being deployed. This version number should be
    # incremented each time you make changes to the application. Versions are not expected to
    # follow Semantic Versioning. They should reflect the version the application is using.
    appVersion: 1.0.2


Constantes de variables a usar en la configuración, con valores específicos de configuración y nombres de recursos a usar. Ubicado en el archivo values.yaml
  
    replicaCount: 2
    image: german2404/counter:1.0.2
    port: 8000
    servicetype: NodePort
    name: pythonapp
    ingressname: gateway-ingress
    minReplicas: 3
    maxReplicas: 7
    cpu: 80
    timestamp: 1


Definición de autosecalado con HPA
Se define luego la política de autoescalado que sirve para que el servicio de la aplicación puede responder antes las distintas cargas de trabajo manejadas. El HPA de Kubernetes permite realizar esa variación del número de pods desplegados mediante un replication controller en función de diferentes métricas.

    apiVersion: autoscaling/v2beta1
    kind: HorizontalPodAutoscaler
    metadata:
      name: {{ .Values.name}}
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: {{ .Values.name }}
      minReplicas: {{ .Values.minReplicas }}
      maxReplicas: {{ .Values.maxReplicas }}
      metrics:
      - type: Resource
        resource:
          name: cpu
          targetAverageUtilization: {{ .Values.cpu }}

Definición de chequeos de salud del Deployment

Se hacen los chequeso de salud del deploymebt, en este contexto en el archivo de deployment.yaml dentro de los templates definidos.

     livenessProbe:
              httpGet:
               path: /health
               port: 8000
              initialDelaySeconds: 5
              periodSeconds: 5
            readinessProbe:
              httpGet:
               path: /health
               port: 8000
              initialDelaySeconds: 5
              periodSeconds: 5

Ingreso de Kubernetes para permitir el tráfico dentro de los Pods
Para el acceso de forma pública a la aplicación correspondiente, se definirá dentro de los archivos de plantillas el archivo ingress.yaml. Este define las rutas de las variables de los puertos y nombre del servicio de cada subpágina web desplegada (“/” y “/health”).

    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: {{ .Values.ingressname}}
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /
    spec:
      rules:
      - http:
          paths:
          - path: /
            backend:
              serviceName: {{ .Values.name}}
              servicePort: {{ .Values.port}}   
          - path: /health
            backend:
              serviceName: {{ .Values.name}}
              servicePort: {{ .Values.port}}
              
### Script de automatización
Para la configuración y despliegue rápido del servicio del contador online en Kubernetes, se tiene la configuración del script mostrado abajo. Este conjunto de instrucciones para la interfaz de comandos de Linux automatiza la construcción y despliegue de la aplicación en un cluster k8s. Específicamente realiza la Construcción de la aplicación, las Pruebas de Integración, el Aprovisionamiento de paquetes, el Despliegue y exposición pública, y las Pruebas de humo.

•Construcción, Aprovisionamiento:
Instalación con Helm de un Chart que provee un nombre único y los paquetes necesarios para la instalación de la aplicación de Python.

    helm install pythonapp ~/sd-project/sd-project

• Despliegue
Con el siguiente comando se puede observar el servicio de ingreso -en este caso, de nombre "gateway-ingress"-, hasta que se le asigna una dirección IP accesible. Toma algo de tiempo.

    sleep 120
    kubectl get ingress
    sleep 480

• Pruebas de humo
Probar Servicio expuesto
#Luego de tener específicamente el Deployment expuesto, o sea en un funcionamiento y visible al público, es pueden realizar pruebas de humo
Estas se basan en verificaciones de:
- Rutas críticas
- Ejecución de reportes, consultas, registros y transacciones relevantes

Primero empezaremos por lo más básico; revisar el estado con información un poco más detallada de todos los Pods que estén en ejecución exponiendo el servicio

    kubectl get pods -o wide

Luego, realizaremos una prueba de humo en algo más específico, o sea un Service. El Servicio se basa en la manera de expoenr a una aplicación ejecutándose en un conjunto de Pods trabajando como un servicio de red.

    EXTERNAL_IP=$(kubectl get ingress gateway-ingress -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
    curl -I http://${EXTERNAL_IP}
    
Chequeo de Pods
Si se quisiera incluso ver las respuestas hechas por alguno de los pods que componen el servicio, se podría realizar una prueba tomando alguno de ellos.
Para lo cual tomaremos el nombre de alguno de los Pods que prestan el servicio

    POD_NAME=$(kubectl get pods  -o jsonpath="{.items[0].metadata.name}")

Ahora, teniendo el nombre del Pod que ha respondido a las peticiones HTTP, se muestran todos los registros de su actividad.

    kubectl logs $POD_NAME
    
• Pruebas unitarias
Pruebas unitarias para la aplicación desarrollada en Python

    python ~/sd-project/test.py
    
• Script para actualizar la aplicación desplegada
Si el desarrollador hace cambios en la aplicación y quiere liberar esa nueva versión, se ha desarrollado otro script que permite que el sistema actualicen esos cambios en el despliegue. Dicho archivo tiene de nombre "upgrade.sh"

    #!/bin/bash
    number=$RANDOM
    echo "Generando nueva imagen con los cambios"
    echo "."
    echo ".."
    docker build --tag german2404/counter:latest .
    echo "Subiendo los cambios al repositorio "
    echo "."
    echo ".."
    docker push german2404/counter:latest
    echo "desplegando los cambios en la aplicación"
    echo "."
    echo ".."
    helm upgrade pythonapp ~/sd-project/sd-project --debug
    echo "..."
    echo "App web en python desplegada junto a la base de datos"
    sleep 3
    echo "..."
    echo "Instalando dependencias.."
    pip3 install flask
    pip3 install redis
    echo "Corriendo pruebas..."
    python3 test.py
    kubectl get ingress
    echo "Ingresar a la ip publica, la ruta / muestra la aplicación que cuenta el numero de veces que se ingresa a la app y /health que el microservicio se encuentra arriba"

