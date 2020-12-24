FROM python:3.8-slim

RUN groupadd --gid 1000 user && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash user

RUN mkdir /home/user/app
ADD setup.py /home/user/app
ADD app /home/user/app/app

RUN cd /home/user/app && \
    pip install --no-cache-dir .

RUN chown -R "1000:1000" /home/user
USER user
WORKDIR /home/user/app

CMD tail -f /dev/null