FROM python:3.9-slim

# Install minimal tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates tar wget gnupg2 tini \
  && rm -rf /var/lib/apt/lists/*

# Python deps (boto3 hanya diperlukan jika mau Secrets Manager; tidak dipakai saat hyperparams)
RUN pip install --no-cache-dir boto3

# create user and directories used by SageMaker
RUN groupadd -r peakminer && useradd -r -g peakminer -d /home/peakminer -s /sbin/nologin peakminer \
 && mkdir -p /opt/peakminer /opt/ml/code /opt/ml/output /opt/ml/model /opt/ml/input \
 && chown -R peakminer:peakminer /opt/peakminer /opt/ml

WORKDIR /opt/ml/code

# copy training entrypoint
COPY train.py /opt/ml/code/train.py
RUN chmod 750 /opt/ml/code/train.py \
 && chown peakminer:peakminer /opt/ml/code/train.py

USER peakminer

ENTRYPOINT ["/usr/bin/tini", "--", "python", "/opt/ml/code/train.py"]


