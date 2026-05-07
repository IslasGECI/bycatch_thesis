#!/usr/bin/env bash
git config --global user.name "Evaristo Rojas • GECI"
git config --global user.email "evaristo.rojas@islas.org.mx"
git config --get core.hooksPath
git config core.hooksPath .githooks
git config --get core.hooksPath
