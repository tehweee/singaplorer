const mongoose = require('mongoose');

const hotelScheme = mongoose.Schema({

    hotelID: {type:String,unique:true,required:true},
    title: {type:String, required:true},
    address: {type:String,required:true},
    latitude:{type:String,required:true},
    longitude:{type:String,required:true},
    totalPrice:{type:String,required:true},
    userID: {type:mongoose.Schema.Types.ObjectId, ref: 'users',required:true},
    pax:{type:String,required:true},
    arrivalDate:{type:String,required:true},
    departureDate:{type:String,required:true},
    city:{type:String,required:true},
                reviewCount: {type:String,required:true},
            reviewScore: {type:String,required:true},


});

module.exports = mongoose.model('hotels',hotelScheme);