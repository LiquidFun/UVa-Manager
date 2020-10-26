#!/bin/python3

import requests
from lxml import html
import sys
import os
import re
import time

# TODO ERROR CHECKING IN ENTIRE FILE

configFilePath = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "config.sh")
with open(configFilePath, 'r') as configFile:
	config = configFile.read()
	USERNAME = re.findall("(?<=UVA_JUDGE_NICKNAME=).*", config)[0]
	PASSWD = re.findall("(?<=UVA_JUDGE_PASSWORD=).*", config)[0]

	if USERNAME == '' or PASSWD == '':
		print("ERROR: No username or password found in config.sh")
		sys.exit()

	login_url = "https://onlinejudge.org/index.php?option=com_comprofiler&task=login"
	submit_url = 'https://onlinejudge.org/index.php?option=com_onlinejudge&Itemid=25&page=save_submission'
	my_submissions_url = 'https://onlinejudge.org/index.php?option=com_onlinejudge&Itemid=9'

	for problem in sys.argv[1:]:

		# 3 is old c++
		lang = {
			'.py' : 6,
			'.cpp' : 5,
			'.pas' : 4,
			'.java' : 2,
			'.c' : 1,
		}

		# Format path
		path = os.path.abspath(problem)
		problemFile = os.path.basename(path)

		problemNum = re.findall(r"/[0-9]*-", path)[-1][1:-1]

		# Get language number
		language = 0
		for l, num in lang.items():
			if l in problemFile:
				language = num
				break

		# Start requests session
		session_requests = requests.session()
		result = session_requests.get(login_url)

		# Get login token
		tree = html.fromstring(result.text)
		authenticity_token = list(set(tree.xpath("//input[@name='cbsecuritym3']/@value")))[0]

		# Login
		payload = {
			"username": USERNAME,
			"passwd": PASSWD,
			"op2": "login",
			"lang": "english",
			"force_session": 1,
			"message": 0,
			"loginform": "loginmodule",
			"cbsecuritym3" : authenticity_token,
			"Submit": "Login",
		}
		result = session_requests.post(
			login_url,
			data = payload,
			headers = dict(referer=login_url)
		)

		# Submit problem
		payload = {
			"localid": problemNum,
			"language": language,
			"code": open(path, "r").read(),
		}
		session_requests.post(
			submit_url,
			data = payload,
			headers = dict(referer=submit_url)
		)

		# Look for results as long as it is in judge queue
		while True:
			time.sleep(3)
			result = session_requests.get(
				my_submissions_url,
				headers = dict(referer=my_submissions_url)
			)

			sections = re.findall(r"sectiontableentry1.*?<\/tr>", result.text, re.DOTALL)[0]
			v = [v.replace("<td>", "").replace("</td>", "") for v in re.findall(r"<td>.*?</td>", sections)]

			print("\t{0}\t{1}\t{2}\t{3}\t{4}".format(v[0], v[2], v[3], v[4], v[6]))
			if "In judge queue" not in v:
				break

