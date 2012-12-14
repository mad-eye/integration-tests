This is a set of templates and contexts for the Jenkins config.xml files.

`compileTemplates.coffee` will compile the templates and put them in the
`jenkins_templates/` directory.  The directory structure should mirror those
under `jenkins/jobs/`, allowing an rsync.  The script `deployJenkins.sh` does
exactly that.

The configuration files you might need to edit are:

* `contexts.coffee` : The basic paramaters for each context.
* `${app}Build.sh` : The custom ci script for each app.

Jobs a combination of which application (eg apogee, bolide, etc), and which
branch (master, develop) is to be watched and built.  The script `fooBuild.sh`
is currently the same for each app (and independent of which branch is being
watched).  That might change if we need it to.
