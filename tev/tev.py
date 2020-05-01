#!/usr/bin/env python
""" util for reporting characters the terminal is sending (in raw mode) """
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
import sys
import termios
import tty


def main():
    """ entrypoint for command-line execution """
    tattr = termios.tcgetattr()
    stdin = sys.stdin.fileno()

    try:
        tty.setraw(stdin, termios.TCSADRAIN)

        while True:
            input_byte = ord(sys.stdin.read(1))

            # ASCII ETX/"end of text" - usually sent by Ctrl-C
            if input_byte == 3:
                break

            sys.stdout.write(
                "int: {0:d};  hex: {0:x};  oct: {0:o};  bin: {0:b}\r\n".format(
                    input_byte
                )
            )
    finally:
        termios.tcsetattr(stdin, termios.TCSADRAIN, tattr)


if __name__ == "__main__":
    main()
