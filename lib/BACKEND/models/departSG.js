const mongoose = require('mongoose');

const departSGScheme = mongoose.Schema({

    slug: { type: String, required: true },
    toCountry: { type: String, required: true }, //the country they depart to so this for example will be london
    toCityName: { type: String, required: true },
    departureTime: { type: String, required: true },
    arrivalTime: { type: String, required: true },
    pricePerPax: { type: String, required: true },
    totalPrice: { type: String, required: true },
    pax: { type: String, required: true },
    cabinClass: { type: String, required: true },
    userID: { type: mongoose.Schema.Types.ObjectId, ref: 'users', required: true },
    cabinClass: { type: String, required: true },


});

module.exports = mongoose.model('departSGs', departSGScheme);