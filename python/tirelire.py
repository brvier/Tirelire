#!/usr/bin/env python
# -*- coding: utf-8 -*-

#!/usr/bin/python
# -*- coding: utf-8 -*-

""" Tirelire
    Copyright (C) 2013 Benoît HERVIER <khertan@khertan.net>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
"""

import os
import sqlite3
from thread import get_ident
import time
import datetime
from settings import Settings

DBPATH = os.path.expanduser('~/.tirelire/tirelire.db')
DATAPATH = os.path.expanduser('~/.tirelire/')

if not os.path.exists(DATAPATH):
    os.makedirs(DATAPATH)


class ExpensesDB(object):
    _version = 1
    _create_expenses = ('CREATE TABLE IF NOT EXISTS expenses '
                        '( '
                        'uid INTEGER PRIMARY KEY AUTOINCREMENT,'
                        'timestamp INTEGER,'
                        'desc TEXT,'
                        'amount INTEGER '
                        ')')
    _create_version = ('CREATE TABLE IF NOT EXISTS version '
                       '( version INTEGER )')
    _update_version = ('UPDATE version set version=1')
    _get_total = ('SELECT SUM(amount) FROM expenses')
    _get_all_expenses = ('SELECT uid, timestamp, desc, amount FROM expenses')
    _insert = ('INSERT INTO expenses (timestamp, desc, amount)'
               ' VALUES (?, ?, ?)')
    _update = ('UPDATE expenses set timestamp=?, desc=?,'
               ' amount=? WHERE uid=?')
    _delete = ('DELETE FROM expenses WHERE uid=?')
    _categories = ('SELECT DISTINCT desc from expenses ORDER BY desc')

    def __init__(self, dbpath):
        self.dbpath = os.path.abspath(dbpath)
        self._connection_cache = {}
        with self._get_conn() as conn:
            conn.execute(self._create_version)
            conn.execute(self._create_expenses)
            conn.execute(self._update_version)

    def _get_conn(self):
        id = get_ident()
        if id not in self._connection_cache:
            self._connection_cache[id] = sqlite3.Connection(self.dbpath,
                                                            timeout=60)
        return self._connection_cache[id]

db = ExpensesDB(DBPATH)
settings = Settings()

def listExpenses(startDate, endDate):
    global db
    with db._get_conn() as conn:
        curs = conn.execute(db._get_all_expenses
                            + ' WHERE timestamp >= ?'
                            + ' AND timestamp <= ?'
                            + ' ORDER BY timestamp DESC', [startDate,
                                                           endDate])
    return [_getTotal(), [{'uid': uid,
                           'date': timestamp,
                           'desc': desc,
                           'amount': amount}
            for uid, timestamp, desc, amount in curs.fetchall()]]


def setSetting(option, value):
    global settings
    settings.set(option, value)
    return True


def getSetting(option):
    global settings
    return settings.get(option)


def rm(uid):
    if uid > 0:
        with db._get_conn() as conn:
            conn.execute(db._delete, (uid, ))
    return True


def insertOrUpdate(uid, desc, amount, date):
    #Convert date to timestamp at 12:00am for section grouping
    ddate = datetime.datetime.fromtimestamp(date)
    ddate = ddate.replace(hour=12, minute=0, second=0, microsecond=0)
    date = time.mktime(ddate.timetuple())
    print 'Date timestamp converted:', date
    if uid > 0:
        with db._get_conn() as conn:
            conn.execute(db._update, (date, desc, amount, uid))
    else:
        with db._get_conn() as conn:
            conn.execute(db._insert, (date, desc, amount))
    conn.commit()
    return True


def getCategories():
    with db._get_conn() as conn:
        curs = conn.execute(db._categories)
        return [{'name': cat} for cat, in curs.fetchall()]
    return []


def _getTotal():
    global db
    curs = 0
    with db._get_conn() as conn:
        curs = conn.execute(db._get_total)

    return curs.fetchone()[0]

if __name__ == '__main__':
    print 'Total:', _getTotal()
    print 'Add: 10', insertOrUpdate(0, 'test1', 10, time.time())
    print 'Total:', _getTotal()
    print 'Remove: 5', insertOrUpdate(0, 'test2', -5, time.time())
    print 'Total:', _getTotal()
    print 'List:', listExpenses(0, time.time())
    print 'Categories', getCategories()
