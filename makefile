docs:
	@git clone https://github.com/DoccZz/docc2html.git	
	@mkdir -p ./.build/docs/
	@sh scripts/build_docs.sh
	@rm -rf ./build
	@rm -rf ./docc2html
