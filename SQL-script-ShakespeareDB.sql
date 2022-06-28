USE shakespearedb;

# Q1: List the work title and the genre type for every work dated before 1600
SELECT DISTINCT Works.Title, Works.GenreType
FROM Works
WHERE Works.Date < 1600;

# Q2: Identify the unique genre types of each of Shakespeare’s works
SELECT DISTINCT Works.Title, Works.GenreType
FROM Works;
## Or:
SELECT DISTINCT Works.GenreType
FROM (SELECT DISTINCT Works.Title FROM Works);

# Q3: Retrieve each character’s name whose abbreviation starts with the letter ’B’ 
## and say a paragraph that includes either the word ’sir’ or the word ’lady’
SELECT DISTINCT
    CharName,
    Abbrev
FROM
    Characters AS c
LEFT JOIN (
SELECT DISTINCT
    character_id,
    Plaintext
FROM
	Paragraphs) AS p
ON c.id = p.character_id
WHERE
    c.Abbrev LIKE 'B%' AND p.PlainText LIKE '%sir%' OR '%lady%';

# Q4: Retrieve the chapter description and the work title of the ’poem’ or ’sonnet’ genre type
SELECT DISTINCT
   w.Title,
   w.GenreType,
   c.Description
FROM
    works AS w
INNER JOIN (
SELECT DISTINCT
    Description,
	work_id
FROM
	Chapters) AS c
ON w.id = c.work_id
WHERE
    w.GenreType = 'Poem' OR w.GenreType = 'Sonnet';

#Q5: List the names of characters who have at least one scene in the Macbeth play
SELECT DISTINCT CharName
FROM Characters AS char_table
INNER JOIN (SELECT DISTINCT character_id, chapter_id FROM Paragraphs) AS p_table ON char_table.id = p_table.character_id
INNER JOIN (SELECT DISTINCT id, Scene, work_id FROM Chapters) AS chap_table ON p_table.chapter_id = chap_table.id
INNER JOIN (SELECT DISTINCT id, Title FROM Works) AS w_table ON chap_table.work_id = w_table.id
WHERE
    w_table.Title = 'Macbeth'
    AND chap_table.Scene >= 1;
    
# Another way - same number of result rows
SELECT DISTINCT CharName
FROM
(SELECT DISTINCT
	Works.id AS wid,
    Works.Title,
    Chapters.id AS chapid,
    Chapters.Scene,
    Chapters.work_id AS chapwid,
    Paragraphs.character_id AS pcharid,
    Paragraphs.chapter_id AS pchapid,
    Characters.id AS charid,
    Characters.CharName
FROM
	Works
INNER JOIN Chapters ON Works.id = Chapters.work_id
INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
INNER JOIN Characters ON Paragraphs.character_id = Characters.id
WHERE
	Title = 'Macbeth'
    AND Scene >= 1) AS result_table;
    
# Q6: Retrieve the title of the works dated 1612, 1610, 1608 or 1606
SELECT DISTINCT 
	Works.Title,
	Works.Date
FROM Works
WHERE Works.Date = 1612 
	OR Works.Date = 1610
    OR Works.Date = 1608
    OR Works.Date = 1606;
    
# Q7: Find the number of characters of each work, ordered from the top down
SELECT DISTINCT
	Title,
    COUNT(DISTINCT charid) AS charnum
FROM
(SELECT DISTINCT
	Works.id AS wid,
    Works.Title,
    Chapters.id AS chapid,
    Chapters.work_id AS chapwid,
    Paragraphs.character_id AS pcharid,
    Paragraphs.chapter_id AS pchapid,
    Characters.id AS charid,
    Characters.CharName
FROM
	Works
INNER JOIN Chapters ON Works.id = Chapters.work_id
INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
INNER JOIN Characters ON Paragraphs.character_id = Characters.id) AS joined_table
GROUP BY Title
ORDER BY charnum DESC;

# Q8: Retrieve the number of paragraphs for each character in ’Hamlet’
SELECT DISTINCT
	wpchar_rtable.CharName,
    SUM(wpchar_rtable.ParagraphNum) AS totalpnum
FROM
(SELECT DISTINCT
	Works.id AS wid,
    Works.Title,
    Chapters.id AS chapid,
    Chapters.work_id AS chapwid,
    Paragraphs.ParagraphNum,
    Paragraphs.character_id AS pcharid,
    Paragraphs.chapter_id AS pchapid,
    Characters.id AS charid,
    Characters.CharName
FROM
	Works
INNER JOIN Chapters ON Works.id = Chapters.work_id
INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
INNER JOIN Characters ON Paragraphs.character_id = Characters.id
WHERE
	Works.Title = 'Hamlet') AS wpchar_rtable
GROUP BY wpchar_rtable.CharName
ORDER BY totalpnum DESC;

# Q9: Find characters with more than 200 paragraphs of dialogue, and the number of works
## Method 1:
SELECT DISTINCT
	CharName,
	COUNT(DISTINCT Works.id) as wnum
