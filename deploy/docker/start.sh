#!/bin/bash
set -e

if [ "$1" = "server" ]; then
  python manage.py migrate
  python manage.py createcachetable
  python manage.py collectstatic
  gunicorn -b :8000 mobile_api.wsgi --timeout 240
else

  if [ "$1" = "celery-worker" ]; then
    celery -A mobile_api worker -l info
  else

    if [ "$1" = "celery-beat" ]; then
      celery -A mobile_api beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    fi

  fi

fi
