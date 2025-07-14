const mongoose = require('mongoose');

const planScheme = mongoose.Schema({

    unique_key: { type: String, require: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'users', },
    arriveSGId: { type: mongoose.Schema.Types.ObjectId, ref: 'arriveSGs', },
    departSGId: { type: mongoose.Schema.Types.ObjectId, ref: 'departSGs', },
    hotelId: { type: mongoose.Schema.Types.ObjectId, ref: 'hotels', },
    attractionId: [{ type: mongoose.Schema.Types.ObjectId, ref: 'attractions', }]

});

module.exports = mongoose.model('plans', planScheme);