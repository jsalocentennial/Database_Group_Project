--This File contains the queries related to PACKAGE TWO. Start by selecting F5 to compile the scripts
--Then select the queries as neccessary for testing. Run queries individually for a cleaner output

--PACKAGE 2: Book and inventory management

-- Add procedures for adding books, updating book details, adjusting inventory, and generating audit reports.
CREATE OR REPLACE PACKAGE INVENTORY_MANAGEMENT_PACKAGE IS
    PROCEDURE ADD_BOOK(
        P_BOOKS_NAME IN BOOKS.BOOKS_NAME%TYPE,
        P_BOOKS_CATEGORY_ID IN BOOKS.BOOKS_CATEGORY_ID%TYPE,
        P_BOOKS_AUTHOR_ID IN BOOKS.BOOKS_AUTHOR_ID%TYPE,
        P_BOOKS_PUBLISHER_ID IN BOOKS.BOOKS_PUBLISHER_ID%TYPE,
        P_BOOKS_ISBN IN BOOKS.BOOKS_ISBN%TYPE,
        P_BOOKS_PUBLICATION_DATE IN BOOKS.BOOKS_PUBLICATION_DATE%TYPE,
        P_BOOKS_DESCRIPTION IN BOOKS.BOOKS_DESCRIPTION%TYPE,
        P_BOOKS_PRICE IN BOOKS.BOOKS_PRICE%TYPE,
        P_INITIAL_QUANTITY IN INVENTORY.INVENTORY_BOOK_QUANTITY%TYPE,
        P_BOOK_ID OUT BOOKS.BOOK_ID%TYPE
    );

    PROCEDURE UPDATE_BOOK(
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE,
        P_BOOKS_NAME IN BOOKS.BOOKS_NAME%TYPE,
        P_BOOKS_CATEGORY_ID IN BOOKS.BOOKS_CATEGORY_ID%TYPE,
        P_BOOKS_AUTHOR_ID IN BOOKS.BOOKS_AUTHOR_ID%TYPE,
        P_BOOKS_PUBLISHER_ID IN BOOKS.BOOKS_PUBLISHER_ID%TYPE,
        P_BOOKS_ISBN IN BOOKS.BOOKS_ISBN%TYPE,
        P_BOOKS_PUBLICATION_DATE IN BOOKS.BOOKS_PUBLICATION_DATE%TYPE,
        P_BOOKS_DESCRIPTION IN BOOKS.BOOKS_DESCRIPTION%TYPE,
        P_BOOKS_PRICE IN BOOKS.BOOKS_PRICE%TYPE
    );

    PROCEDURE UPDATE_PRICE(
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE,
        P_NEW_PRICE IN BOOKS.BOOKS_PRICE%TYPE
    );

    PROCEDURE ADJUST_INVENTORY(
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE,
        P_QUANTITY_CHANGE IN NUMBER
    );

    PROCEDURE GET_AUDIT_REPORT(
        P_REPORT OUT SYS_REFCURSOR,
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE DEFAULT NULL,
        P_FROM_DATE IN DATE DEFAULT NULL,
        P_TO_DATE IN DATE DEFAULT NULL
    );
END INVENTORY_MANAGEMENT_PACKAGE;
/

