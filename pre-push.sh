#!/bin/sh

if $(which bundle &> /dev/null); then
	bundle exec fastlane ci
elif $(which fastlane &> /dev/null); then
	fastlane ci
else
	echo 'Fastlane not installed; Run `bundle install` or install Fastlane directly'
	exit 1
fi
