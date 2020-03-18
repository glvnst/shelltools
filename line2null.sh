#!/bin/sh
# converts newlines to nulls, useful with xargs -0
# installed_name:line2null

exec tr '\n' '\0'

