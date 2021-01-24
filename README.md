# docker-python-ofelia

Let's assume we have a Python app printing current time to stdout, and we want 
to run it by schedule within docker container. How to do it?

First, let's build it as a Python package with entry point ``task`` defined in a setup file:

```python
from setuptools import setup

setup(
    name="app",
    packages=["app"],
    include_package_data=True,
    zip_safe=False,
    entry_points={
        "console_scripts": [
            "task=app.task:main",
        ]
    }
)
```

After installing the package, a user may invoke ``main`` function (from module [/app/task.py](https://github.com/viktorsapozhok/docker-python-ofelia/blob/main/app/task.py))
by calling ``task`` on the command line.

```shell
$ task
current time: 15:50:50
```

Now we build a docker image as simple as installing the app
package with user privileges.

```shell
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
```

Note, that we don't want to install cron in docker container. The reason is that
using cron we need to run ``task`` under root what can cause some inconvenience when using
environment variables. Instead, we are using [Ofelia docker scheduler][1] which does
all the dirty work for us.

Here is the docker-compose configuration:

```yaml
version: '3.7'

services:
  app:
    image: app
    container_name: app
    restart: always
    user: user
    build:
      context: .
      dockerfile: Dockerfile
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.app.schedule: "@every 10s"
      ofelia.job-exec.app.command: "task"

  ofelia:
    image: mcuadros/ofelia:latest
    restart: always
    depends_on:
      - app
    command: daemon --docker
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:r
```

Now, running a service we get our task to be executed by the defined schedule, every 10 seconds:

```shell
$ docker-compose up
Recreating app ... done
Recreating docker-python-ofelia_ofelia_1 ... done
Attaching to app, docker-python-ofelia_ofelia_1
ofelia_1  | scheduler.go:34 ▶ NOTICE New job registered "app" - "task" - "@every 10s"
ofelia_1  | scheduler.go:54 ▶ DEBUG Starting scheduler with 1 jobs
ofelia_1  | common.go:123 ▶ NOTICE [Job "app" (30174edd9f02)] Started - task
ofelia_1  | common.go:123 ▶ NOTICE [Job "app" (30174edd9f02)] Output: current time: 15:40:48
ofelia_1  | common.go:123 ▶ NOTICE [Job "app" (6cc13206d61e)] Started - task
ofelia_1  | common.go:123 ▶ NOTICE [Job "app" (6cc13206d61e)] Output: current time: 15:40:58
ofelia_1  | common.go:123 ▶ NOTICE [Job "app" (90fefad32d2c)] Started - task
ofelia_1  | common.go:123 ▶ NOTICE [Job "app" (90fefad32d2c)] Output: current time: 15:41:08
```

Nice thing about Ofelia is that she can be easily integrated with Slack.
To do this we simply add one new line to docker-compose file:

```yaml
services:
  app:
    ...
    labels:
      ...
      ofelia.job-exec.app.slack-webhook: "slack-webhook-url"
```

To get a webhook URL you need to configure the incoming webhook in your Slack channel.
You can find [here][2] how to do this.

Now running the service, you will be receiving the following messages in Slack channel:

<a href="https://github.com/viktorsapozhok/docker-python-ofelia/blob/main/docs/source/images/slack.png?raw=true">
    <img 
        src="https://github.com/viktorsapozhok/docker-python-ofelia/blob/main/docs/source/images/slack.png?raw=true" 
        alt="ofelia slack integration"
    >
</a>

As a result, we have a job running by schedule inside the container with the execution log redirected to the Slack channel.

## License

MIT License (see [LICENSE](LICENSE)).

[1]: https://github.com/mcuadros/ofelia "Ofelia - a docker job scheduler"
[2]: https://api.slack.com/messaging/webhooks "Sending messages using Incoming Webhooks"
[3]: https://viktorsapozhok.github.io/docker-python-ofelia/ "Running Python script in docker container by cron as a non-root user]"
