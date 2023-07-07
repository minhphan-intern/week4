FROM debian:11

ENV LANG C.UTF-8

### INSTALL DEPENDENCIES
RUN set -x; \
    apt-get update -y \ 
    && apt-get install -y --no-install-recommends \
        python3-pip \
        python-dev \
        python3-dev \
        libxml2-dev \
        libpq-dev \
        liblcms2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libsasl2-dev \
        libldap2-dev \
        build-essential \
        git \
        libssl-dev \
        libffi-dev \
        libjpeg-dev \
        libblas-dev \
        libatlas-base-dev \
        npm

RUN npm install -g less less-plugin-clean-css
RUN apt-get install -y node-less \
    wkhtmltopdf

### Install postgreSQL client
RUN set -x; \
    apt-get -y install gnupg2 \ 
    wget \
    strace
RUN strace wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get -y update \ 
    && apt-get -y install postgresql-13 postgresql-client-13

### Install odoo
RUN useradd -m -d /opt/odoo -U -r -s /bin/bash odoo \
    && git clone https://www.github.com/odoo/odoo --depth 1 --branch 15.0 /opt/odoo/odoo

RUN pip install --upgrade pip \
    && pip install wheel setuptools \
    && pip install -r /opt/odoo/odoo/requirements.txt

RUN mkdir /var/log/odoo \
    && chown -R odoo: /var/log/odoo
COPY ./conf/odoo/odoo.conf /etc/odoo/

EXPOSE 8069 8071 8072

USER odoo
WORKDIR /opt/odoo/odoo
ENTRYPOINT [ "/opt/odoo/odoo/odoo-bin" ]
CMD ["-c","/etc/odoo/odoo.conf"]