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
    },
)
