CREATE OR REPLACE PROCEDURE COPY_SCHEMA_DATA (
    p_source_schema IN VARCHAR2,
    p_target_schema IN VARCHAR2
) IS
    CURSOR table_cursor IS
        SELECT table_name FROM all_tables WHERE owner = UPPER(p_source_schema);

    CURSOR view_cursor IS
        SELECT view_name, text FROM all_views WHERE owner = UPPER(p_source_schema);

    v_table_name   VARCHAR2(200);
    v_view_name    VARCHAR2(200);
    v_view_text    CLOB;
BEGIN
    -- Drop and recreate tables
    FOR table_rec IN table_cursor LOOP
        v_table_name := table_rec.table_name;

        -- Drop table in the target schema if it exists
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || p_target_schema || '.' || v_table_name || ' CASCADE CONSTRAINTS';
            DBMS_OUTPUT.PUT_LINE('Dropped table: ' || p_target_schema || '.' || v_table_name);
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN -- Ignore "table not found" error
                    RAISE;
                END IF;
        END;

        -- Create table in the target schema
        EXECUTE IMMEDIATE 'CREATE TABLE ' || p_target_schema || '.' || v_table_name || ' AS SELECT * FROM ' || p_source_schema || '.' || v_table_name || ' WHERE 1=2';
        DBMS_OUTPUT.PUT_LINE('Created table: ' || v_table_name);

        -- Insert data into the new table
        EXECUTE IMMEDIATE 'INSERT INTO ' || p_target_schema || '.' || v_table_name || ' SELECT * FROM ' || p_source_schema || '.' || v_table_name;
        DBMS_OUTPUT.PUT_LINE('Inserted data into table: ' || v_table_name);
    END LOOP;

    -- Drop and recreate views
    FOR view_rec IN view_cursor LOOP
        v_view_name := view_rec.view_name;
        v_view_text := view_rec.text;

        -- Drop view in the target schema if it exists
        BEGIN
            EXECUTE IMMEDIATE 'DROP VIEW ' || p_target_schema || '.' || v_view_name;
            DBMS_OUTPUT.PUT_LINE('Dropped view: ' || p_target_schema || '.' || v_view_name);
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE != -942 THEN -- Ignore "view not found" error
                    RAISE;
                END IF;
        END;

        -- Replace the schema in the view definition
        v_view_text := REPLACE(v_view_text, '"' || p_source_schema || '"', '"' || p_target_schema || '"');

        -- Create the view in the target schema
        EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW ' || p_target_schema || '.' || v_view_name || ' AS ' || v_view_text;
        DBMS_OUTPUT.PUT_LINE('Created view: ' || v_view_name);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Schema copy complete!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/