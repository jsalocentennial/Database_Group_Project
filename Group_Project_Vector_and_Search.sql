--This file contains the queries related to the VECTOR / HYBRID Search functionality
--Run the Main datafile before performing these tests

-- Semantic Search of Book Descriptions
SELECT BOOK_ID,
    BOOKS_NAME,
    VECTOR_DISTANCE(
        BOOKS_EMBEDDING,
        VECTOR_EMBEDDING(
            ALL_MINILM_L12_V2 USING 'stories about magic' AS data
        ),
        COSINE
    ) AS DISTANCE
FROM BOOKS
WHERE BOOKS_EMBEDDING IS NOT NULL
ORDER BY DISTANCE
FETCH FIRST 5 ROWS ONLY;

-- Hybrid Search: Fantasy Books Under or Equal to $25
SELECT BOOK_ID,
    BOOKS_NAME,
    BOOKS_PRICE,
    VECTOR_DISTANCE(
        BOOKS_EMBEDDING,
        VECTOR_EMBEDDING(
            ALL_MINILM_L12_V2 USING 'stories about magic' AS data
        ),
        COSINE
    ) AS DISTANCE
FROM BOOKS
WHERE BOOKS_CATEGORY_ID = 2
AND BOOKS_PRICE <= 25
AND BOOKS_EMBEDDING IS NOT NULL
ORDER BY DISTANCE
FETCH FIRST 5 ROWS ONLY;

--Semantic Search of customer Review
SELECT R.REVIEW_ID,
    B.BOOKS_NAME,
    R.REVIEW_TEXT,
    R.REVIEW_RATING,
    VECTOR_DISTANCE(
        R.REVIEW_EMBEDDING,
        VECTOR_EMBEDDING(
            ALL_MINILM_L12_V2 USING 'exciting and imaginative story' AS data
        ),
        COSINE
    ) AS DISTANCE
FROM BOOK_REVIEW R
JOIN BOOKS B ON R.BOOK_ID = B.BOOK_ID
WHERE R.REVIEW_EMBEDDING IS NOT NULL
ORDER BY DISTANCE
FETCH FIRST 5 ROWS ONLY;