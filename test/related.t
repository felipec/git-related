#!/bin/sh

test_description="Test git related"

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
	git format-patch --stdout -1 basic > patch &&
	git related patch | sort > actual &&
	cat > expected <<-EOF &&
	Jon Stewart <jon@stewart.com> (100%)
	EOF
	test_cmp expected actual
"

test_expect_success "others" "
	git format-patch --stdout -1 feature > patch &&
	git related patch | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (33%)
	John Poppins <john@doe.com> (67%)
	EOF
	test_cmp expected actual
"

test_expect_success "multiple patches" "
	git format-patch --stdout -1 feature > patch1 &&
	git format-patch --stdout -1 feature~ > patch2 &&
	git related patch1 patch2 | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john@doe.com> (67%)
	Jon Stewart <jon@stewart.com> (33%)
	EOF
	test_cmp expected actual
"

test_expect_success "from revision range" "
	git related master..feature | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (33%)
	John Poppins <john@doe.com> (67%)
	EOF
	test_cmp expected actual
"

test_expect_success "from single revision" "
	git related master | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (33%)
	John Poppins <john@doe.com> (67%)
	EOF
	test_cmp expected actual
"

test_expect_success "no arguments" "
	git related | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (33%)
	John Poppins <john@doe.com> (67%)
	EOF
	test_cmp expected actual
"

test_expect_success "mailmap" "
	test_when_finished 'rm -rf .mailmap' &&
	cat > .mailmap <<-EOF &&
	Jon McAvoy <jon@stewart.com>
	John Poppins <john.poppings@google.com> <john@doe.com>
	John Poppins <john.poppings@google.com> <john@poppings.com>
	EOF
	git related --roles | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (author: 100%)
	Jon McAvoy <jon@stewart.com> (reviewer: 33%)
	EOF
	test_cmp expected actual
"

test_expect_success "commits" "
	git related -craw | git log --format='%s' --no-walk --stdin > actual &&
	cat > expected <<-EOF &&
	four.fix
	four
	three
	EOF
	test_cmp expected actual
"

test_expect_success "files" "
	git related -f | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (20%)
	John Poppins <john@doe.com> (40%)
	Jon Stewart <jon@stewart.com> (20%)
	Pablo Escobar <pablo@escobar.com> (20%)
	EOF
	test_cmp expected actual
"

test_expect_success "encoding" "
	export LC_ALL=C &&
	git checkout next &&
	echo umlaut >> content &&
	git commit -q -a -m umlaut --author='Author Ümlaut <author@umlaut.com>' &&
	echo other >> content &&
	git commit -q -a -m other --author='Other Content <other@content.com>' &&
	git related -1 next | sort > actual &&
	cat > expected <<-EOF &&
	Author Ümlaut <author@umlaut.com> (33%)
	Mary Poppins <mary@yahoo.com.uk> (33%)
	Octavio Paz <octavio.paz@gmail.com> (33%)
	EOF
	test_cmp expected actual
"

test_done
