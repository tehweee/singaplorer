const mongoose = require('mongoose');

const arriveSGScheme = mongoose.Schema({

    token: {type:String,required:true},
    fromCountry: {type:String, required:true}, //the country they arrive from so this for example will be london
    fromAirport: {type:String,required:true},
    departureTime: {type:String,required:true},
    arrivalTime :{type:String,required:true},
    pricePerPax: {type:String,required:true},
    totalPrice:{type:String,required:true},
    pax:{type:String,required:true},
    cabinClass:{type:String,required:true},
    userID: {type:mongoose.Schema.Types.ObjectId, ref: 'users',required:true},
});

module.exports = mongoose.model('arriveSGs',arriveSGScheme);