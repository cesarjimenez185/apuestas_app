const express = require('express');
const router = express.Router();
const betController = require('../controllers/betController');
const { auth } = require('../middleware/auth');

router.post('/', auth, betController.placeBet);
router.get('/', auth, betController.getUserBets);
router.get('/:id', auth, betController.getBetById);
router.put('/settle', auth, betController.settleBets);

module.exports = router;
