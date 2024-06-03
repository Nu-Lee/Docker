# Wsclean v3.4 Dockerfile
---------------------
https://wsclean.readthedocs.io/  
--------------------
you can edit Dockerfile and build
## build Dockerfile
```
cd Docker
docker build -t wsclean ./
docker run -it -v data_dir:/root wsclean
```
