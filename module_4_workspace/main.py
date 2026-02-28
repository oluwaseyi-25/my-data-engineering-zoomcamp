import requests
import gzip

from time import sleep
url_template = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2019-{month:02d}.csv.gz"
urls = [url_template.format(month = i) for i in range(1, 13)]

def main():
    for url in urls:
        response = requests.get(url)
        file_name = url.split('/')[-1]
        with open('./fhv_data/' + file_name, 'wb') as fp:
            fp.write(response.content)

if __name__ == "__main__":
    main()
