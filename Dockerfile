FROM python:3.6

#https://www.caktusgroup.com/blog/2017/03/14/production-ready-dockerfile-your-python-django-app/
RUN set -ex \
    && RUN_DEPS=" \
    libpcre3 \
    mime-support \
    " \
    && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS \
    && rm -rf /var/lib/apt/lists/*



#https://www.caktusgroup.com/blog/2017/03/14/production-ready-dockerfile-your-python-django-app/
COPY requirements.txt /requirements.txt
RUN set -ex \
    && BUILD_DEPS=" \
    build-essential \
    libpcre3-dev \
    libpq-dev \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && pip install --no-cache-dir -r /requirements.txt \
    \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/plotlyDash
COPY . /home/plotlyDash
RUN python3 setup.py develop
WORKDIR /home/plotlyDash/demo
RUN python3 manage.py migrate && python3 manage.py shell < configdb.py && python3 manage.py collectstatic --noinput --link
EXPOSE 8000
#ENTRYPOINT  python3 manage.py runserver 0.0.0.0:80 --nostatick

#https://www.digitalocean.com/community/tutorials/how-to-build-a-django-and-gunicorn-application-with-docker
CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "demo.wsgi:application"]
