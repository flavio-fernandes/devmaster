#!/bin/bash

for elem in `git diff --cached --name-only && git diff --name-only` ; do
    /vagrant/ediff_bin/gediff.sh ${elem}
done
