README.md: */README.md docs/about.md
	@printf '==> %s\n' "$@"
	.helpers/readme_generator.py \
	  --header docs/about.md \
	  */README.md \
	  >"$@"
