all: build

build: 
	jekyll build

preview: 
	jekyll serve --watch --drafts

publish: build
	git add .
	git stash save
	git checkout publish || git checkout --orphan publish
	find . -maxdepth 1 ! -name '.' ! -name '.git*' ! -name '_site' -exec rm -rf {} +
	find _site -maxdepth 1 -exec mv {} . \;
	rmdir _site
	git add -A && git commit -m "Publish" || true
	git push -f git+ssh://git@push.clever-cloud.com/app_35705790-187f-4d5d-b6aa-3b13ec768ca9.git \
	    publish:master
	git checkout master
	git clean -fdx
	git stash pop || true

publish-ppd:
	jekyll build --drafts
	git stash save
	git checkout publish-ppd || git checkout --orphan publish-ppd
	find . -maxdepth 1 ! -name '.' ! -name '.git*' ! -name '_site' -exec rm -rf {} +
	find _site -maxdepth 1 -exec mv {} . \;
	rmdir _site
	git add -A && git commit -m "Publish ppd" || true
	git push -f git+ssh://git@push.clever-cloud.com/app_9a3c4a03-ccfa-4e0c-94f3-773fbe17e488.git \
	    publish-ppd:master
	git checkout master
	git clean -fdx
	git stash pop || true
