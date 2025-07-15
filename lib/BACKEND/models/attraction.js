const mongoose = require('mongoose');

const attractionScheme = mongoose.Schema({

    slug: { type: String, required: true },
    title: { type: String, required: true },
    pricePerPax: { type: String, required: true },
    address: { type: String, required: true },
    description: { type: String, required: true },
    latitude: { type: String, required: true },
    longitude: { type: String, required: true },
    totalPrice: { type: String, required: true },
    userID: { type: mongoose.Schema.Types.ObjectId, ref: 'users', required: true },
    pax: { type: String, required: true },
    bookedDate: { type: String, required: true },


});

module.exports = mongoose.model('attractions', attractionScheme);