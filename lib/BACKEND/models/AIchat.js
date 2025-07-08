const mongoose = require('mongoose');

const aiChatScheme = mongoose.Schema({

    userID: {type:mongoose.Schema.Types.ObjectId, ref: 'users',required:true},
    aiMessage: {type:String,required:true},



});

module.exports = mongoose.model('aiChats',aiChatScheme);