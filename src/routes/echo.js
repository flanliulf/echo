const express = require('express');
const router = express.Router();
const echoController = require('../controllers/echoController');

/**
 * @route   GET /echo
 * @desc    Echo接口，返回hello
 * @access  Public
 */
router.get('/echo', echoController.getEcho);

module.exports = router;
