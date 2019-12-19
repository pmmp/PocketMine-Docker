clean:
	: REMINDER: You might need sudo to run this recipe
	test ! -d data || rm -r data
	rm testsuite/*/*/*.phar || true
	mkdir data
	chown 1000:1000 data
