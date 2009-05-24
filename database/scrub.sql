-- This script is used to remove sensitive data from production (or replicated)
-- database dumps.  It must be run before anything else is done to the dump.

SET SESSION sql_mode='STRICT_ALL_TABLES';

UPDATE Indexers SET password='',
                    eMail='indexer@comics.org',
                    Message=NULL;

