#!/bin/sh

test_description='Test git who'

. $(dirname $0)/test-lib.sh

setup

test_expect_success 'basic' '
	git who | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (17%)
	John Poppins <john@doe.com> (33%)
	Jon Stewart <jon@stewart.com> (17%)
	Mary Poppins <mary@yahoo.com.uk> (17%)
	Pablo Escobar <pablo@escobar.com> (17%)
	EOF
	test_cmp expected actual
'

test_expect_success 'roles' '
	git who --roles | sort > actual &&
	cat > expected <<-EOF &&
	John Poppins <john.poppings@google.com> (author: 17%)
	John Poppins <john@doe.com> (author: 33%)
	Jon Stewart <jon@stewart.com> (author: 17%, reviewer: 17%)
	Mary Poppins <mary@yahoo.com.uk> (author: 17%)
	Pablo Escobar <pablo@escobar.com> (author: 17%)
	EOF
	test_cmp expected actual
'

test_done
