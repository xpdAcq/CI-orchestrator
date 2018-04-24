CI-orchestrator
===============
Dep installation orchestrator for complex builds on CI

Problem
-------
Installing dependencies on CI's is hard. 
Sometimes we want the CI to run with the currently released code, sometimes on 
the bleeding edge code from GitHub or other sources.
Sometimes we need need a mixture of the two.
Usually one turns to build matricies to fix this on the CI but it is difficult
to setup a system which knows which things to install when.

Solution
--------
Have a dedicated requirements file which has the needed structure to describe
the various sources of the requirements and what "level" they are to be 
applied.

Spec
~~~~
The file is a yaml file which has the structure of:

.. code-block:: yaml
   name:
     default: {installer: name}
     bleeding: {bleeding instaler: name}

eg.

.. code-block:: yaml
   xpdconf:
     default: {conda: xpdconf}
     experimental: {pip: git+git://github.com/xpdAcq/xpdConf.git#egg=xpdconf}

Env vars can be set to modify the level of the install.
If the env var is not set then the installer defaults to the the default.

Env Vars:

.. code-block:: shell
   $INSTALLERS
   $INSTALLERS_ORDER
   $PRECEDENCE
