FROM python:3.8-slim

RUN groupadd --gid 1000 user && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash user

RUN mkdir /home/user/mypackage
ADD setup.py /home/user/mypackage
ADD mypackage /home/user/mypackage/mypackage

RUN cd /home/user/mypackage && \
    pip install --no-cache-dir .

RUN chown -R "1000:1000" /home/user
USER user
WORKDIR /home/user/mypackage

CMD tail -f /dev/null