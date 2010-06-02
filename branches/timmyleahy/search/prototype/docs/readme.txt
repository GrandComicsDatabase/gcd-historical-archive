Requirements:

Java:
http://java.sun.com/javase/downloads/index.jsp
You will need Java 1.6.x (SE) installed. 

MySQL and The GCD Database
You will need to have MySQL running with a image of the GCD database. The 2010-03-06 dump was is used by the prototype:
http://dev.comics.org/data/ 

[gcd-solr] will be the directory that the zip file has been unpacked in

1. Configure the database settings. Located in [gcd-solr]/example/solr/conf/data-config.xml
  - You will most likely need to change the following attributes in <dataSource>
    - The ip/host, port number, and database name in the 'url' attribute.
      (currently set to localhost:3306/gcd)
    - The user name in the 'user' attribute. Solr doesn't write anything to the database but
      it's always a good idea to have a read only account just for it to use.
    - The password in the 'password' attribute.

2. Navigate to [gcd-solr]/example and execute the following command:
   java -jar start.jar
   
3. You should start to see log messages on the console. If Solr starts up successfully, you should see the
   following messages:
   INFO: SolrUpdateServlet.init() done
   ####-##-## ##:##:##.###::INFO:  Started SocketConnector @ 0.0.0.0:8983

4. Go to your browser and open http://localhost:8983 and follow the instructions on the home page

While you're using the browser, Solr will continue to log to the console as well as a log file in:
[gcd-solr]/example/logs

5. To stop the server, send a break to it (ctrl+c)