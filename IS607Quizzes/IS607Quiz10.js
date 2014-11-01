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


// 1. What is the average city population by region?


// 2. Which region has the most people? The fewest?


// 3. What is the total population of each division?


