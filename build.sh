#!/usr/bin/env bash

repo="docker.io"
imgname="eswees/openvpn-status"

pushd $(dirname $0)

#docker rmi $(docker images -f "dangling=true" -q)

build_code=1
tag_code=1
push_code=1

docker build --no-cache=true --tag="${imgname}" -f Dockerfile .
build_code=$?

if [ ${build_code} == '0' ]; then
	docker tag ${imgname} ${repo}/${imgname}
	tag_code=$?
	docker push ${repo}/${imgname}
	push_code=$?
fi

popd

if [ "${tag_code}" == '0' ] && [ "${push_code}" == '0' ] && [ "${build_code}" == '0' ]; then
	exit 0
else
	echo -en "\tbuild: $build_code\ttag: $tag_code\tpush: $push_code\n"
	exit 1
fi
