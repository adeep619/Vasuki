#
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
import re
    # to retain cookies
cookies = login_req.cookies
# link for Aaoar1
soup = bs.BeautifulSoup(
        s.get('https://mycocosm.jgi.doe.gov/mycocosm/proteins-browser/browse    ?p=fungi').text,
        'html.parser')

#To get the Table from html
table=soup.find('table')
#open CSV file to write
file=csv.writer(open("table_out_from_jgi_cazy.csv", "w"))
#get the total length of the table for loop
x = (len(table.findAll('tr')))
#find all tr and iterate through the table for each column
for row in table.findAll('tr')[1:x]: #tr=table rule
        col = row.findAll('td') #all of the column "td=table data"
        protein_id= col[0].getText()
        loc=col[1].getText()
        gene_len=col[2].getText()
        prot_len=col[3].getText()
        anot= col[4].getText()
        domain=col[5].getText()
        all_data=(protein_id, loc, gene_len, prot_len,anot,domain)
        file.writerow(all_data) #write all of the columns

