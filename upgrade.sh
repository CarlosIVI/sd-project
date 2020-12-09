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
helm upgrade pythonapp ~/sd-project/sd-project --debug --recreate-pods
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

