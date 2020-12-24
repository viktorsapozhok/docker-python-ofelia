import os
from setuptools import setup

root_dir = os.path.abspath(os.path.dirname(__file__))

setup(
    name="mypackage",
    version="0.0.1",
    packages=["mypackage"],
    include_package_data=True,
    zip_safe=False,
    entry_points={
        "console_scripts": [
            "mytask=mypackage.task:main",
        ]
    },
    python_requires=">=3.8"
)
