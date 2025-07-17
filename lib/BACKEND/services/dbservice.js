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
const { ObjectId } = require('mongodb');
const api_key = "f8f1cc1c8emsh8ce076a6136ca13p116ff2jsn1f2f9b873075";
plan_key = "68764ee1c67a66cd9527972d";
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

    console.log("Starting request...");

    const request = https.request(options, (response) => {
      let data = '';

      response.on('data', chunk => {
        data += chunk;
      });

      response.on('end', () => {
        try {
          console.log(data);
          const parsed = JSON.parse(data);
          const attractionData = parsed.data;

          // Safe extraction of attraction addresses array
          const attractionAddresses = attractionData.addresses?.attraction;
          const firstAttraction = (Array.isArray(attractionAddresses) && attractionAddresses.length > 0) ? attractionAddresses[0] : {};

          const simplified = {
            slug: slug,
            title: attractionData.name ?? "",
            pricePerPax: (attractionData.representativePrice?.publicAmount?.toString()) ?? "",
            address: firstAttraction.address ?? "No Address Found",
            description: attractionData.description ?? "",
            latitude: firstAttraction.latitude ?? "No Latitude Found",
            longitude: firstAttraction.longitude ?? "No Longitude Found",
            totalPrice: (2 * (attractionData.representativePrice?.publicAmount ?? 0)).toString(),
            userID: "6866d8f6804aa5ebc8c8ea34",
            pax: "2",
            bookedDate: selectedDate ?? "",
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
          );

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
      const what = await user.create({
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
      return what._id;
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
      const chat = await aichat.create({
        userID: userID,
        aiMessage: aiMessage
      });
      return await chat.save();
    } catch (e) {
      throw new Error("Failed to add AI chat: " + e.message);
    }
  },
  async updateToken(id, token) {
    try {
      await user.findByIdAndUpdate(id, { token: token });
      return;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please try again later.")
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
  async getAiChat(userID) {
    try {
      let result = await aichat.find({ userID: userID });
      return result;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error retrieving login credentials");
    }
  },
  async getUserIDFromToken(token) {
    try {
      let result = await user.findOne({ token: token }).select("_id");
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
      plan_key = "";
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
          $push: { attractionId: new mongoose.Types(newAttractionId) }
        }
      );
      return;
    } catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please try again later.");
    }
  },
  async getUser(email, password) {
    try {
      let result = await user.findOne({ email: email, password: password });
      return result;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error retrieving login credentials");
    }
  },
  async updateToken(id, token) {
    try {
      await user.findByIdAndUpdate(id, { token: token });
      return;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error at the server. Please try again later.")
    }
  },
  async getUserByToken(token) {
    try {
      let result = await user.findOne({ token: token }).select();
      return result;
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error retrieving login credentials");
    }
  },
  async getUserAIToken(id) {
    try {
      let result = await user.findById(id).select(aiTokens - _id);
      return result
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error retrieving user data");
    }
  },
  async updateUserAIToken(conditions, updates) {
    try {
      let result = await user.findByIdAndUpdate(conditions, updates)
      if (!result) return "Unable to find User.";
      else return "Tokens have been added!";
    }
    catch (e) {
      console.log(e.message);
      throw new Error("Error adding Tokens");
    }
  },
  // services/dbservice.js (or wherever getHotelPhoto is defined)
  async getHotelPhoto(hotelID) {
    return new Promise((resolve, reject) => { // This promise handles the async data retrieval
      const path = `/api/v1/hotels/getHotelPhotos?hotel_id=${hotelID}`;
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
            const hotelImages = parsed.data?.map(item => item.url) || []; // Extract URLs directly
            resolve(hotelImages); // Resolve the promise with the data
          } catch (err) {
            console.error('Error parsing hotel photo data:', err);
            reject(err); // Reject the promise if there's an error
          }
        });
      });

      request.on('error', (e) => {
        console.error('Hotel Photo API request error:', e);
        reject(e); // Reject the promise on request error
      });
      request.end();
    });
  },
  async getAttractionReviews(id) {
    return new Promise((resolve, reject) => {
      const path = `/api/v1/attraction/getAttractionReviews?id=${id}&page=1`; // Use backticks for template literals
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

            const reviews = Array.isArray(parsed.data) ? parsed.data : [];

            const simplifiedReviews = reviews.map(review => ({
              id: review.id,
              // Fix 1: Use numericRating to match Flutter model
              numericRating: review.numericRating,
              content: review.content,
              language: review.language,
              travelPartnerTypes: review.travelPartnerTypes ?? [],
              // Fix 2: Directly map user properties from the original review object
              userName: review.user?.name || null,
              userAvatar: review.user?.avatar || null,
              userCountry: review.user?.cc1 || null,
              epochMs: review.epochMs
            }));
            console.log('Simplified Reviews:', JSON.stringify(simplifiedReviews, null, 2));

            resolve(simplifiedReviews);
          } catch (err) {
            console.error('Error parsing attraction review data:', err);
            reject(err);
          }
        });
      });

      request.on('error', (e) => {
        console.error('Attraction Review API request error:', e);
        reject(e);
      });

      request.end();
    });
  }
};

module.exports = db;
