Requirements:

Java:
http://java.sun.com/javase/downloads/index.jsp
You will need Java 1.6.x (SE) installed. If you are running Ubunutu, you can follow these pages on how to install Java:

https://help.ubuntu.com/community/Java
https://help.ubuntu.com/community/JavaInstallation 

Ant:
http://ant.apache.org/
You will also need Ant, the Java build tool, installed as well. If you are running Ubunutu, you can just run 'apt-get install ant'. If not, please follow the installation instructions at http://ant.apache.org/manual/install.html

MySQL and The GCD Database
You will need to have MySQL running with a image of the GCD database. The one that's been used with the prototype can be found here:
http://dev.comics.org/data/ 

Solr:
http://lucene.apache.org/solr/
You will need a distribution of Solr. It comes with an embedded Java web server (Jetty) and that's all you will need to run 

1. Check out the prototype from GCD's Subversion repository:
svn co [url]

2. Copy solr distro into dist directory
