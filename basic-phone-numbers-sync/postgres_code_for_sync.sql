---  ORG A CODE

-- FUNCTION: schemadev.update_contact_phone()

-- DROP FUNCTION schemadev.update_contact_phone();

CREATE FUNCTION schemadev.update_contact_phone()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
 DECLARE
  oldxmlbinary varchar;
 BEGIN
     -- save old value
     oldxmlbinary := get_xmlbinary();
     -- change value base64 to ensure writing to _trigger_log is enabled
    SET LOCAL xmlbinary TO 'base64';

     IF new.phone != old.phone THEN
          UPDATE schematest.contact
          SET phone = new.phone, contact_uid__c=1
          WHERE email = old.email;
     END IF;

     -- Reset the value
     EXECUTE 'SET LOCAL xmlbinary TO ' || oldxmlbinary;
     RETURN NEW;
 END;
 $BODY$;


 -- Trigger: update_schema2_contact

 -- DROP TRIGGER update_schema2_contact ON schemadev.contact;

 CREATE TRIGGER update_schema2_contact
     AFTER UPDATE
     ON schemadev.contact
     FOR EACH ROW
     EXECUTE PROCEDURE schemadev.update_contact_phone();



--- ORG B  CODE

-- FUNCTION: schemadev.update_contact_phone_b()

-- DROP FUNCTION schematest.update_contact_phone_b();

CREATE FUNCTION schematest.update_contact_phone_b()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
 DECLARE
  oldxmlbinary varchar;
 BEGIN
     -- save old value
     oldxmlbinary := get_xmlbinary();
     -- change value base64 to ensure writing to _trigger_log is enabled
    SET LOCAL xmlbinary TO 'base64';

    IF new.phone != old.phone THEN
         UPDATE schemadev.contact
         SET phone = new.phone, contact_uid__c=1
         WHERE email = old.email;
    END IF;

     -- Reset the value
     EXECUTE 'SET LOCAL xmlbinary TO ' || oldxmlbinary;
     RETURN NEW;
 END;
 $BODY$;



 -- Trigger: update_schema2_contact

 -- DROP TRIGGER update_schema1_contact ON schematest.contact;


CREATE TRIGGER update_schema1_contact
    AFTER UPDATE
    ON schematest.contact
    FOR EACH ROW
    EXECUTE PROCEDURE schematest.update_contact_phone_b();




--- TEST QUERY

UPDATE schemadev.contact SET phone='111' WHERE email = 'lbailey@salesforce.com';
