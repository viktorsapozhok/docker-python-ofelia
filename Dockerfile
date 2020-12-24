FROM python:3.8-slim

RUN mkdir /mypackage

ADD setup.py /mypackage
ADD mypackage /mypackage/mypackage

RUN cd mypackage && pip install --no-cache-dir .

WORKDIR /mypackage

CMD tail -f /dev/null