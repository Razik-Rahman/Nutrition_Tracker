const mongoose = require('mongoose');

const foodSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  category: { type: String, required: true },
  gram: { type: Number, required: true },
  protein: { type: Number, required: true },
  fibre: { type: Number, required: true },
  calories: { type: Number, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Food', foodSchema);
