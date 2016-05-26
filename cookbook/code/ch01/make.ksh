#!/bin/ksh
  
# Keep Apache and mod_perl up to date
# Install in non-root crontab.

source="/path/to/your/source"

echo "about to update apache\n"
cd $source/apache-1.3
cp src/CHANGES src/CHANGES.old
cvs update

echo "about to update modperl\n"
cd $source/modperl
make realclean
cp Changes Changes.old
cvs update -dP

echo "about to make modperl\n"
perl Makefile.PL \
     APACHE_SRC=$source/apache-1.3/src \
     APACHE_PREFIX=/usr/local/apache \
     EVERYTHING=1 \
     DO_HTTPD=1 \
     USE_APACI=1 \
     APACI_ARGS='--enable-module=rewrite \
                 --enable-module=info \
                 --enable-module=expires \
                 --disable-module=userdir'
make && make test