FROM
	Works
INNER JOIN Chapters ON Works.id = Chapters.work_id
INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
INNER JOIN Characters ON Paragraphs.character_id = Characters.id
WHERE 
	ParagraphNum > 200
GROUP BY CharName;

## Method 2:
SELECT DISTINCT
	e.CharName,
    COUNT(DISTINCT e.Title) as wnum
FROM
(SELECT DISTINCT
	Works.id AS wid,
    Works.Title,
    Chapters.id AS chapid,
    Chapters.work_id AS chapwid,
    Paragraphs.ParagraphNum,
    Paragraphs.character_id AS pcharid,
    Paragraphs.chapter_id AS pchapid,
    Characters.id AS charid,
    Characters.CharName
FROM
	Works
INNER JOIN Chapters ON Works.id = Chapters.work_id
INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
INNER JOIN Characters ON Paragraphs.character_id = Characters.id
WHERE ParagraphNum > 200
GROUP BY CharName) AS e
GROUP BY Charname;

# Q10: Retrieve the name of Hamlet characters who appear in Shakespeare’s other works
## Method 1:
SELECT DISTINCT CharName
FROM Characters
WHERE EXISTS (SELECT DISTINCT Works.id AS wid,
			                  Works.Title,
                              Chapters.id AS chapid,
                              Chapters.work_id AS chapwid,
                              Paragraphs.ParagraphNum,
                              Paragraphs.character_id AS pcharid,
                              Paragraphs.chapter_id AS pchapid,
                              Characters.id AS charid,
                              Characters.CharName
			   FROM Works
               INNER JOIN Chapters ON Works.id = Chapters.work_id
               INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
               INNER JOIN Characters AS q ON Paragraphs.character_id = Characters.id
               WHERE Title = 'Hamlet' 
					 AND CharName != 'Hamlet'
                     AND Characters.CharName = q.CharName);
## Test Q10 Method 2:
SELECT
	wpchar_rtable.CharName
FROM
(SELECT DISTINCT
	Works.id AS wid,
   	 Works.Title,
    	Chapters.id AS chapid,
    	Chapters.work_id AS chapwid,
    	Paragraphs.ParagraphNum,
    	Paragraphs.character_id AS pcharid,
    	Paragraphs.chapter_id AS pchapid,
    	Characters.id AS charid,
   	Characters.CharName
FROM
	Works
INNER JOIN Chapters ON Works.id = Chapters.work_id
INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
INNER JOIN Characters ON Paragraphs.character_id = Characters.id
WHERE
	Works.Title = 'Hamlet') AS wpchar_rtable
WHERE wpchar_rtable.CharName != 'Hamlet'
GROUP BY wpchar_rtable.CharName;

# Q11: Retrieve the names of all characters who appear in the work that have the highest number of paragraphs among all of Shakespeare’s works (Top 10)
SELECT DISTINCT
	a.CharName,
    MAX(a.totalpnum) AS maxpnum
FROM
(SELECT DISTINCT
	Works.id AS wid,
    Works.Title,
    Chapters.id AS chapid,
    Chapters.Scene,
    Chapters.work_id AS chapwid,
    SUM(Paragraphs.ParagraphNum) as totalpnum,
    Paragraphs.character_id AS pcharid,
    Paragraphs.chapter_id AS pchapid,
    Characters.id AS charid,
    Characters.CharName
FROM
	Works
INNER JOIN Chapters ON Works.id = Chapters.work_id
INNER JOIN Paragraphs ON Chapters.id = Paragraphs.chapter_id
INNER JOIN Characters ON Paragraphs.character_id = Characters.id
GROUP BY Title) AS a
GROUP BY a.CharName;

# Q12:  Retrieve the chapters’ descriptions of Othello, Passionate Pilgrim, and Twelfth Night works without including the chapters with missing descriptions
SELECT DISTINCT
	a.Description
FROM
(SELECT DISTINCT
	Works.id,
    Works.Title,
    Chapters.work_id,
    Chapters.Description
FROM
	Works
INNER JOIN Chapters ON Chapters.work_id = Works.id
WHERE
	Works.Title = 'Othello' OR Works.Title = 'Passionate Pilgrim' OR Works.Title = 'Twelfth Night') AS a
WHERE a.Description IS NOT NULL;

# Q13: List the names of characters who say ’How now! what’s the matter?'
SELECT DISTINCT
	b.CharName
FROM
(SELECT DISTINCT
	Characters.id,
    Characters.CharName,
    Paragraphs.character_id,
    Paragraphs.PlainText
FROM
	Characters
INNER JOIN Paragraphs ON Characters.id = Paragraphs.character_id
WHERE
	 Paragraphs.PlainText = 'How now! what’s the matter?') AS b;

# Q14: List the paragraphs that more than five different characters have said
SELECT DISTINCT
	PlainText,
    COUNT(DISTINCT character_id) as charcount
FROM Paragraphs
GROUP BY Paragraphs.PlainText
HAVING charcount > 5;