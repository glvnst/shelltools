#!/usr/bin/env python3
""" utility for printing markdown tables """
import collections
import json
import sys


def dict2mdtable(row_list, col_list=None, fill_empty=""):
    """
    return a string containing a markdown-formatted table. the table is
    generated from the supplied list of dicts that contain row data, and a
    list of column names which refer to keys in the dicts. column widths are
    automatically calculated. the optional fill_empty argument defines the
    value inserted into cells that don't have data
    """
    # for example to create this table...
    #
    # animal | color | feature
    # ------ | ----- | ------------
    # turtle | green | shell
    # crow   | black | intelligence
    # horse  | brown | long face
    #
    # you'd supply this row_list (remember regular python dicts are unordered):
    # [
    #     {"animal": "turtle", "feature": "shell", "color": "green"},
    #     {"color": "black", "animal": "crow", "feature": "intelligence"},
    #     {"feature": "long face", "animal": "horse", "color": "brown"},
    # ]
    # ...and (optionally) this col_list: ["animal", "color", "feature"]

    if not col_list:
        # the user didn't supply a col_list so we generate one from the set of
        # keys in all the rows
        col_list_tmp = set()
        for row in row_list:
            col_list_tmp.update(row)
        col_list = sorted(col_list_tmp)

    if fill_empty is not None:
        # fill_empty represents the default value for cells that aren't defined
        # in a row
        filler = lambda: fill_empty
        row_list = [collections.defaultdict(filler, row) for row in row_list]

    # calculate the width of each column. this is derived from the max length
    # of the row contents in a column including the column name itself
    col_widths = {
        col_name: max([len(row[col_name]) for row in row_list] + [len(col_name)])
        for col_name in col_list
    }

    # generate a format string that can later be used to print the rows of the
    # table. in the above example this would work out to:
    # "{animal:<6} | {color:<5} | {feature:<12}"
    row_fmt = " | ".join(
        [
            "{{{name}:<{width}}}".format(name=col_name, width=col_widths[col_name])
            for col_name in col_list
        ]
    )

    # the header row contains just the names of the columns
    header_row = {col_name: col_name for col_name in col_list}

    # the delimiter row contains the dash/underlines that appear on the line
    # below the header row (this is vital for md tables to be parsed as tables)
    delim_row = {col_name: "-" * col_widths[col_name] for col_name in col_list}

    # putting it all together
    return "\n".join(
        [row_fmt.format(**row) for row in [header_row, delim_row] + row_list]
    )


def main():
    """entrypoint for direct execution"""
    # wip. currently reads json docs (1 per line) on stdin, prints summary table
    print(dict2mdtable([json.loads(line) for line in sys.stdin]))


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n")
        sys.exit(1)
