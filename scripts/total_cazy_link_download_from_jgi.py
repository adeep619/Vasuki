#this script is not working as it should be
#it works only when the page is also open in the web browser which makes no sense to me

import requests
import bs4 as bs
import urllib.request
import os
import csv

URL = 'https://signon.jgi.doe.gov/signon'
LOGIN_ROUTE = '/create'
HEADERS = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36',
        'origin': URL, 'referer': URL + LOGIN_ROUTE}
    # session object
s = requests.session()

    # login data
login_payload = {
        'login': 'aman.deep@uni-due.de',
        'password': 'Tonystark@1234',
    }

    # POST request
login_req = s.post(URL + LOGIN_ROUTE, headers=HEADERS, data=login_payload)

    # to check the login status (should be 200 or 300's)
print(login_req.status_code)


soup = bs.BeautifulSoup(
        s.get('https://mycocosm.jgi.doe.gov/mycocosm/annotations/browser/cazy/summary;ut4gL1?p=fungi').text,
        'html.parser')

all=soup.find(id='sr-Cazy:root')
domain='https://mycocosm.jgi.doe.gov'

soup2 = bs.BeautifulSoup(s.get('https://mycocosm.jgi.doe.gov/ext-api/mycocosm/annotations-browser/browse/ut4gL1?nodeId=CAZY:PL&portalId=Veral1&f=2&p=fungi').text,'html.parser')
#print(soup2)
#To get the Table from html
table = soup2.find('table')
#open CSV file to write

f = open("table_out_from_jgi_cazy_all.csv", "w")
file=csv.writer(f)
#file = csv.writer(open("table_out_from_jgi_cazy_all.csv", "w"))
# get the total length of the table for loop
x = (len(table.find_all('tr')))
# find all tr and iterate through the tablefor each column
for row in table.find_all('tr')[1:x]:
        col = row.find_all('td')  # all of the column "td"
        protein_id = col[0].getText()
        loc = col[1].getText()
        gene_len = col[2].getText()
        prot_len = col[3].getText()
        anot = col[4].getText()
        domain = col[5].getText()
        all_data = (protein_id, loc, gene_len, prot_len, anot, domain)
        file.writerow(all_data)  # write all of the columns

f.close()
# for link in soup.find_all('a', href=True):
#         print(link['href'])
#         complete_link= domain + link['href']
#         print(complete_link)

        # #domain='https://mycocosm.jgi.doe.gov'😃
        # #
        #soup2 = bs.BeautifulSoup(s.get(complete_link).text,'html.parser')
        #print(soup2)
        # To get the Table from html
        #table = soup2.find('table')
        # open CSV file to write
#         file = csv.writer(open("table_out_from_jgi_cazy_all.csv", "a"))
#         # get the total length of the table for loop
#         x = (len(table.find_all('tr')))
#         # find all tr and iterate through the tablefor each column
#         for row in table.find_all('tr')[1:x]:
#                 col = row.find_all('td')  # all of the column "td"
#                 protein_id = col[0].getText()
#                 loc = col[1].getText()
#                 gene_len = col[2].getText()
#                 prot_len = col[3].getText()
#                 anot = col[4].getText()
#                 domain = col[5].getText()
#                 all_data = (protein_id, loc, gene_len, prot_len, anot, domain)
#                 file.writerow(all_data)  # write all of the columns
#                 file.write('\n')
# #
# # #print(link)
# # #response= s.get(domain + '/ext-api/mycocosm/annotations-browser/browse/ut4gL1?nodeId=Cazy:root&amp;portalId=Aalte1&amp;f=1&amp;p=fungi')
# #
# #
# #
# #
