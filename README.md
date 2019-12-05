### boilerplate of grpc/rest service 

try make help

use make clone to mint your own service

to use local docker in minikube and avoid pull from remote repo

So to use an image without uploading it, you can follow these steps:

Set the environment variables with eval $(minikube docker-env)
Build the image with the Docker daemon of Minikube (eg docker build -t my-image .)
Set the image in the pod spec like the build tag (eg my-image)
Set the imagePullPolicy to Never, otherwise Kubernetes will try to download the image.
