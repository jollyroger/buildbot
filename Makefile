# developer utilities

.PHONY: docs apidocs pylint

docs:
	$(MAKE) -C master/docs

apidocs:
	$(MAKE) -C apidocs

tutorial:
	$(MAKE) -C master/docs tutorial

pylint:
	cd master; $(MAKE) pylint
	cd slave; $(MAKE) pylint

pyflakes:
	pyflakes master/buildbot slave/buildslave

debs: deb-master deb-slave

deb-master:
	cd master; fakeroot debian/rules clean
	dpkg-source -b master
	cd master; fakeroot debian/rules binary
	cd master; dpkg-genchanges > ../master.changes

deb-slave:
	cd slave; fakeroot debian/rules clean
	dpkg-source -b slave
	cd slave; fakeroot debian/rules binary
	cd slave; dpkg-genchanges > ../slave.changes
