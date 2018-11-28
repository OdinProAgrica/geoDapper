FROM hpccsystems/hpcc:6.4.24-1

EXPOSE 8010
EXPOSE 8015

COPY ./setupPython.sh /code/setupPython.sh
RUN /code/setupPython.sh

COPY ./Docker/environment.conf /etc/HPCCSystems/environment.conf
RUN chown hpcc /etc/HPCCSystems/environment.conf
RUN chgrp hpcc /etc/HPCCSystems/environment.conf
RUN chmod 644 /etc/HPCCSystems/environment.conf

COPY ./Docker/start.sh /usr/local/bin/start.sh

ENTRYPOINT /usr/local/bin/start.sh
