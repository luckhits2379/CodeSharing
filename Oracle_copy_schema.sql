CREATE OR REPLACE PROCEDURE sync_tables_and_views(source_schema VARCHAR2) IS
BEGIN
    -- Handle tables from the source schema
    FOR src_table IN (SELECT table_name FROM all_tables WHERE owner = UPPER(source_schema)) LOOP
        -- Check if the table exists in the current schema
        IF EXISTS (SELECT 1 FROM user_tables WHERE table_name = src_table.table_name) THEN
            -- Drop the existing table
            EXECUTE IMMEDIATE 'DROP TABLE ' || src_table.table_name || ' CASCADE CONSTRAINTS';
        END IF;

        -- Create and populate the table from the source schema
        EXECUTE IMMEDIATE 'CREATE TABLE ' || src_table.table_name || 
                          ' AS SELECT * FROM ' || source_schema || '.' || src_table.table_name;
    END LOOP;

    -- Handle views from the source schema
    FOR src_view IN (SELECT view_name, text FROM all_views WHERE owner = UPPER(source_schema)) LOOP
        -- Check if the view exists in the current schema
        IF EXISTS (SELECT 1 FROM user_views WHERE view_name = src_view.view_name) THEN
            -- Drop the existing view
            EXECUTE IMMEDIATE 'DROP VIEW ' || src_view.view_name;
        END IF;

        -- Create the view in the current schema
        EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || src_view.view_name || 
                          ' AS ' || src_view.text;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Tables and views have been synchronized from ' || source_schema || ' to the current schema.');
END;