README.md: */README.md docs/about.md Makefile .helpers/readme_generator.py
	@printf '==> %s\n' "$@"
	.helpers/readme_generator.py \
	  --header docs/about.md \
	  */README.md \
	  >"$@"
