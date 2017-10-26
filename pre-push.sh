#!/bin/sh

if $(which bundle &> /dev/null); then
	bundle exec fastlane test
elif $(which fastlane &> /dev/null); then
	fastlane test
else
	echo 'Fastlane not installed; Run `bundle install` or install Fastlane directly'
	exit 1
fi
