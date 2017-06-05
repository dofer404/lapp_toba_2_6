# Ubuntu LAPP stack con Apache, PostgreSQL, PHP

FROM ubuntu

MAINTAINER dofer404 version 2.6

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  locales

RUN locale-gen es_AR.UTF-8
ENV LANG='es_AR.UTF-8' LANGUAGE='es_AR:es' LC_ALL='es_AR.UTF-8'

# Instalar control de versiones
RUN apt-get install -y \
  subversion
#  git \

# Descargamos toba 2.6
RUN svn co --non-interactive --trust-server-cert https://repositorio.siu.edu.ar/svn/toba/trunk_versiones/2.6/ /opt/toba_2_6/

# Nos guardamos los proyectos por defecto de la instalación
RUN mv /opt/toba_2_6/proyectos /opt/toba_2_6/proyectos_src

# Instalar Apache,
RUN apt-get install -y \
  apache2

# Instalar PHP y graphviz
RUN apt-get install -y \
  php \
  php-cli \
  php-gd \
  libapache2-mod-php \
  graphviz

# Instalar postgresql
RUN apt-get install -y \
  postgresql \
  postgresql-contrib \
  php-pgsql \
  libapache2-mod-auth-pgsql

# Otras librerías necesarias para toba 2.6
RUN apt-get install -y \
  php-mbstring \
  php-xml

# Quitar archivos APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# somos el usuario postgres
USER postgres

# Iniciamos postgres y le cambiamos la contraseña al usuario postgres
RUN /etc/init.d/postgresql start && \
    psql --command "ALTER USER "postgres" WITH PASSWORD 'postgres';" && \
    /etc/init.d/postgresql stop
# Agregar volumenes para los datos de postgres???
# VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# somos el usuario root
USER root

RUN echo "localhost:5432:*:postgres:postgres" > ~/.pgpass
RUN chmod 0600 ~/.pgpass

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV PATH="${PATH}:/opt/toba_2_6/bin/"

COPY contenedor/configuracion/cli-php.ini     /etc/php/7.0/cli/php.ini
COPY contenedor/configuracion/pg_hba.conf     /etc/postgresql/9.5/main/pg_hba.conf
COPY contenedor/configuracion/postgresql.conf /etc/postgresql/9.5/main/postgresql.conf
COPY contenedor/configuracion/apache2.conf    /etc/apache2/apache2.conf
COPY contenedor/configuracion/apache2-php.ini /etc/php/7.0/apache2/php.ini
COPY contenedor/comandos/instalar_toba_2_6            /usr/bin/instalar_toba_2_6
COPY contenedor/comandos/instalar_toba_2_6_luego_bash /usr/bin/instalar_toba_2_6_luego_bash
COPY contenedor/comandos/iniciar_servicios            /usr/bin/iniciar_servicios

EXPOSE 80
EXPOSE 5432

CMD ["/usr/bin/iniciar_servicios"]
