#!/bin/sh

test_description="Test git related"

. ./test-lib.sh

setup () {
	git init -q &&
	echo one > content &&
	git add content &&
	git commit -q -m one --author='Pablo Escobar <pablo@escobar.com>' &&
	echo two >> content &&
	git commit -q -a -m one --author='Jon Stewart <jon@stewart.com>' &&
	echo three >> content &&
	git commit -q -a -m three --author='John Doe <john@doe.com>' &&
	echo four >> content &&
	git branch -q basic &&
	git commit -q -a -F - --author='John Poppins <john@doe.com>' <<-EOF &&
	four

	Reviewed-by: Jon Stewart <jon@stewart.com>
	EOF
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
	Jon Stewart <jon@stewart.com> (author: 100%)
	EOF
	test_cmp expected actual
"

test_expect_success "others" "
	git format-patch --stdout -1 feature > patch &&
	git related patch | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john@doe.com> (author: 66%)
	Jon Stewart <jon@stewart.com> (reviewer: 33%, author: 33%)
	EOF
	test_cmp expected actual
"

test_expect_success "multiple patches" "
	git format-patch --stdout -1 feature > patch1 &&
	git format-patch --stdout -1 feature~ > patch2 &&
	git related patch1 patch2 | sort > actual &&
	cat > expected <<-EOF &&
	John Doe <john@doe.com> (author: 50%)
	Jon Stewart <jon@stewart.com> (author: 50%)
	EOF
	test_cmp expected actual
"

test_expect_success "from revision range" "
	git related master..feature | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john@doe.com> (author: 66%)
	Jon Stewart <jon@stewart.com> (reviewer: 33%, author: 33%)
	EOF
	test_cmp expected actual
"

test_expect_success "from single rev revision range" "
	git related -1 feature | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john@doe.com> (author: 66%)
	Jon Stewart <jon@stewart.com> (reviewer: 33%, author: 33%)
	EOF
	test_cmp expected actual
"

test_expect_success "mailmap" "
	test_when_finished 'rm -rf .mailmap' &&
	cat > .mailmap <<-EOF &&
	Jon McAvoy <jon@stewart.com>
	John Poppins <john@poppins.com> <john@doe.com>
	EOF
	git related -1 feature | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john@poppins.com> (author: 66%)
	Jon McAvoy <jon@stewart.com> (reviewer: 33%, author: 33%)
	EOF
	test_cmp expected actual
"

test_expect_success "commits" "
	git related -craw -1 feature | git log --format='%s' --no-walk --stdin > actual &&
	cat > expected <<-EOF &&
	four
	three
	one
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
	Author Ümlaut <author@umlaut.com> (author: 33%)
	Mary Poppins <mary@yahoo.com.uk> (author: 33%)
	Octavio Paz <octavio.paz@gmail.com> (author: 33%)
	EOF
	test_cmp expected actual
"

test_done
