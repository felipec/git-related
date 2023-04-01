#!/bin/sh

. "$(dirname "$0")"/sharness.sh

cat > "$HOME/.gitconfig" <<-EOF
[user]
	name = Author
	email = author@example.com
EOF

setup () {
	git init -q &&
	echo one > content &&
	git add content &&
	git commit -q -m one --author='Pablo Escobar <pablo@escobar.com>' &&
	echo two >> content &&
	git commit -q -a -m two --author='Jon Stewart <jon@stewart.com>' &&
	echo three >> content &&
	git commit -q -a -m three --author='John Doe <john@doe.com>' &&
	echo four >> content &&
	git branch -q basic &&
	git commit -q -a -F - --author='John Poppins <john@doe.com>' <<-EOF &&
	four

	Reviewed-by: Jon Stewart <jon@stewart.com>
	EOF
	echo four.fix >> content &&
	git commit -q -a -m four.fix --author='John Poppins <john.poppings@google.com>' &&
	git checkout -q -b feature -t &&
	echo five >> content &&
	git commit -q -a -m five --author='Mary Poppins <mary@yahoo.com.uk>'
	git checkout -q -b next -t &&
	echo six >> content &&
	git commit -q -a -m six --author='Octavio Paz <octavio.paz@gmail.com>' &&
	git checkout -q -
}

test_cmp() {
	${TEST_CMP:-diff -u} "$@"
}

test_when_finished() {
	test_cleanup="{ $*
		} && (exit \"\$eval_ret\"); eval_ret=\$?; $test_cleanup"
}
