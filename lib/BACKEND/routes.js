const express = require('express');
const cors = require('cors');
const Stripe = require('stripe');
const https = require('https');
const db = require("./services/dbservice.js");
const crypto = require('crypto');
const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json()); 

const port = 3000;
api_key = "61dfbf32b1msh394b80f9035fef3p11ca2ajsnc624eaa3533d";
db.connect()
.then(function(response){
    console.log(response);
})
.catch(function(error){
    console.log(error.message);
});
app.listen(port, () => {
  console.log(`🚀 Server is running at http://localhost:${port}`);
});
app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.get('/api/flights', (req, res) => {
  const { from, to, depart, cabinClass,sort,return: returnDate } = req.query;

  const options = {
    method: 'GET',
    hostname: 'booking-com15.p.rapidapi.com',
    path: `/api/v1/flights/searchFlights?fromId=${from}&toId=${to}&departDate=${depart}&stops=none&pageNo=1&adults=1&sort=${sort}&cabinClass=${cabinClass}&currency_code=SGD`,
    headers: {
      'x-rapidapi-key': api_key,
      'x-rapidapi-host': 'booking-com15.p.rapidapi.com',
    },
  };

  const request = https.request(options, function (response) {
    let data = '';

    response.on('data', chunk => {
      data += chunk;
    });

    response.on('end', () => {
      try {
        const parsed = JSON.parse(data);
        const offers = parsed.data?.flightOffers || [];

        const simplified = offers
          .map(offer => {
            const segment = offer.segments?.[0];
            if (!segment) return null;

            const allLegs = segment.legs || [];

            const from = segment.departureAirport?.name || 'Unknown';
            const to = segment.arrivalAirport?.name || 'Unknown';
            const departTime = segment.departureTime || '';
            const arriveTime = segment.arrivalTime || '';
            const token = offer.token || '';

            const airline =
              allLegs[0]?.carriersData?.[0]?.name ||
              allLegs[0]?.carrierInfo?.marketingCarrier ||
              'Unknown';

            const price = offer.travellerPrices?.[0]?.travellerPriceBreakdown?.total.units;

            return {
              airline,
              from,
              to,
              departTime,
              arriveTime,
              price,
              token
            };
          })
          .filter(flight => flight !== null);

        console.log({ data: simplified });
        res.json({ data: simplified });
      } catch (err) {
        console.error('Failed to parse or fetch flight data', err);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  });

  request.on('error', e => {
    console.error(e);
    res.status(500).json({ error: 'Request failed' });
  });

  request.end();
});
app.get('/api/flights/detail', (req, res) => {
  const { token } = req.query;

  const options = {
    method: 'GET',
    hostname: 'booking-com15.p.rapidapi.com',
    path: `/api/v1/flights/getFlightDetails?token=${token}&currency_code=SGD`,
    headers: {
      'x-rapidapi-key': api_key,
      'x-rapidapi-host': 'booking-com15.p.rapidapi.com',
    },
  };

  const request = https.request(options, function (response) {
    let data = '';

    response.on('data', chunk => {
      data += chunk;
    });

    response.on('end', () => {
      try {
        const parsed = JSON.parse(data);
        const offer = parsed.data || {};

        const simplified = 
        {
          token : offer.token,
          departureAirport: offer.segments[0].departureAirport.name,
          arrivalAirport :offer.segments[0].arrivalAirport.name,
          departureCountry : offer.segments[0].departureAirport.countryName,
          arrivalCountry : offer.segments[0].arrivalAirport.countryName,
          departureTime : offer.segments[0].departureTime,
          arrivalTime : offer.segments[0].arrivalTime,
          price : offer.priceBreakdown.totalWithoutDiscountRounded.units,
          cabinClass : offer.segments[0].legs[0].cabinClass,


        }

        console.log({ data: simplified });
        res.json({ data: simplified });
      } catch (err) {
        console.error('Failed to parse or fetch flight data', err);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  });

  request.on('error', e => {
    console.error(e);
    res.status(500).json({ error: 'Request failed' });
  });

  request.end();
});
app.post('/api/arrive/flights/checkout', (req, res) => {
    console.log("Testing")
    const { 
      token,
      fromCountry, 
      fromAirport, 
      departureTime, 
      arrivalTime, 
      pricePerPax, 
      cabinClass, 
    } = req.body;
    db.addArrive(
      token,
      fromCountry,
      fromAirport,
      departureTime,
      arrivalTime,
      pricePerPax,
      (pricePerPax * 2).toString(),
      "2",
      cabinClass,
      "6866d8f6804aa5ebc8c8ea34"

    )
        .then(function(response){
        res.status(200).json(response);
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
});
app.post('/api/departure/flights/checkout', (req, res) => {
    console.log("Testing")
    const { 
      token,
      fromCountry, 
      fromAirport, 
      departureTime, 
      arrivalTime, 
      pricePerPax, 
      cabinClass, 
    } = req.body;
    db.addDepart(
      token,
      fromCountry,
      fromAirport,
      departureTime,
      arrivalTime,
      pricePerPax,
      (pricePerPax * 2).toString(),
      "2",
      cabinClass,
      "6866d8f6804aa5ebc8c8ea34"

    )
        .then(function(response){
        res.status(200).json(response);
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
});
app.get('/api/hotels', (req, res) => {
  console.log("dwdw")
  const {
    arrival_date,
    departure_date,
    minPrice,
    maxPrice
  } = req.query;

  const params = new URLSearchParams({
    dest_id: '25054',
    search_type: 'hotel',
    arrival_date,
    departure_date,
    room_qty: '1',
    page_number: '1',
    price_min: minPrice,
    price_max: maxPrice,
    units: 'metric',
    temperature_unit: 'c',
    languagecode: 'en-us',
    currency_code: 'SGD'
  });

  const path = `/api/v1/hotels/searchHotels?${params.toString()}`;

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
        const hotels = parsed.data?.hotels || [];

        const simplified = hotels.map(hotel => ({
          name: hotel.property.name,
          hotelID: hotel.hotel_id,
          starRating: hotel.property.propertyClass || 0,
          reviewScore: hotel.property.reviewScore || 0,
          reviewText: hotel.property.reviewScoreWord || '',
          reviewCount: hotel.property.reviewCount || 0,
          priceGross: hotel.property?.priceBreakdown?.grossPrice?.value || 0,
          priceCurrency: hotel.property?.priceBreakdown?.grossPrice?.currency || 'SGD',
          checkInDate: hotel.property.checkinDate,
          checkInFrom: hotel.property.checkin?.fromTime || '',
          checkInUntil: hotel.property.checkin?.untilTime || '',
          checkOutDate: hotel.property.checkoutDate,
          checkOutFrom: hotel.property.checkout?.fromTime || '',
          checkOutUntil: hotel.property.checkout?.untilTime || '',
          imageUrls: hotel.property.photoUrls || [],
          accessibilityLabel: hotel.accessibilityLabel || '',
          hotelID:hotel.hotel_id || ""
        }));

        res.json({
          status: true,
          message: 'Success',
          timestamp: Date.now(),
          data: simplified
        });

      } catch (err) {
        console.error('Error parsing hotel data:', err);
        res.status(500).json({ status: false, message: 'Internal server error' });
      }
    });
  });

  request.on('error', (e) => {
    console.error('Hotel API request error:', e);
    res.status(500).json({ status: false, message: 'Request failed' });
  });

  request.end();
});
app.get('/api/hotels/detail', (req, res) => {
  const {
    hotel_id,
    arrival_date,
    departure_date,
  } = req.query;
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

        const simplified =  {
            hotelID: hotelData.hotel_id,
            name: hotelData.hotel_name,
            arrivalDate: hotelData.arrival_date,
            departureDate: hotelData.departure_date,
            latitude: hotelData.latitude,
            longitude: hotelData.longitude,
            address: hotelData.address,
            city: hotelData.city,
            totalPrice: hotelData.product_price_breakdown.gross_amount.value,
            reviewCount: hotelData.rawData.reviewCount,
            reviewScore: hotelData.rawData.reviewScore,

          };
        console.log({ data: simplified });
        res.json({ data: simplified });

      } catch (err) {
        console.error('Error parsing hotel data:', err);
      }
    });
  });

  request.on('error', (e) => {
    console.error('Hotel API request error:', e);
  });

  request.end();
});
app.post('/api/hotels/checkout', (req, res) => {
    console.log("Testing")
    const { hotel_id, arrival_date, departure_date} = req.body;
    db.checkoutHotel(hotel_id,arrival_date,departure_date)
        .then(function(response){
        res.status(200).json(response);
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
});
app.post('/api/attraction/checkout', (req, res) => {
    console.log("Testing")
    const { slug, date } = req.body;
    db.checkoutAttraction(slug,date)
        .then(function(response){
        res.status(200).json(response);
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
});
app.get('/api/attraction', (req, res) => {

  const options = {
    method: 'GET',
    hostname: 'booking-com15.p.rapidapi.com',
    port: null,
    path: '/api/v1/attraction/searchAttractions?id=eyJwaW5uZWRQcm9kdWN0IjoiUFJuNjNoTmJYYVhlIiwidWZpIjotNzM2MzV9&sortBy=trending&page=1&currency_code=SGD&languagecode=en-us',
    headers: {
      'x-rapidapi-key': api_key,
      'x-rapidapi-host': 'booking-com15.p.rapidapi.com'
    }
  };

  const request = https.request(options, function (response) {
    let data = '';

    response.on('data', chunk => {
      data += chunk;
    });

    response.on('end', () => {
      try {
        const parsed = JSON.parse(data);
        const products = parsed.data?.products || [];

        const simplified = products
          .map(product => {
            if (!product) return null;

            const name = product.name || "";
            const slug = product.slug || "";
            const shortDescription = product.shortDescription || '';
            const price = product.representativePrice?.chargeAmount || 0;


            return {
              name,
              slug,
              shortDescription,
              price,
            };
          })
          .filter(product => product !== null);
                console.log("\n\n\n\n\n=====================================");

        console.log({ data: simplified });
                console.log("\n\n\n\n\n=====================================");

        res.json({ data: simplified });
      } catch (err) {
        console.error('Failed to parse or fetch flight data', err);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  });

  request.on('error', e => {
    console.error(e);
    res.status(500).json({ error: 'Request failed' });
  });

  request.end();
});
app.get('/api/attraction/detail', (req, res) => {
  const { slug } = req.query;
  const options = {
    method: 'GET',
    hostname: 'booking-com15.p.rapidapi.com',
    port: null,
    path: `/api/v1/attraction/getAttractionDetails?slug=${slug}&currency_code=SGD`,    
    headers: {
      'x-rapidapi-key': api_key,
      'x-rapidapi-host': 'booking-com15.p.rapidapi.com'
    }
  };

  const request = https.request(options, function (response) {
    let data = '';

    response.on('data', chunk => {
      data += chunk;
    });

    response.on('end', () => {
      try {
       const parsed = JSON.parse(data);
        const d = parsed.data;

  if (!d) {
    return res.status(400).json({ error: 'No data found' });
  }

const simplified = {
  description: d.description || "",
  name: d.name || "",
  reviewTotal: d.reviews?.total || 0,
  address: d.addresses?.attraction?.[0]?.address || "",
  city: d.addresses?.attraction?.[0]?.city || "",
  country: d.addresses?.attraction?.[0]?.country || "",
  reviewStats: d.reviewsState?.combinedNumericStats?.average || 0,
  price: d.representativePrice?.chargeAmount || 0,
    reviews: d.reviews?.reviews?.map(r => ({
    id: r.id,
    numericRating: r.numericRating,
    content: r.content,
    userName: r.user?.name || "Unknown"
  })) || []
};

console.log({ data: simplified })
res.json({ data: simplified });

      } catch (err) {
        console.error('Failed to parse or fetch flight data', err);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  });

  request.on('error', e => {
    console.error(e);
    res.status(500).json({ error: 'Request failed' });
  });

  request.end();
});
app.get('/api/attraction/detail/avalibility', (req, res) => {
  const { slug,date } = req.query;
  console.log(slug);
  console.log(date);
  const options = {
    method: 'GET',
    hostname: 'booking-com15.p.rapidapi.com',
    port: null,
    path: `/api/v1/attraction/getAvailability?slug=${slug}&date=${date}&currency_code=SGD&languagecode=en-us`,
    headers: {
      'x-rapidapi-key': api_key,
      'x-rapidapi-host': 'booking-com15.p.rapidapi.com'
    }
  };

  const request = https.request(options, function (response) {
    let data = '';

    response.on('data', chunk => {
      data += chunk;
    });

    response.on('end', () => {
      try {
        const parsed = JSON.parse(data);
        const datas = parsed.data || [];

        const simplified = datas
          .map(data => {
            if (!data) return null;

            const start = data.start || "";

            return {
              start
            };
          })
          .filter(data => data !== null);
                console.log("\n\n\n\n\n=====================================");

        console.log({ data: simplified });
                console.log("\n\n\n\n\n=====================================");

        res.json({ data: simplified });
      } catch (err) {
        console.error('Failed to parse or fetch flight data', err);
        res.status(500).json({ error: 'Internal server error' });
      }
    });
  });

  request.on('error', e => {
    console.error(e);
    res.status(500).json({ error: 'Request failed' });
  });

  request.end();
});
app.post('/api/add/users',function(req,res) {
    let data = req.body;
    db.addAccount(
      data.username,
      data.phoneNumber,
      data.password,
      data.email,
      data.timeZone,
      data.nationality,
      data.language,
      data.preferences,
      data.aiTokens,
    )
    .then(function(response){
        res.status(200).json({"message":response});
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
})
app.post('/api/add/support',function(req,res) {
    let data = req.body;
    db.addSupport(
      data.userID,
      data.firstName,
      data.lastName,
      data.country,
      data.comment,
      data.date,
    )
    .then(function(response){
        res.status(200).json({"message":response});
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
})
app.post('/api/add/hotel',function(req,res) {
    let data = req.body;
    db.addHotel(
      data.slug,
      data.title,
      data.pricePerPax,
      data.address,
      data.description,
      data.latitude,
      data.longtitude,
      data.totalPrice,
      data.userID,
      data.pax,
      data.arrivalDate,
      data.departureDate,

    )
    .then(function(response){
        res.status(200).json({"message":response});
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
})
app.post('/api/add/depart',function(req,res) {
    let data = req.body;
    db.addDepart(
      data.slug,
      data.toCountry,
      data.toCityName,
      data.departureTime,
      data.arrivalTime,
      data.pricePerPax,
      data.totalPrice,
      data.pax,
      data.cabinClass,
      data.userID,

    )
    .then(function(response){
        res.status(200).json({"message":response});
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
})
app.post('/api/add/arrive',function(req,res) {
    let data = req.body;
    db.addArrive(
      data.slug,
      data.fromCountry,
      data.fromCityName,
      data.departureTime,
      data.arrivalTime,
      data.pricePerPax,
      data.totalPrice,
      data.pax,
      data.cabinClass,
      data.userID,

    )
    .then(function(response){
        res.status(200).json({"message":response});
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
})
app.post('/api/add/aichat',function(req,res) {
    let data = req.body;
    db.addAIChat(
      data.userID,
      data.aiMessage,
    )
    .then(function(response){
        res.status(200).json({"message":response});
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
})
app.post('/api/add/attraction',function(req,res) {
    let data = req.body;
    db.addAttraction(
      data.slug,
      data.title,
      data.pricePerPax,
      data.address,
      data.description,
      data.latitude,
      data.longtitude,
      data.totalPrice,
      data.userID,
      data.pax,
      data.bookedDate,

    )
    .then(function(response){
        res.status(200).json({"message":response});
    })
    .catch(function(error){
        res.status(500).json({"message":error.message});
    });
})

app.post('/create-payment-intent', async (req, res) => {
  const { priceId } = req.body;
  
  try {
    // Get price details from Stripe
    const price = await stripe.prices.retrieve(priceId);

    // Create payment intent using the amount from the price object
    const paymentIntent = await stripe.paymentIntents.create({
      amount: price.unit_amount,
      currency: price.currency,
      automatic_payment_methods: { enabled: true },
    });

    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = app;