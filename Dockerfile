FROM debian:jessie
RUN apt-get update
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y curl git
RUN curl https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add -
RUN echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
RUN apt-get install -y --force-yes freeswitch-video-deps-most
RUN apt-get install -y autoconf automake devscripts gawk chkconfig dnsutils sendmail-bin sensible-mda ntpdate ntp g++ git-core curl libjpeg62-turbo-dev libncurses5-dev make python-dev pkg-config libgdbm-dev libyuv-dev libdb-dev libvpx2-dev gettext sudo lua5.1 libxml2 libxml2-dev openssl libcurl4-openssl-dev gettext gcc libldns-dev libpcre3-dev build-essential libssl-dev libspeex-dev libspeexdsp-dev libsqlite3-dev libedit-dev libldns-dev libpq-dev bc
RUN git config --global pull.rebase true
RUN git clone -b v1.6.19 https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/local/src/freeswitch
RUN cd /usr/local/src/freeswitch; ./bootstrap.sh -j
RUN sed -i "s#\#xml_int/mod_xml_curl#xml_int/mod_xml_curl#g" /usr/local/src/freeswitch/modules.conf
RUN sed -i "s#\#mod_db#mod_db#g" /usr/local/src/freeswitch/modules.conf
RUN sed -i "s#\#applications/mod_voicemail#applications/mod_voicemail#g" /usr/local/src/freeswitch/modules.conf
RUN sed -i "s#\#event_handlers/mod_json_cdr#event_handlers/mod_json_cdr#g" /usr/local/src/freeswitch/modules.conf
RUN cd /usr/local/src/freeswitch; ./configure -C
RUN cd /usr/local/src/freeswitch; make all cd-sounds-install cd-moh-install
RUN cd /usr/local/src/freeswitch; make; make install
RUN ln -s /usr/local/freeswitch/bin/freeswitch /usr/local/bin/freeswitch
RUN ln -s /usr/local/freeswitch/bin/fs_cli /usr/local/bin/fs_cli

RUN git clone -b v3.6 https://github.com/iNextrix/ASTPP /usr/src/ASTPP
RUN cp /usr/src/ASTPP/freeswitch/init/freeswitch.debian.init /etc/init.d/freeswitch
RUN chmod 755 /etc/init.d/freeswitch
RUN chmod +x /etc/init.d/freeswitch
RUN update-rc.d freeswitch defaults
RUN chkconfig --add freeswitch
RUN chkconfig --level 345 freeswitch on

RUN cp /usr/src/ASTPP/freeswitch/conf/autoload_configs/* /usr/local/freeswitch/conf/autoload_configs/
RUN cp -rf /usr/src/ASTPP/freeswitch/scripts/* /usr/local/freeswitch/scripts/
RUN cp -rf /usr/src/ASTPP/freeswitch/sounds/*.wav /usr/local/freeswitch/sounds/en/us/callie/
RUN chmod -Rf 777 /usr/local/freeswitch/sounds/en/us/callie/
RUN rm -rf  /usr/local/freeswitch/conf/dialplan/*
RUN touch /usr/local/freeswitch/conf/dialplan/astpp.xml
RUN rm -rf  /usr/local/freeswitch/conf/directory/*
RUN touch /usr/local/freeswitch/conf/directory/astpp.xml
RUN rm -rf  /usr/local/freeswitch/conf/sip_profiles/*
RUN touch /usr/local/freeswitch/conf/sip_profiles/astpp.xml
