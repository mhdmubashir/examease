const axios = require('axios');
axios.get('http://localhost:5050/api/v1/users/all')
  .then(res => console.log(typeof res, Object.keys(res), typeof res.data, Object.keys(res.data)))
  .catch(err => console.log(typeof err.response.data, Object.keys(err.response.data)));
