#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2019 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
#
# Given a git range, spit out the Change ID (CID) that are fixed in that release
#
# usage:
#	generate_cid.sh GIT_RANGE
#
#

# if we decide to rename the thing, change it here
prefix="CID-"

help()
{
	echo "error, git range not found"
	echo "usage:"
	echo "	$0 GIT_RANGE"
	exit 1
}

print_sha()
{
	sha1=$1
	gsr=$(git show -s --abbrev-commit --abbrev=12 --pretty=format:"%h (\"%s\")%n" "${sha1}")
	echo "${prefix}${gsr}"
}

generate_cid()
{
	git_range=$1
	for c in $(git rev-list --no-merges "${git_range}"); do
		# kernel commits have these in 2 different ways:
		# "    commit 4b2c5a14cd8005a900075f7dfec87473c6ee66fb upstream."
		# or
		# "    [ Upstream commit 3a069024d371125227de3ac8fa74223fcf473520 ]"
		#
		# Pick out the "first" 40 digit sha1 in the changelog text, which should be the "upstream" id
		upstream=$(git log -1 "${c}" | awk '{if(NR>1)print}' | grep -E -o '[0-9a-f]{40}' | head -n 1 )
		if [ "${upstream}" != "" ] ; then
			print_sha "${upstream}"
			continue
		fi
		echo "upstream git id not found for ${c}"
	done
}

git_range=$1

if [ "${git_range}" == "" ] ; then
	help
fi

generate_cid "${git_range}"
exit 0
