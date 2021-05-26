#!/bin/sh

test_description="Test git who"

. ./test-lib.sh

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

setup

test_expect_success "basic" "
	git who | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (17%)
	John Poppins <john@doe.com> (33%)
	Jon Stewart <jon@stewart.com> (17%)
	Mary Poppins <mary@yahoo.com.uk> (17%)
	Pablo Escobar <pablo@escobar.com> (17%)
	EOF
	test_cmp expected actual
"

test_expect_success "roles" "
	git who --roles | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (author: 17%)
	John Poppins <john@doe.com> (author: 33%)
	Jon Stewart <jon@stewart.com> (author: 17%, reviewer: 17%)
	Mary Poppins <mary@yahoo.com.uk> (author: 17%)
	Pablo Escobar <pablo@escobar.com> (author: 17%)
	EOF
	test_cmp expected actual
"

test_done
