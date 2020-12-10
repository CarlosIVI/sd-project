
#!/bin/bash

echo "desplegando la aplicación"
echo "."
echo ".."
helm install pythonapp ~/sd-project/sd-project

echo "..."
echo "App web en python desplegada junto a la base de datos"
echo "La aplicación está lista para ser probada en la ip publica del balanceador que se muestra a continuación"
sleep 120
kubectl get ingress

echo "Esperando 8 minutos mientras despliega con las unidades más pequeñas existentes en google cloud"
sleep 480

echo "Ingresar a la ip publica, la ruta / muestra la aplicación que cuenta el numero de veces que se ingresa a la app y /health que el microservicio se encuentra arriba"
#Pruebas de humo
echo "Chequeo del estado de todos los Pods en ejecución exponiendo el servicio, con información poco más detallada"
kubectl get pods -o wide

echo "...."
echo "Prueba del Servicio, que expone a la aplicación del contador"
EXTERNAL_IP=$(kubectl get ingress gateway-ingress -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
curl -I http://${EXTERNAL_IP}

echo "....."
echo "Pruebas de ejecución de algunos de los Pods que prestan componen el Servicio"

POD_NAME=$(kubectl get pods  -o jsonpath="{.items[0].metadata.name}")
kubectl logs $POD_NAME
echo "---"
