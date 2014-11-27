#!/usr/bin/env python

"""sanity_check_fasta.py: 

    Check for dumplicates.

Last modified: Thu Nov 27, 2014  02:55PM

"""
    
__author__           = "Dilawar Singh"
__copyright__        = "Copyright 2013, Dilawar Singh and NCBS Bangalore"
__credits__          = ["NCBS Bangalore"]
__license__          = "GNU GPL"
__version__          = "1.0.0"
__maintainer__       = "Dilawar Singh"
__email__            = "dilawars@ncbs.res.in"
__status__           = "Development"

import difflib
import sys
import os
import re

names = []

def process(filename):
    with open(filename, "r") as f:
        text = f.read()
    matrixPat = re.compile('matrix(?P<matrix>\s+(\s|\w)+)', re.I | re.DOTALL)
    matrix = matrixPat.search(text)
    blocks = matrix.group('matrix')
    for b in blocks.split("\n"):
        b = b.strip()
        if len(b) < 60 and len(b) > 0:
            if b in names:
                print("Error: %s is duplicate" % b)
            else:
                names.append(b)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("USAGE: %s filename" % sys.argv[0])
        sys.exit()
    filename = sys.argv[1]
    process(filename)
