# COPR "make_srpm" entry point. COPR runs:
#   make -f .copr/Makefile srpm outdir=<dir> spec=<path-to-spec>
# Our own specs get their Source0 tarball from this checkout; upstream ones
# (packaging/extra) download theirs with spectool.
outdir ?= $(CURDIR)/out/srpm
spec ?=

srpm:
	dnf -y install rpm-build rpmdevtools git-core
	./packaging/make-sources.sh
	mkdir -p "$(outdir)"
	cd .cache/rpm-sources && spectool -g "$(abspath $(spec))"
	rpmbuild -bs "$(spec)" \
	  --define "_sourcedir $(CURDIR)/.cache/rpm-sources" \
	  --define "_srcrpmdir $(outdir)"
