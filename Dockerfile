FROM python:3.7

ARG password

RUN apt-get update && apt-get install -y \
    libxml2-dev libxslt-dev libpython3-dev zlib1g-dev

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list

RUN apt-get update && apt-get install -y google-chrome-stable

WORKDIR /usr/local/bin
RUN wget https://chromedriver.storage.googleapis.com/78.0.3904.105/chromedriver_linux64.zip && unzip chromedriver_linux64.zip

WORKDIR /notebook
RUN pip install --upgrade pip

COPY requirements.txt /notebook
RUN pip install -r requirements.txt

RUN apt-get install -y nodejs npm
RUN npm install -g --unsafe-perm ijavascript && ijsinstall

RUN apt-get install -y php php-zmq
ADD ./jupyter-php-installer.phar /notebook/jupyter-php-installer.phar

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"

RUN php ./jupyter-php-installer.phar install

RUN jupyter notebook --generate-config
RUN echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 8888" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.password = '$password'" >> /root/.jupyter/jupyter_notebook_config.py

CMD ["jupyter", "notebook", "--allow-root"]
