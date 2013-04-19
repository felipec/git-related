#!/bin/sh

test_description="Test git related"

. ./sharness.sh

setup() {
	git init &&
	echo one > content &&
	git add content &&
	git commit -q -m one --author='Pablo Escobar <pablo@escobar.com>' &&
	echo two >> content &&
	git commit -q -a -m one --author='Jon Stewart <jon@stewart.com>' &&
	echo three >> content &&
	git commit -q -a -m three --author='John Doe <john@doe.com>' &&
	echo four >> content &&
	git branch basic &&
	git commit -q -a -F - --author='John Poppins <john@doe.com>' <<-EOF &&
	four

	Reviewed-by: Jon Stewart <jon@stewart.com>
	EOF
	echo five >> content &&
	git commit -q -a -m five --author='Mary Poppins <mary@yahoo.com.uk>'
	git checkout -b next &&
	echo six >> content &&
	git commit -q -a -m six --author='Ocatio Paz <octavio.paz@gmail.com>'
}

setup

test_expect_success "basic" "
	git format-patch --stdout -1 basic > patch &&
	git related patch | sort > actual &&
	cat > expected <<-EOF &&
	Jon Stewart <jon@stewart.com>
	Pablo Escobar <pablo@escobar.com>
	EOF
	test_cmp expected actual
"

test_expect_success "others" "
	git format-patch --stdout -1 master > patch &&
	git related patch | sort > actual &&
	cat > expected <<-EOF &&
	John Doe <john@doe.com>
	John Poppins <john@doe.com>
	Jon Stewart <jon@stewart.com>
	EOF
	test_cmp expected actual
"

test_expect_success "multiple patches" "
	git format-patch --stdout -1 master > patch1 &&
	git format-patch --stdout -1 master^ > patch2 &&
	git related patch1 patch2 | sort > actual &&
	cat > expected <<-EOF &&
	John Doe <john@doe.com>
	John Poppins <john@doe.com>
	Jon Stewart <jon@stewart.com>
	Pablo Escobar <pablo@escobar.com>
	EOF
	test_cmp expected actual
"

test_expect_success "from committish" "
	git related -1 master | sort > actual &&
	cat > expected <<-EOF &&
	John Doe <john@doe.com>
	John Poppins <john@doe.com>
	Jon Stewart <jon@stewart.com>
	EOF
	test_cmp expected actual
"

test_expect_success "from single rev committish" "
	git related -1 master | sort > actual &&
	cat > expected <<-EOF &&
	John Doe <john@doe.com>
	John Poppins <john@doe.com>
	Jon Stewart <jon@stewart.com>
	EOF
	test_cmp expected actual
"

test_done
