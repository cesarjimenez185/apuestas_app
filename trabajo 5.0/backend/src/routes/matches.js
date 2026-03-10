const express = require('express');
const router = express.Router();
const matchController = require('../controllers/matchController');
const { auth } = require('../middleware/auth');

router.get('/', matchController.getAllMatches);
router.get('/live', matchController.getLiveMatches);
router.get('/:id', matchController.getMatchById);
router.post('/', auth, matchController.createMatch);
router.put('/:id', auth, matchController.updateMatch);
router.put('/:id/live', auth, matchController.updateLiveScore);
router.post('/seed', matchController.seedMatches);

module.exports = router;
