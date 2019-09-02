FROM ubuntu:16.04

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get -y dist-upgrade \
    && apt-get -y install git python-pip uwsgi virtualenv sudo python-dev libyaml-dev \
       libsasl2-dev libldap2-dev nginx uwsgi-plugin-python mysql-client \
    && rm -rf /var/cache/apt/archives/*

RUN useradd -m -s /bin/bash iris

COPY src /home/iris/source/src
COPY setup.py /home/iris/source/setup.py
COPY MANIFEST.in /home/iris/source/MANIFEST.in

WORKDIR /home/iris

RUN chown -R iris:iris /home/iris /var/log/nginx /var/lib/nginx \
    && sudo -Hu iris mkdir -p /home/iris/var/log/uwsgi /home/iris/var/log/nginx /home/iris/var/run \
    && sudo -Hu iris virtualenv /home/iris/env \
    && sudo -Hu iris /bin/bash -c 'source /home/iris/env/bin/activate \
    && cd /home/iris/source && pip install . && pip install -e ".[prometheus]"'

COPY . /home/iris
COPY ops/config/systemd /etc/systemd/system
COPY ops/daemons /home/iris/daemons
COPY db /home/iris/db
COPY configs/config.dev.yaml /home/iris/config/config.yaml
COPY ops/entrypoint.py /home/iris/entrypoint.py


EXPOSE 16649
EXPOSE 8001
EXPOSE 8002

CMD ["sudo", "-Hu", "iris", "bash", "-c", "source /home/iris/env/bin/activate && python /home/iris/entrypoint.py"]
