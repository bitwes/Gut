# GUT Documentation
This is the readme for the readmes.  The one that binds them all together.  The super README!  The supreme readme.  The readme that begets readmes.  Behold it in all of its glory!


# Local Documentation Generation
You can generate the documentation locally to see what it will look like on readthedocs.

### Create the docker image
To create the docker container, run the following from the `documentation` directory.  You only have to do this if the container does not exist.
```
docker-compose -f docker/compose.yml build
```

### Generate the documentation
Each time you want to regenerate the documentation run the following from the `documentation` directory.
```
docker-compose -f docker/compose.yml up
```

### View Generated Documentation
You can view the generated documentation here:
```
documentation/docs/_build/html/index.html
```
