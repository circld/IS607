// IS607 Week 10 Quiz
// Paul Garaud


// 1. Which states have populations under 8m?
// All states except: CA, FL, IL, MI, NY, OH, PA, & TX
db.zips.aggregate(
        {
            $group : { _id : '$state', statePop : { $sum : '$pop'} }
        } ,
        { $match : { statePop : {$lt : 8000000}} }
    )

// 2. What is the fifth largest city in NY?
// Brooklyn, 11212
db.zips.aggregate(
        {
            $sort : { 'pop' : -1 }
        } ,
        {
            $match : { 'state' : 'NY' }
        }
    ).toArray()[4]  // indexing starts at 0

// 3. What is the total number of cities in each state?
// AK : 54, AL : 101, ... , WV : 40, WY : 96
var map1 = function() {
    emit(this.state, this.city);
};

var reduce1 = function(keySt, valCity) {
    return valCity.length;
};

db.zips.mapReduce(
        map1 ,
        reduce1 ,
        { out: 'zips_city_count_by_state' }
        )

// Challenge question

// Adding region & division
// Function to add values
var add_attr = function(state_array, attrName, attrValue) {
    for (index in state_array) {
        var newField = {};
        newField[attrName] = attrValue;
        db.zips.update( 
                { state : state_array[index] } , 
                { $set : newField } ,
                { multi : true } )
    }
};

// Add values
add_attr(['CT', 'ME', 'MA', 'NH', 'RI', 'VT'], 'region', 'NE')
add_attr(['CT', 'ME', 'MA', 'NH', 'RI', 'VT'], 'division', 1)
add_attr(['NJ', 'NY', 'PA'], 'region', 'NE')
add_attr(['NJ', 'NY', 'PA'], 'division', 2)
add_attr(['IL', 'IN', 'MI', 'OH', 'WI'], 'region', 'MW')
add_attr(['IL', 'IN', 'MI', 'OH', 'WI'], 'division', 3)
add_attr(['IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD'], 'region', 'MW')
add_attr(['IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD'], 'division', 4)
add_attr(['DE', 'FL', 'GA', 'MD', 'NC', 'SC', 'VA', 'DC', 'WV'], 
        'region', 'S')
add_attr(['DE', 'FL', 'GA', 'MD', 'NC', 'SC', 'VA', 'DC', 'WV'], 
        'division', 5)
add_attr(['AL', 'KY', 'MS', 'TN'], 'region', 'S')
add_attr(['AL', 'KY', 'MS', 'TN'], 'division', 6)
add_attr(['AR', 'LA', 'OK', 'TX'], 'region', 'S')
add_attr(['AR', 'LA', 'OK', 'TX'], 'division', 7)
add_attr(['AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY'],
        'region', 'W')
add_attr(['AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY'],
        'division', 8)
add_attr(['AK', 'CA', 'HI', 'OR', 'WA'], 'region', 'W')
add_attr(['AK', 'CA', 'HI', 'OR', 'WA'], 'division', 9)

// sanity check
db.zips.distinct('region')
db.zips.distinct('division')

// 1. What is the average city population by region?
// MW : 1205, NE : 11,345, S : 9936, W : 7682
var mapc1 = function() {
    emit(this.region, this.pop);
};

var reducec1 = function(keyRegion, valPop) {
    return Array.sum(valPop) / valPop.length;
};

db.zips.mapReduce(
        mapc1 ,
        reducec1 ,
        { out : 'zips_avg_city_pop_by_reg' } )

// 2. Which region has the most people? The fewest?
// biggest: South (85,173,522), smallest: NE (50,807,650)
db.zips.aggregate(
        {
            $group : { _id : '$region', regPop : { $sum : '$pop' } }
        } ,
        {
            $sort : { regPop : 1 }
        } ,
        {
            $group : { _id : '$region', 
                biggestName : { $last : '$_id' } ,
                biggestPop : { $last : '$regPop' } ,
                smallestName : { $first : '$_id' },
                smallestPop : { $first : '$regPop' }
            }
        } ,
        {
            $project :
            { _id : 0 ,
              bigRegion : { name : '$biggestName', pop : '$biggestPop' } ,
              smallRegion : { name : '$smallestName', pop : '$smallestPop' }
            }
        }
    )

// 3. What is the total population of each division?
// div 1 (13,205,417), 2 (37,602,233), ... , 8 (13,657,960), 9 (39,116,830)
db.zips.aggregate(
        {
            $group : { _id : '$division',  divPop : { $sum : '$pop' } }
        } ,
        {
            $sort : { _id : 1 }
        }
    )

