from setuptools import setup, find_packages

setup(
    name="pyCRUMBS",
    version="0.1.0",
    description="Python implementation of the CRUMBS library for I2C communication on Raspberry Pi",
    author="Cameron K. Brooks",
    author_email="cbrook49@uwo.ca",
    packages=find_packages(),
    install_requires=[
        "smbus2",
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: POSIX :: Linux",
        "License :: OSI Approved :: MIT License",
    ],
)