CREATE OR REPLACE PACKAGE BODY INVENTORY_MANAGEMENT_PACKAGE IS
    PROCEDURE ADD_BOOK(
        P_BOOKS_NAME IN BOOKS.BOOKS_NAME%TYPE,
        P_BOOKS_CATEGORY_ID IN BOOKS.BOOKS_CATEGORY_ID%TYPE,
        P_BOOKS_AUTHOR_ID IN BOOKS.BOOKS_AUTHOR_ID%TYPE,
        P_BOOKS_PUBLISHER_ID IN BOOKS.BOOKS_PUBLISHER_ID%TYPE,
        P_BOOKS_ISBN IN BOOKS.BOOKS_ISBN%TYPE,
        P_BOOKS_PUBLICATION_DATE IN BOOKS.BOOKS_PUBLICATION_DATE%TYPE,
        P_BOOKS_DESCRIPTION IN BOOKS.BOOKS_DESCRIPTION%TYPE,
        P_BOOKS_PRICE IN BOOKS.BOOKS_PRICE%TYPE,
        P_INITIAL_QUANTITY IN INVENTORY.INVENTORY_BOOK_QUANTITY%TYPE,
        P_BOOK_ID OUT BOOKS.BOOK_ID%TYPE
    )
    IS
    BEGIN
        IF P_INITIAL_QUANTITY IS NULL OR P_INITIAL_QUANTITY < 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Initial inventory quantity cannot be negative or null.');
        END IF;
        IF P_BOOKS_PRICE IS NULL OR P_BOOKS_PRICE < 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Book price cannot be negative or null.');
        END IF;

        INSERT INTO BOOKS (
            BOOKS_NAME,
            BOOKS_CATEGORY_ID,
            BOOKS_AUTHOR_ID,
            BOOKS_PUBLISHER_ID,
            BOOKS_ISBN,
            BOOKS_PUBLICATION_DATE,
            BOOKS_DESCRIPTION,
            BOOKS_PRICE
        )
        VALUES (
            P_BOOKS_NAME,
            P_BOOKS_CATEGORY_ID,
            P_BOOKS_AUTHOR_ID,
            P_BOOKS_PUBLISHER_ID,
            P_BOOKS_ISBN,
            P_BOOKS_PUBLICATION_DATE,
            P_BOOKS_DESCRIPTION,
            P_BOOKS_PRICE
        )
        RETURNING BOOK_ID INTO P_BOOK_ID;

        INSERT INTO INVENTORY (
            INVENTORY_ID,
            INVENTORY_BOOK_ID,
            INVENTORY_BOOK_QUANTITY
        )
        VALUES (
            INVENTORY_ID_SEQ.NEXTVAL,
            P_BOOK_ID,
            P_INITIAL_QUANTITY
        );
    END ADD_BOOK;

    PROCEDURE UPDATE_BOOK(
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE,
        P_BOOKS_NAME IN BOOKS.BOOKS_NAME%TYPE,
        P_BOOKS_CATEGORY_ID IN BOOKS.BOOKS_CATEGORY_ID%TYPE,
        P_BOOKS_AUTHOR_ID IN BOOKS.BOOKS_AUTHOR_ID%TYPE,
        P_BOOKS_PUBLISHER_ID IN BOOKS.BOOKS_PUBLISHER_ID%TYPE,
        P_BOOKS_ISBN IN BOOKS.BOOKS_ISBN%TYPE,
        P_BOOKS_PUBLICATION_DATE IN BOOKS.BOOKS_PUBLICATION_DATE%TYPE,
        P_BOOKS_DESCRIPTION IN BOOKS.BOOKS_DESCRIPTION%TYPE,
        P_BOOKS_PRICE IN BOOKS.BOOKS_PRICE%TYPE
    )
    IS
    BEGIN
        IF P_BOOKS_PRICE IS NULL OR P_BOOKS_PRICE < 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Book price cannot be negative or null.');
        END IF;

        UPDATE BOOKS
        SET BOOKS_NAME = P_BOOKS_NAME,
            BOOKS_CATEGORY_ID = P_BOOKS_CATEGORY_ID,
            BOOKS_AUTHOR_ID = P_BOOKS_AUTHOR_ID,
            BOOKS_PUBLISHER_ID = P_BOOKS_PUBLISHER_ID,
            BOOKS_ISBN = P_BOOKS_ISBN,
            BOOKS_PUBLICATION_DATE = P_BOOKS_PUBLICATION_DATE,
            BOOKS_DESCRIPTION = P_BOOKS_DESCRIPTION,
            BOOKS_PRICE = P_BOOKS_PRICE
        WHERE BOOK_ID = P_BOOK_ID;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'Book ID not found.');
        END IF;
    END UPDATE_BOOK;

    PROCEDURE UPDATE_PRICE(
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE,
        P_NEW_PRICE IN BOOKS.BOOKS_PRICE%TYPE
    )
    IS
    BEGIN
        IF P_NEW_PRICE IS NULL OR P_NEW_PRICE < 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Book price cannot be negative or null.');
        END IF;

        UPDATE BOOKS
        SET BOOKS_PRICE = P_NEW_PRICE
        WHERE BOOK_ID = P_BOOK_ID;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'Book ID not found.');
        END IF;
    END UPDATE_PRICE;

    PROCEDURE ADJUST_INVENTORY(
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE,
        P_QUANTITY_CHANGE IN NUMBER
    )
    IS
        V_CURRENT_QUANTITY INVENTORY.INVENTORY_BOOK_QUANTITY%TYPE;
    BEGIN
        IF P_QUANTITY_CHANGE IS NULL
           OR P_QUANTITY_CHANGE = 0
           OR P_QUANTITY_CHANGE != TRUNC(P_QUANTITY_CHANGE) THEN
            RAISE_APPLICATION_ERROR(-20023, 'Inventory adjustment must be a non-zero whole number.');
        END IF;

        SELECT INVENTORY_BOOK_QUANTITY
        INTO V_CURRENT_QUANTITY
        FROM INVENTORY
        WHERE INVENTORY_BOOK_ID = P_BOOK_ID
        FOR UPDATE;

        IF V_CURRENT_QUANTITY + P_QUANTITY_CHANGE < 0 THEN
            RAISE_APPLICATION_ERROR(-20024, 'Inventory adjustment would result in negative stock.');
        END IF;

        UPDATE INVENTORY
        SET INVENTORY_BOOK_QUANTITY = V_CURRENT_QUANTITY + P_QUANTITY_CHANGE
        WHERE INVENTORY_BOOK_ID = P_BOOK_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20025, 'Inventory record not found for book ID.');
    END ADJUST_INVENTORY;

    PROCEDURE GET_AUDIT_REPORT(
        P_REPORT OUT SYS_REFCURSOR,
        P_BOOK_ID IN BOOKS.BOOK_ID%TYPE,
        P_FROM_DATE IN DATE,
        P_TO_DATE IN DATE
    )
    IS
    BEGIN
        IF P_FROM_DATE IS NOT NULL
           AND P_TO_DATE IS NOT NULL
           AND TRUNC(P_FROM_DATE) > TRUNC(P_TO_DATE) THEN
            RAISE_APPLICATION_ERROR(-20026, 'Report start date must not be after end date.');
        END IF;

        OPEN P_REPORT FOR
            SELECT A.AUDIT_ID,
                   A.RECORD_ID AS BOOK_ID,
                   B.BOOKS_NAME AS BOOK_TITLE,
                   A.TABLE_NAME,
                   A.COLUMN_NAME,
                   A.ACTION_TYPE,
                   A.OLD_VALUE,
                   A.NEW_VALUE,
                   A.AUDIT_DATE
            FROM AUDIT_LOG A
            LEFT JOIN BOOKS B
                ON B.BOOK_ID = A.RECORD_ID
            WHERE A.TABLE_NAME IN ('BOOKS', 'INVENTORY')
              AND (P_BOOK_ID IS NULL OR A.RECORD_ID = P_BOOK_ID)
              AND (P_FROM_DATE IS NULL OR A.AUDIT_DATE >= TRUNC(P_FROM_DATE))
              AND (P_TO_DATE IS NULL OR A.AUDIT_DATE < TRUNC(P_TO_DATE) + 1)
            ORDER BY A.AUDIT_DATE, A.AUDIT_ID;
    END GET_AUDIT_REPORT;
