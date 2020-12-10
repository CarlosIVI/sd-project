#!/bin/bash
echo "desplegando la aplicación"
echo "."
echo ".."
helm install pythonapp ~/prueba/sd-project/sd-project
echo "..."
echo "App web en python desplegada junto a la base de datos"
echo "La aplicación está lista para ser probada en la ip publica del balanceador que se muestra a continuación"
sleep 120
kubectl get ingress
echo "Ingresar a la ip publica, la ruta / muestra la aplicación que cuenta el numero de veces que se ingresa a la app y /health que el microservicio se encuentra arriba"

