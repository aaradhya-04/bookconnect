const express = require('express');
const router = express.Router();
const reviewModel = require('../models-mongo/reviewModel');
const { client: redisClient } = require('../utils/redisClient');
const bookModel = require('../models-mongo/bookModel');
const asyncHandler = require('../utils/asyncHandler');

// GET /api/reviews - cached (all users)
router.get('/reviews', async (req, res, next) => {
  try {
    const cacheKey = 'api:reviews:all';
    if (redisClient.isOpen) {
      const cached = await redisClient.get(cacheKey);
      if (cached) {
        return res.json(JSON.parse(cached));
      }
    }

    const reviews = await reviewModel.getAllWithUserAndBook();

    if (redisClient.isOpen) {
      try { await redisClient.setEx(cacheKey, 300, JSON.stringify(reviews)); } catch (e) { console.error('Redis set error', e); }
    }

    res.json(reviews);
  } catch (err) { next(err); }
});

// GET /api/books - cached (all books)
router.get('/books', asyncHandler(async (req, res) => {
  const cacheKey = 'api:books:all';
  if (redisClient.isOpen) {
    const cached = await redisClient.get(cacheKey);
    if (cached) return res.json(JSON.parse(cached));
  }
  const books = await bookModel.getAll();
  if (redisClient.isOpen) {
    await redisClient.setEx(cacheKey, 300, JSON.stringify(books));
  }
  res.json(books);
}));

module.exports = router;
