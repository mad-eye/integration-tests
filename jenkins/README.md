This is a set of templates and contexts for the Jenkins config.xml files.

To Update Jenkins Configuration
-------------------------------

#### First update the configuration files:
Jobs a combination of which application (eg apogee, bolide, etc), and which
branch (master, develop) is to be watched and built.  The configuration files
you might need to edit are:

* `contexts.coffee` : The basic paramaters for each context.
* `scripts/${app}.sh` : The custom ci script for each app.

The script `scripts/${app}.sh` is currently the same for each app (and independent of
which branch is being watched).  That might change if we need it to.

#### Compile and deploy the templates.

1. Run `coffee compileTemplates.coffee` to compile the templates and put them in the
`jenkins_templates/` directory.  The directory structure should mirror those
under `jenkins/jobs/`, allowing an rsync. 
2. Execute the script `deployJenkins.sh` to rsync to `ci.madeye.io`.


