FROM alpine as config
ARG url="https://liveuclac-my.sharepoint.com/:f:/g/personal/rmappmb_ucl_ac_uk/EtlNnulBSUtAvOP6S99KcAIBYzze7jTPsmFk2_iHqKDjEw?e=rBP0RO"

RUN apk add --no-cache curl
RUN curl --location --cookie-jar "/cookie-jar.txt" "${url}"
RUN cat <<EOF > "/rclone.conf"
[onedrive]
type = webdav
url = https://liveuclac-my.sharepoint.com/personal/rmappmb_ucl_ac_uk
vendor = other
headers = Cookie,FedAuth=$(grep FedAuth "/cookie-jar.txt" | rev | cut -f1 | rev)
EOF

FROM rclone/rclone as download

COPY --from=config "/rclone.conf" "/rclone.conf"
RUN rclone --config "/rclone.conf" copy --progress onedrive:"Documents/synthseg models" /models

FROM tensorflow/tensorflow:2.0.0-gpu-py3

COPY --chmod=555 "." "/synthseg"

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install "/synthseg"

COPY --from=download "/models" "/synthseg/models"

ENTRYPOINT ["python", "/synthseg/scripts/commands/SynthSeg_predict.py"]
