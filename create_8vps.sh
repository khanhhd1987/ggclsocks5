#!/bin/bash

MAX=8
COUNT=1

for ((i=1; i<=MAX;)); do
  # Tạo 2 máy tại Osaka (asia-northeast2-a)
  for j in {1..2}; do
    if [ $i -le $MAX ]; then
      echo "Creating proxy-vm-$i in asia-northeast2-a (Osaka)"
      gcloud compute instances create proxy-vm-$i \
        --zone=asia-northeast2-a \
        --machine-type=e2-micro \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --boot-disk-size=10GB \
        --tags=http-server,https-server,socks5-proxy \
        --can-ip-forward \
        --no-restart-on-failure \
        --metadata startup-script-url=https://raw.githubusercontent.com/khanhhd1987/ggclsocks5/main/setup.sh \
        --quiet
      ((i++))
    fi
  done

  # Tạo 1 máy tại Tokyo (asia-northeast1-a)
  if [ $i -le $MAX ]; then
    echo "Creating proxy-vm-$i in asia-northeast1-a (Tokyo)"
    gcloud compute instances create proxy-vm-$i \
      --zone=asia-northeast1-a \
      --machine-type=e2-micro \
      --image-family=debian-11 \
      --image-project=debian-cloud \
      --boot-disk-size=10GB \
      --tags=http-server,https-server,socks5-proxy \
      --can-ip-forward \
      --no-restart-on-failure \
      --metadata startup-script-url=https://raw.githubusercontent.com/khanhhd1987/ggclsocks5/main/setup.sh \
      --quiet
    ((i++))
  fi
done
