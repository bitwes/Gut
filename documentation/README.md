# GUT Documentation
This is the readme for the readmes.  The one that binds them all together.  The super README!  The supreme readme.  Behold it in all of its glory!

Documentation is hosted at https://gut.readthedocs.io.




# Structure
`documentation/docs/conf.py`
This is the Sphinx configuration file.

`documentation/docs/index.rst`
The Home page and also responsible for generating the Table of Contents for the site.  If you add a new page, it must be added to one of the `.. toctree::` entries.

`documentation/docs`  The directory for all the wiki pages.  All wiki pages are markdown.

`documentation/_static/css`
The CSS goes in here.

`documentation/_static/images` Put any wiki related images in here.




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
