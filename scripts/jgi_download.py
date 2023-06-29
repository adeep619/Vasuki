import requests
import bs4 as bs
import urllib.request
import os

if not os.path.exists("JGI_Database"):
    os.makedirs("JGI_Database")

fungi_ids = open('fungi_id_list.txt', 'r')
for row in fungi_ids:
    IDs = row.split('\t')[0]
    print(f"****************************** script running for {IDs} *************************************\n")
    log += "****************************** script running for {IDs} *************************************\n"
    organism = IDs
    # URL and HEADERS after login to the website
    # from browser and ispect element
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

    # to retain cookies
    cookies = login_req.cookies

    soup = bs.BeautifulSoup(
        s.get('https://genome.jgi.doe.gov/portal/ext-api/downloads/get-directory?organism=' + organism).text,
        'html.parser')
    # print(soup.find_all('file'))
    # link=soup.find('')
    domain = 'https://genome.jgi.doe.gov'
    from re import search

    all_url = []
    import os

    if not os.path.exists("JGI_Database/" + organism):
        os.makedirs("JGI_Database/" + organism)
    for url in soup.find_all('file'):
        all_url.append(url.get('url'))

    # print(all_url[0])
    # to test for single file
    # for  link in all_url:
    #     if search("KOG", link):
    #         file_name = link.split('/')[-1]
    #         print("downloading file: ", file_name)
    #         # s.get is important
    #         response = s.get(domain + link)
    #         data = open("test_data_download" + "/" + file_name, 'wb')
    #         data.write(response.content)
    #         data.close()
    #         print("file downloaded: " + file_name)

    # provide list oif files to download

    f = open("list_files_download.config", "r")
    for list in f:
        name = list
        final_name = name.rstrip()
        # print(final_name.split(","))
    files_list = name.split(",")
    for link in all_url:
        for files in files_list:

            if search(files, link):
                file_name = link.split('/')[-1]

                print("downloading file: ", file_name, "\n")
                # s.get is important
                response = s.get(domain + link)
                data = open("JGI_Database/" + organism + "/" + file_name, 'wb')
                data.write(response.content)
                for i in response.content:
                    if i == "Error":
                        print(f"this file {link} could not downloaded properly \n")
                        break

                data.close()
                print("file downloaded: " + file_name)

LOG = open('JGI_Database/download.log', 'w')
LOG.write(log)
LOG.close()
