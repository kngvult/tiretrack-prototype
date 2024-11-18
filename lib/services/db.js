// services/db.js
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'http://192.168.100.153',
  database: 'RecapPro',
  password: '123',
  port: 5432, // porta padrão do PostgreSQL
});

module.exports = {
  query: (text, params) => pool.query(text, params),
};
