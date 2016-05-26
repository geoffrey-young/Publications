## [Articles Written for perl.com](articles/)

In 2003, I wrote a series of articles on mod_perl 2.0 for [perl.com](http://www.perl.com), which I have exported as PDF documents and archived here.

 * [Filters in Apache 2.0](http://www.perl.com/pub/a/2003/04/17/filters.html) begins the series with an introduction to Apache 2.0's new output filter mechanism.
 * [Testing mod_perl 2.0](http://www.perl.com/pub/a/2003/05/22/testing.html) discusses how to use the powerful [Apache-Test](http://httpd.apache.org/test) framework to test your mod_perl applications.
 * [Integrating mod_perl with Apache 2.1 Authentication](http://www.perl.com/pub/a/2003/07/08/mod_perl.html) shows how to leverage the new Apache 2.1 authentication provider mechanism and write Digest providers in Perl. It's very cool stuff.

You can find code from the articles in the [code](code/) directory

 * [Apache-Clean-2.0](code/Apache-Clean-2.0) - code from both [Filters in Apache 2.0](http://www.perl.com/pub/a/2003/04/17/filters.html) and [Testing mod_perl 2.0](http://www.perl.com/pub/a/2003/05/22/testing.html)
 * [Apache-Clean-1.0](code/Apache-Clean-1.0) - code from [Testing mod_perl 2.0](http://www.perl.com/pub/a/2003/05/22/testing.html) that shows [Apache-Test](http://httpd.apache.org/test) in use with mod_perl 1.x.
 * [Apache-AuthenHook-2.00_01](code/Apache-AuthenHook-2.00_01) - code from [Integrating mod_perl with Apache 2.1 Authentication](http://www.perl.com/pub/a/2003/07/08/mod_perl.html)

although all modules have been updated since then, and can be seen in their current version on CPAN

 * [Apache::AuthenHook](http://search.cpan.org/~geoff/Apache-AuthenHook/)
 * [Apache::Clean](http://search.cpan.org/~geoff/Apache-Clean/)
