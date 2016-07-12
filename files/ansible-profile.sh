#  Snipped from the ansible/hacking/env-setup file
#
#  Modifies environment for running Ansible

# Default values for shell variables we use
PYTHONPATH=${PYTHONPATH-""}
PATH=${PATH-""}
MANPATH=${MANPATH-""}

verbosity=silent

export ANSIBLE_HOME="/opt/git/ansible"

PREFIX_PYTHONPATH="$ANSIBLE_HOME/lib"
PREFIX_PATH="$ANSIBLE_HOME/bin"
PREFIX_MANPATH="$ANSIBLE_HOME/docs/man"

expr "$PYTHONPATH" : "${PREFIX_PYTHONPATH}.*" > /dev/null || export PYTHONPATH="$PREFIX_PYTHONPATH:$PYTHONPATH"
expr "$PATH" : "${PREFIX_PATH}.*" > /dev/null || export PATH="$PREFIX_PATH:$PATH"
expr "$MANPATH" : "${PREFIX_MANPATH}.*" > /dev/null || export MANPATH="$PREFIX_MANPATH:$MANPATH"

#
# Generate egg_info so that pkg_resources works
#

# Do the work in a function so we don't repeat ourselves later
gen_egg_info()
{
    if [ -e "$PREFIX_PYTHONPATH/ansible.egg-info" ] ; then
        \rm -rf "$PREFIX_PYTHONPATH/ansible.egg-info"
    fi
    python setup.py egg_info
}

cd ${ANSIBLE_HOME}
if [ "$ANSIBLE_HOME" != "$PWD" ] ; then
    current_dir="$PWD"
else
    current_dir="$ANSIBLE_HOME"
fi
(
	cd "$ANSIBLE_HOME"
	if [ "$verbosity" = silent ] ; then
	    gen_egg_info > /dev/null 2>&1
            find . -type f -name "*.pyc" -exec rm {} \; > /dev/null 2>&1
	else
	    gen_egg_info
            find . -type f -name "*.pyc" -exec rm {} \;
	fi
	cd "$current_dir"
)

if [ "$verbosity" != silent ] ; then
    cat <<- EOF
	
	Setting up Ansible to run out of checkout...
	
	PATH=$PATH
	PYTHONPATH=$PYTHONPATH
	MANPATH=$MANPATH
	
	Remember, you may wish to specify your host file with -i
	
	Done!
	
	EOF
fi

unset verbosity
