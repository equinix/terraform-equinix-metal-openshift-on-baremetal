#!/bin/bash

RDIR=$1

if [ -f $RDIR/artifacts/openshift-install.tar.gz ]; then
	echo 'Openshift Installer Exists'
else
	mkdir $RDIR/artifacts; 
	curl http://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${var.ocp_version}/openshift-install-linux.tar.gz \
		--output $RDIR/artifacts/openshift-install.tar.gz;
fi

rm -rf $RDIR/artifacts/install
mkdir $RDIR/artifacts/install
cd $RDIR/artifacts;
tar -xvzf openshift-install.tar.gz;