END INVENTORY_MANAGEMENT_PACKAGE;
/


--Testing for package two

SET SERVEROUTPUT ON

SAVEPOINT PACKAGE_TWO_TEST;

-- Add Book
DECLARE
    V_NEW_BOOK_ID BOOKS.BOOK_ID%TYPE;
BEGIN
    INVENTORY_MANAGEMENT_PACKAGE.ADD_BOOK(
        P_BOOKS_NAME => 'Package Two Test Book',
        P_BOOKS_CATEGORY_ID => 1,
        P_BOOKS_AUTHOR_ID => 1,
        P_BOOKS_PUBLISHER_ID => 1,
        P_BOOKS_ISBN => '9780000000001',
        P_BOOKS_PUBLICATION_DATE => DATE '2026-01-01',
        P_BOOKS_DESCRIPTION => 'Test description for the Package Two add-book operation.',
        P_BOOKS_PRICE => 24.99,
        P_INITIAL_QUANTITY => 10,
        P_BOOK_ID => V_NEW_BOOK_ID
    );
END;
/
select * from books;
select * from audit_log;

SELECT TABLE_NAME, COLUMN_NAME, ACTION_TYPE, NEW_VALUE
FROM AUDIT_LOG
WHERE RECORD_ID = (
    SELECT BOOK_ID
    FROM BOOKS
    WHERE BOOKS_ISBN = '9780000000001'
)
  AND TABLE_NAME IN ('BOOKS', 'INVENTORY')
ORDER BY AUDIT_ID;

--- Before Update Changes
SELECT b.book_id,
       b.books_name,
       b.books_price,
       i.inventory_book_quantity AS qty_before
FROM   books b
JOIN   inventory i ON i.inventory_book_id = b.book_id
WHERE  b.book_id = 1;

-- Update Book Details
BEGIN
    inventory_management_package.update_book(
        p_book_id     => 1,
        p_books_name  => 'Scary Book Update',
        p_books_category_id => 1,
        p_books_author_id => 1,
        p_books_publisher_id => 1,
        p_books_isbn => '1234567891234',
        p_books_publication_date => DATE '2000-01-01',
        p_books_description => 'Updated by Package Two test.',
        p_books_price => 12.99
    );
END;
/

SELECT book_id,
       books_name,
       books_price,
       LENGTH(books_description) AS desc_len
FROM   books
WHERE  book_id = 1;

-- Update Price 
BEGIN
    inventory_management_package.update_price(1, 15.99);
END;
/

SELECT book_id, books_price
FROM   books
WHERE  book_id = 1;

--  Adjust Inventory (+5) ===
BEGIN
    inventory_management_package.adjust_inventory(1, 5);
END;
/

SELECT inventory_book_quantity AS qty_after
FROM   inventory
WHERE  inventory_book_id = 1;

-- Audit Log for Book 1
SELECT table_name,
       column_name,
       action_type,
       SUBSTR(old_value, 1, 25) AS old_val,
       SUBSTR(new_value, 1, 25) AS new_val
FROM   audit_log
WHERE  record_id = 1
  AND  table_name IN ('BOOKS', 'INVENTORY')
ORDER BY audit_id;

select * from audit_log;

ROLLBACK TO PACKAGE_TWO_TEST;