const mongoose = require('mongoose');
const https = require('https');
const aichat = require("../models/AIchat.js");
const arrivesg = require("../models/arriveSG.js");
const attraction = require("../models/attraction.js");
const departsg = require("../models/departSG.js");
const hotel = require("../models/hotel.js");
const support = require("../models/support.js");
const user = require("../models/user.js");
const plan = require("../models/plan.js");

const api_key = "c5efe436famsh7d51410c6ef5da8p17b5f9jsn8e3dc7178b24";
plan_key = "";
let db = {
  async connect() {
    try {
      await mongoose.connect('mongodb://127.0.0.1:27017/Singaplorer');
      return "Connected to Mongo DB";
    } catch (e) {
      console.log(e.message);
      throw new Error("Error connecting to Mongo DB");
    }
  },
  async checkoutAttraction(slug, selectedDate) {
    const encodedSlug = encodeURIComponent(slug);

    const path = `/api/v1/attraction/getAttractionDetails?slug=${encodedSlug}&languagecode=en-us&currency_code=SGD`;

    const options = {
      method: 'GET',
      hostname: 'booking-com15.p.rapidapi.com',
      port: null,

      path,
      headers: {
        'x-rapidapi-key': api_key,
        'x-rapidapi-host': 'booking-com15.p.rapidapi.com'
      }
    };
    console.log("fuck me")
    const request = https.request(options, (response) => {
      let data = '';

      response.on('data', chunk => {
        data += chunk;
      });

      response.on('end', () => {
        try {
          console.log(data)
          const parsed = JSON.parse(data);
          const attractionData = parsed.data;

          const simplified =
          {
            slug: slug,
            title: attractionData.name,
            pricePerPax: attractionData.representativePrice.publicAmount.toString(),
            address: attractionData.addresses.attraction[0].address,
            description: attractionData.description,
            latitude: attractionData.addresses.attraction[0].latitude,
            longitude: attractionData.addresses.attraction[0].longitude,
            totalPrice: (2 * attractionData.representativePrice.publicAmount).toString(),
            userID: "6866d8f6804aa5ebc8c8ea34",
            pax: "2",
            bookedDate: selectedDate,
          };
          console.log({ data: simplified });
          this.addAttraction(
            simplified.slug,
            simplified.title,
            simplified.pricePerPax,
            simplified.address,
            simplified.description,
            simplified.latitude,
            simplified.longitude,
            simplified.totalPrice,
            simplified.userID,
            simplified.pax,
            simplified.bookedDate,
          )

        } catch (err) {
          console.error('Error parsing hotel data:', err);
        }
      });
    });

    request.on('error', (e) => {
      console.error('Hotel API request error:', e);
    });

    request.end();
  },
  async checkoutHotel(hotel_id, arrival_date, departure_date) {
    const queryParams = new URLSearchParams({
      hotel_id,
      arrival_date,
      departure_date,
      adults: '1',
      children_age: '1,17',
      room_qty: '1',
      units: 'metric',
      temperature_unit: 'c',
      languagecode: 'en-us',
      currency_code: 'SGD'
    });

    const path = `/api/v1/hotels/getHotelDetails?${queryParams.toString()}`;


    const options = {
      method: 'GET',
      hostname: 'booking-com15.p.rapidapi.com',
      path,
      headers: {
        'x-rapidapi-key': api_key,
        'x-rapidapi-host': 'booking-com15.p.rapidapi.com'
      }
    };

    const request = https.request(options, (response) => {
      let data = '';

      response.on('data', chunk => {
        data += chunk;
      });

      response.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          const hotelData = parsed.data || {};

          const simplified = {
            hotelID: hotelData.hotel_id,
            name: hotelData.hotel_name,
            address: hotelData.address,
            latitude: hotelData.latitude,
            longitude: hotelData.longitude,
            totalPrice: hotelData.product_price_breakdown.gross_amount.value,
            arrivalDate: hotelData.arrival_date,
            departureDate: hotelData.departure_date,
            city: hotelData.city,
            reviewCount: hotelData.rawData.reviewCount,
            reviewScore: hotelData.rawData.reviewScore,
          };
          console.log({ data: simplified });
          this.addHotel(
            simplified.hotelID,
            simplified.name,
            simplified.address,
            simplified.latitude,
            simplified.longitude,
            simplified.totalPrice,
            "6866d8f6804aa5ebc8c8ea34",
            1,
            simplified.arrivalDate,
            simplified.departureDate,
            simplified.city,
            simplified.reviewCount,
            simplified.reviewScore
          )

        } catch (err) {
          console.error('Error parsing hotel data:', err);
        }
      });
    });

    request.on('error', (e) => {
      console.error('Hotel API request error:', e);
    });

    request.end();
  },
  async checkoutFlight(token) {
    const queryParams = new URLSearchParams({
      hotel_id,
      arrival_date,
      departure_date,
      adults: '1',
      children_age: '1,17',
      room_qty: '1',
      units: 'metric',
      temperature_unit: 'c',
      languagecode: 'en-us',
      currency_code: 'SGD'
    });

    const path = `/api/v1/hotels/getHotelDetails?${queryParams.toString()}`;


    const options = {
      method: 'GET',
      hostname: 'booking-com15.p.rapidapi.com',
      path,
      headers: {
        'x-rapidapi-key': api_key,
        'x-rapidapi-host': 'booking-com15.p.rapidapi.com'
      }
    };

    const request = https.request(options, (response) => {
      let data = '';

      response.on('data', chunk => {
        data += chunk;
      });

      response.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          const hotelData = parsed.data || {};

          const simplified = {
            hotelID: hotelData.hotel_id,
            name: hotelData.hotel_name,
            address: hotelData.address,
            latitude: hotelData.latitude,
            longitude: hotelData.longitude,
            totalPrice: hotelData.product_price_breakdown.gross_amount.value,
            arrivalDate: hotelData.arrival_date,
            departureDate: hotelData.departure_date,
            city: hotelData.city,
            reviewCount: hotelData.rawData.reviewCount,
            reviewScore: hotelData.rawData.reviewScore,
          };
          console.log({ data: simplified });
          this.addHotel(
            simplified.hotelID,
            simplified.name,
            simplified.address,
            simplified.latitude,
            simplified.longitude,
            simplified.totalPrice,
            "6866d8f6804aa5ebc8c8ea34",
            1,
            simplified.arrivalDate,
            simplified.departureDate,
            simplified.city,
            simplified.reviewCount,
            simplified.reviewScore
          )

        } catch (err) {
          console.error('Error parsing hotel data:', err);
        }
      });
    });

    request.on('error', (e) => {
      console.error('Hotel API request error:', e);
    });

    request.end();
  },
  async addAttraction(slug, title, pricePerPax, address,
    description, latitude, longitude, totalPrice, userID, pax, bookedDate) {
    try {
      console.log("Attempt to add in...")
      console.log(longitude)
      const createdAttraction = await attraction.create({
        slug,
        title,
        pricePerPax,
        address,
        description,
        latitude,
        longitude,
        totalPrice,
        userID,
        pax,
        bookedDate
      });
      await this.updatePlanAttractions(plan_key, createdAttraction._id)
      return `Attraction: ${title} has been added into attraction collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`Attraction: ${title} was not added.`);
    }
  },
  async addAccount(username, phoneNumber, password, email, timeZone, nationality, language, preferences, aiTokens) {
    try {
      await user.create({
        username,
        phoneNumber,
        password,
        email,
        timeZone,
        nationality,
        language,
        preferences,
        aiTokens,
      });
      return `Account: ${username} has been added into account collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`Account: ${username} was not added.`);
    }
  },
  async addSupport(userID, firstName, lastName, country, comment, date) {
    try {
      await support.create({
        userID,
        firstName,
        lastName,
        country,
        comment,
        date,
      });
      return `Support: ${userID} has been added into support collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`Support: ${userID} was not added.`);
    }
  },
  async addHotel(hotelID, title, address, latitude, longitude,
    totalPrice, userID, pax, arrivalDate, departureDate,
    city,
    reviewCount,
    reviewScore
  ) {
    try {
      const createdHotel = await hotel.create({
        hotelID,
        title,
        address,
        latitude,
        longitude,
        totalPrice,
        userID,
        pax,
        arrivalDate,
        departureDate,
        city,
        reviewCount,
        reviewScore
      });
      console.log(plan_key)
      console.log(createdHotel._id)
      await this.updatePlanHotel(plan_key, createdHotel._id)
      return `Hotel: ${title} has been added into hotel collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`Hotel: ${title} was not added.`);
    }
  },
  async addDepart(
    slug,
    toCountry,
    toCityName,
    departureTime,
    arrivalTime,
    pricePerPax,
    totalPrice,
    pax,
    cabinClass,
    userID
  ) {
    try {
      const createdDeparture = await departsg.create({
        slug,
        toCountry,
        toCityName,
        departureTime,
        arrivalTime,
        pricePerPax,
        totalPrice,
        pax,
        cabinClass,
        userID,
      });
      await this.setUpPlan(userID, createdDeparture._id);
      return `Depart: ${slug} has been added into depart collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`Depart: ${slug} was not added.`);
    }
  },
  async addArrive(token, fromCountry, fromAirport, departureTime, arrivalTime, pricePerPax, totalPrice, pax, cabinClass, userID) {
    try {
      const createdArrival = await arrivesg.create({
        token,
        fromCountry,
        fromAirport,
        departureTime,
        arrivalTime,
        pricePerPax,
        totalPrice,
        pax,
        cabinClass,
        userID,
      });
      await this.updatePlanArrival(plan_key, createdArrival._id)
      return `Arrive: ${token} has been added into arrive collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`Arrive: ${token} was not added.`);
    }
  },
  async addAIChat(userID, aiMessage) {
    try {
      await aichat.create({
        userID,
        aiMessage,
      });
      return `AI CHAT: ${userID} has been added into ai chat collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`AI CHAT: ${userID} was not added.`);
    }
  },
  async updateToken(id, token) {
    try {
      await user.findByIdAndUpdate(id, { token: token });
      return;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please tr yagain later.")
    }
  },
  async removeToken(id) {
    try {
      await user.findByIdAndUpdate(id, { $unset: { token: 1 } });
      return;
    } catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please try again later.")
    }
  },
  async getAccount(username, password) {
    try {
      let result = await user.findOne({ username: username, password: password });
      return result;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error retrieving login credentials");
    }
  },
  async setUpPlan(userId, departKey) {
    try {
      const planData = await plan.create({
        userId: new mongoose.Types.ObjectId(userId),
        departSGId: new mongoose.Types.ObjectId(departKey),
        arriveSGId: null,
        hotelId: null,
        attractionId: []
      });
      plan_key = planData._id;
      console.log(plan_key);
      return `AI CHAT: ${userId} has been added into ai chat collection`;
    } catch (e) {
      console.log(e.message);
      throw new Error(`AI CHAT: ${userId} was not added.`);
    }
  },
  async updatePlanHotel(id, hotelId) {
    try {
      await plan.findByIdAndUpdate(id, { hotelId: hotelId });
      return;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please tr yagain later.")
    }
  },
  async updatePlanArrival(id, arriveSGId) {
    try {
      await plan.findByIdAndUpdate(id, { arriveSGId: arriveSGId });
      return;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please tr yagain later.")
    }
  },
  async updatePlanAttractions(id, newAttractionId) {
    try {
      await plan.findByIdAndUpdate(
        id,
        {
          $push: { attractionId: mongoose.Types.ObjectId(newAttractionId) }
        }
      );
      return;
    } catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please try again later.");
    }
  }

};

module.exports = db;
