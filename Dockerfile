FROM debian:stretch
RUN apt-get update

RUN apt-get install -y gnupg2 wget git
RUN wget -O - https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc | apt-key add -
RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" > /etc/apt/sources.list.d/freeswitch.list
RUN echo "deb-src http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" >> /etc/apt/sources.list.d/freeswitch.list
RUN apt-get update && apt-get install -y freeswitch-meta-all

RUN cd /opt && git clone -b v4.0.1 https://github.com/iNextrix/ASTPP.git

RUN mv -f /usr/share/freeswitch/scripts /tmp/.
RUN ln -s /opt/ASTPP/freeswitch/scripts /usr/share/freeswitch/
RUN cp -rf /opt/ASTPP/freeswitch/sounds/*.wav /usr/share/freeswitch/sounds/en/us/callie
RUN cp -rf /opt/ASTPP/freeswitch/conf/autoload_configs/* /etc/freeswitch/autoload_configs/

RUN /bin/systemctl start freeswitch
RUN /bin/systemctl enable freeswitch
RUN sed -i "s#max-sessions\" value=\"1000#max-sessions\" value=\"2000#g" /etc/freeswitch/autoload_configs/switch.conf.xml
RUN sed -i "s#sessions-per-second\" value=\"30#sessions-per-second\" value=\"50#g" /etc/freeswitch/autoload_configs/switch.conf.xml
RUN sed -i "s#max-db-handles\" value=\"50#max-db-handles\" value=\"500#g" /etc/freeswitch/autoload_configs/switch.conf.xml
RUN sed -i "s#db-handle-timeout\" value=\"10#db-handle-timeout\" value=\"30#g" /etc/freeswitch/autoload_configs/switch.conf.xml
RUN rm -rf  /etc/freeswitch/dialplan/*
RUN touch /etc/freeswitch/dialplan/astpp.xml
RUN rm -rf  /etc/freeswitch/directory/*
RUN touch /etc/freeswitch/directory/astpp.xml
RUN rm -rf  /etc/freeswitch/sip_profiles/*
RUN touch /etc/freeswitch/sip_profiles/astpp.xml
RUN chmod -Rf 755 /usr/share/freeswitch/sounds/en/us/callie
RUN /bin/systemctl restart freeswitch
RUN /bin/systemctl enable freeswitch

ENTRYPOINT /bin/systemctl freeswitch restart && bash
