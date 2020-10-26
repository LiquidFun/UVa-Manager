#!/bin/python3

import sys

# Supply the problem path as first argument
# Supply only the problem test input as second argument as string

path = sys.argv[1]
problemTests = [a for a in sys.argv[2].split('Sample Input\n') if a != '']

for i, problem in enumerate(problemTests):
	# TODO CHECK IF DOES NOT EXIST
	p = problem.split('Sample Output\n')
	with open(path + "t" + str(i+1) + "in.txt", "w") as f:
		f.write(p[0])
		# print("({0}) -> Creating test case {1}".format(sys.argv[0], chr(i+65)))
	with open(path + "t" + str(i+1) + "out.txt", "w") as f:
		f.write(p[1])
