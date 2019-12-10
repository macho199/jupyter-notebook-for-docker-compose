FROM python:3

ARG password

RUN apt-get update && apt-get install -y \
    libxml2-dev libxslt-dev libpython3-dev zlib1g-dev

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update
RUN apt-get install -y google-chrome-stable

WORKDIR /usr/local/bin
RUN wget https://chromedriver.storage.googleapis.com/78.0.3904.105/chromedriver_linux64.zip && unzip chromedriver_linux64.zip

WORKDIR /notebook
RUN pip install --upgrade pip
#RUN pip install jupyter requests lxml cssselect beautifulsoup4 pyquery mysqlclient pymongo openpyxl pandas matplotlib selenium
# jupyter requests lxml cssselect beautifulsoup4 pyquery mysqlclient pymongo openpyxl pandas matplotlib selenium
COPY requirements.txt /notebook
RUN pip install -r requirements.txt

RUN jupyter notebook --generate-config
RUN echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 8888" >> /root/.jupyter/jupyter_notebook_config.py
#RUN echo "c.NotebookApp.password = 'sha1:02a2d3f1b278:048db04681031bb60627f46d56943c0c68fe860e'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.password = '$password'" >> /root/.jupyter/jupyter_notebook_config.py

#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--NotebookApp.token=''", "--allow-root"]
CMD ["jupyter", "notebook", "--allow-root"]