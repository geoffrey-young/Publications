#!/bin/ksh

# Keep Apache and mod_perl up to date.
# Install in root crontab
#
# The result is a nice diff of the change logs
# for both mod_perl and Apache, emailed 
# directly to you.

source="/path/to/your/source"
email="your@email.address"
  
/usr/local/apache/bin/apachectl stop

cd $source/modperl
make install

>/usr/local/apache/logs/error_log

/usr/local/apache/bin/apachectl start

sleep 10
today=`date +%b" "%d", "%Y`
  
cd $source/modperl
echo "\n---- mod_perl Changes ----" > Changes.diff
diff -u Changes.old Changes >> Changes.diff

cd $source/apache-1.3/src
echo "\n---- Apache Changes ----" > Changes.diff
diff -u CHANGES.old CHANGES >> Changes.diff

cat /usr/local/apache/logs/error_log \
  $source/modperl/Changes.diff \
  $source/apache-1.3/src/Changes.diff \
  | mail -s "httpd $today" $email
