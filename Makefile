install: # Install everything needed to build this project
	mkdir -p .bin

	echo "Installing elm..."
	curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
	gunzip elm.gz
	chmod +x elm
	mv elm .bin/

	(cd frontend && npm install)

run: # Build the site
	trap 'kill %1; kill %2' SIGINT
	(cd frontend && while inotifywait -r . -e create,delete,modify; do ../.bin/elm make src/Main.elm --output=main.js; done) &
	(cd frontend && npx @tailwindcss/cli -i ./main.css -o ./compiled.css --watch)

build: # Build and optimize for production
	rm -rf frontend/build
	mkdir frontend/build

	(cd frontend && ../.bin/elm make src/Main.elm --output=build/main.js --optimize)
	(cd frontend && npx uglifyjs build/main.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | npx uglifyjs --mangle --output build/main.js)
	(cd frontend && npx minify index.html > build/index.html)
	(cd frontend && npx @tailwindcss/cli -i main.css -o build/compiled.css --minify)
	(cp -R frontend/static frontend/build)

deploy:
	gh workflow run "deploy.yml"
