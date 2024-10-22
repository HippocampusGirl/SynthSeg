FROM tensorflow/tensorflow:2.0.0-gpu-py3

COPY --chmod=555 "." "/synthseg"

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install "/synthseg"

ENTRYPOINT ["python", "/synthseg/scripts/commands/SynthSeg_predict.py"]
