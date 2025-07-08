const mongoose = require('mongoose');

const userScheme = mongoose.Schema({

    username: {type:String, required:true},
    phoneNumber: {type:String,required:false},
    password: {type:String,required:true},
    email :{type:String,required:true},
    aiTokens:{type:String,required:false},
    timeZone:{type:String,required:false},
    nationality:{type:String,required:false},
    language:{type:String,required:false},
    preferences:{type:[String],required:false},
    token:{type:String}


});

module.exports = mongoose.model('users',userScheme);