const mongoose = require('mongoose');

const supportScheme = mongoose.Schema({

    userID: {type:mongoose.Schema.Types.ObjectId, ref: 'users',required:true},
    firstName: {type:String,required:true},
    lastName: {type:String,required:true},
    country :{type:String,required:true},
    comment:{type:String,required:true},
    date:{type:String,required:true},



});

module.exports = mongoose.model('supports',supportScheme);