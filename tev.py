#!/usr/bin/python
# Smallish util for reporting characters the terminal is sending (in raw mode)
# Copyright (C) 2008 Benjamin Burke - http://www.galvanist.com/
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
import tty
import termios
import sys


# This hack is here because I'm stuck on 2.4, which has no bin() or ":b"
## {{{ http://code.activestate.com/recipes/576847/ (r1)
hexDict = {
    '0':'0000', '1':'0001', '2':'0010', '3':'0011', '4':'0100', '5':'0101',
    '6':'0110', '7':'0111', '8':'1000', '9':'1001', 'a':'1010', 'b':'1011',
    'c':'1100', 'd':'1101', 'e':'1110', 'f':'1111', 'L':''}

def dec2bin(n):
    """
    A foolishly simple look-up method of getting binary string from an integer
    This happens to be faster than all other ways!!!
    """
    # =========================================================
    # create hex of int, remove '0x'. now for each hex char,
    # look up binary string, append in list and join at the end.
    # =========================================================
    return ''.join([hexDict[hstr] for hstr in hex(n)[2:]])
## end of http://code.activestate.com/recipes/576847/ }}}


termSettings = termios.tcgetattr(sys.stdin.fileno())

try:
    tty.setraw(sys.stdin.fileno(), termios.TCSADRAIN)

    while 1:
        i = ord(sys.stdin.read(1))
     
        if i == 3:
            break
        else:
            # Because I'm stuck in 2.4
            print "int: %(i)d;  hex: %(i)x;  oct: %(i)o;  bin: %(ib)s;\r" % \
                    {"i": i, "ib": dec2bin(i)}

            # For the future:
            #print "int: {0:d};  hex: {0:x};  oct: {0:o};  bin: {0:b}\r".format(i)
finally:
    termios.tcsetattr(sys.stdin.fileno(), termios.TCSADRAIN, termSettings)

exit
