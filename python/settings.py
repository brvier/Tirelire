#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (c) 2011 Benoit HERVIER <khertan@khertan.net>
# Licenced under GPLv3

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation; version 3 only.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

import os
import json


class Settings(object):

    '''Config object'''

    def __init__(self,):

        if not os.path.exists(os.path.expanduser('~/.tirelire/tirelire.conf')):
            self._write_defaults()
        self._settings = None

    def _write_defaults(self):
        ''' Write the default config'''
        self._settings = {'currencysymbol': '€', }

        self._write()
        return self._settings

    def _write(self, ):
        if not self._settings:
            self._settings = self._read

        with open(os.path.expanduser('~/.tirelire/tirelire.conf'), 'wb') \
                as configfile:
            json.dump(self._settings, configfile)

    def _read(self,):
        if os.path.exists(os.path.expanduser('~/.tirelire/tirelire.conf')):
            with open(os.path.expanduser('~/.tirelire/tirelire.conf'), 'rb') \
                    as configfile:
                self._settings = json.load(configfile)
        else:
            self._settings = self._write_defaults()

    def get(self, option):
        if not self._settings:
            self._read()
        if option not in self._settings:
            self._write_defaults()
        return self._settings[option]

    def set(self, option, value):
        if not self._settings:
            self._read()
        self._settings[option] = value
        self._write()
