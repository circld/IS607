// IS607 Week 12 Quiz
// Paul Garaud
// nb. I feel embarrassed with how long it took me to write the first
// load statement below.


// 1. Read in data
LOAD CSV WITH HEADERS FROM "file:///C:/Users/Paul/CUNY MSDA/IS607/IS607Quizzes/week-12-quiz-data-courses.csv" AS csvfile
    MERGE (s:Student { 
                firstname: csvfile.GivenName ,
                lastname: csvfile.Surname ,
                id: toInt(csvfile.ID) } 
            )
    MERGE (c:Course { 
                department: csvfile.CourseDept ,
                number: toInt(csvfile.CourseNumber) ,
                title: csvfile.CourseName }
            )
    MERGE (m:Placeholder {
                sid: toInt(csvfile.ID) ,
                cid: toInt(csvfile.CourseNumber) ,
                section: toInt(csvfile.Section) , 
                insructor: csvfile.Instructor ,
                grade: csvfile.Grade }
            )
;

// Create relationships
MATCH (m:Placeholder) WHERE m.grade <> 'IP'
MATCH (n:Student { id: m.sid })
MATCH (c:Course { number: m.cid })
CREATE n-[:Completed { section: m.section ,
    instructor: m.instructor , 
    grade: m.grade }]->c
;

MATCH (m:Placeholder { grade: 'IP' })
MATCH (n:Student { id: m.sid })
MATCH (c:Course { number: m.cid })
CREATE n-[:Enrolled { section: m.section ,
    instructor: m.instructor , 
    grade: m.grade }]->c
;

MATCH (m:Placeholder) DELETE m;

// bring in housing data

LOAD CSV WITH HEADERS FROM "file:///C:/Users/Paul/CUNY MSDA/IS607/IS607Quizzes/week-12-quiz-data-students-and-housing.csv" AS csvfile
    MERGE (:Dormitory { name: csvfile.Dormitory })
;

LOAD CSV WITH HEADERS FROM "file:///C:/Users/Paul/CUNY MSDA/IS607/IS607Quizzes/week-12-quiz-data-students-and-housing.csv" AS csvfile
    MATCH (n:Student { id: toInt(csvfile.ID) })
    MATCH (d:Dormitory { name: csvfile.Dormitory })
    CREATE n-[:Housed { room: csvfile.Room }]->d
    SET n.gender = csvfile.Gender  ,
        n.address = csvfile.StreetAddress  ,
        n.city = csvfile.City  ,
        n.state = csvfile.State  ,
        n.zipcode = csvfile.ZipCode  ,
        n.phone = csvfile.TelephoneNumber
;


// 2. A graph database for this data is a poor choice; a relational solutionwould have been far preferable. For one thing, there are few 'traversals'--these nodes could just have easily have been stored in tables without losing any information or tractability (eg, student, course, enrollment_status tables). If there had been loops in the graph, or other such information that is difficult to capture in traditional relational structures, then a graph database would have been a better choice. As it stands, however, it's hard to argue that this data really represents a 'network' in any meaningful sense of the term.


// 3. Find all roommates of Richard Kowalski
MATCH (n:Student { firstname: 'Richard', lastname: 'Kowalski' })-[r]->(:Dormitory), (m:Student)-[:Housed { room: r.room }]->() RETURN m ;
;


// 4. Update relationship
MATCH (n:Student { firstname: 'Richard', lastname: 'Kowalski' })-[r]->(c:Course { title: 'Finite Mathematics' })
CREATE n-[:Completed {section: r.section, instructor: r.instructor, grade: 'B'}]->c
DELETE r;
