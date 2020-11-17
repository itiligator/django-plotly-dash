FROM python:3.6
WORKDIR /home/plotlyDash
#COPY ./requirements.txt /home/plotlyDash/requirements.txt
#COPY ./dev_requirements.txt /home/plotlyDash/dev_requirements.txt
COPY ./l.txt /home/plotlyDash/l.txt
#RUN pip3 install -r requirements.txt && pip3 install -r dev_requirements.txt
RUN pip3 install -r l.txt
COPY . /home/plotlyDash
RUN python3 setup.py develop
WORKDIR /home/plotlyDash/demo
RUN python3 manage.py migrate && python3 manage.py shell < configdb.py && python3 manage.py collectstatic --noinput --link
EXPOSE 80
ENTRYPOINT  python3 manage.py runserver 0.0.0.0:80 --nostatick
