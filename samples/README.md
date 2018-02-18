# GutTests
This repo contains the tests for the Gut Godot tool and some sample code.

# Setup
This repo is to be used in conjunction with the Gut repo.  It is setup to ignore the addons folder.  The configuration I have been using is that I symlink the `gut` folder into the addons folder in this project.  This makes editing Gut and the tests a little cumbersome but it's the best setup I could find.  

I was going to make Gut a Github Submodule of this, but it appears that the Godot Asset Library wants an 'addons' folder at the root of the repo. Since the addons folder is also in the root of this repo it won't work.

# Contributing
If you have a bug fix or enhancement for Gut you must also submit a pull request to this repo with any tests you have created.
