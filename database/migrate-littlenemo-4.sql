UPDATE gcd_indicia_publisher SET issue_count = 
    (SELECT COUNT(*) FROM gcd_issue 
     WHERE indicia_publisher_id = gcd_indicia_publisher.id);
UPDATE gcd_brand SET issue_count = 
    (SELECT COUNT(*) FROM gcd_issue WHERE brand_id = gcd_brand.id);
