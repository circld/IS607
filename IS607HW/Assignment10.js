// IS607 Week 10 Assignment
// Paul Garaud


// Use mapReduce to calculate total pop by state
var map1 = function() {
    emit(this.state, this.pop);
}

var reduce1 = function(keyState, valPop) {
    return Array.sum(valPop);
}

db.zips.mapReduce( map1, reduce1, 
        { out : 'pop_by_state' } )
