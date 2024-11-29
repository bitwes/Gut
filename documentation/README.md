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




# Class Reference Generation

## Setup
The class reference documentation generation toolkit wrapper script requires:
* `zsh`
* `python3`
* Docker (per above requirements)

Before generating class reference:
* The project must have been opened in the editor or you have run an import (`godot --import`).  No xml files will be generated if not.
* You must have created the docker image already, per the directions above.


## Execution
From the root of this project run:
* `zsh documentation/generate_rst.sh`

Output will be located in the following directories:
* XML:  `documentation/class_ref_xml`
* RST:  `documentation/docs/class_ref`
* HTML:  `documentation/docs/_build/html/class_ref`

Class Reference will be on the index page the the bottom of the TOC.

The XML and RST files are under revision control, the HTML is not.