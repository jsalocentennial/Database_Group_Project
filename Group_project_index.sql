--These queries require the main data to be executed first. They are to test the functionality
--Of the indexes. Execute the main Group Project file before performing these tests
--Run scripts individually for a cleaner output

--Check Index was made
SELECT TABLE_NAME,
    INDEX_NAME,
    INDEX_TYPE
FROM USER_INDEXES
WHERE TABLE_NAME = 'BOOKS';

--Sample Query / Use Explain Plan view to see search priority

SELECT BOOK_ID,
    BOOKS_NAME,
    BOOKS_CATEGORY_ID,
    BOOKS_PRICE
FROM BOOKS
WHERE BOOKS_CATEGORY_ID = 2
AND BOOKS_PRICE <= 25;

--Verify the indexed columns and their positions
SELECT TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    COLUMN_POSITION
FROM USER_IND_COLUMNS
WHERE INDEX_NAME = 'IDX_BOOKS_CATEGORY_PRICE'
ORDER BY COLUMN_POSITION;