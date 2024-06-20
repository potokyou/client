# Run container
sudo docker run -d \
--log-driver none \
--restart always \
--network potok-dns-net \
--ip=172.29.172.254 \
--name $CONTAINER_NAME $CONTAINER_NAME
