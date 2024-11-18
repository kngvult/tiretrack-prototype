const express = require('express'); 
const cors = require('cors');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

// Enable CORS
app.use(cors());

// Use body-parser middleware
app.use(bodyParser.json());

// PostgreSQL connection configuration
const pool = new Pool({
  user: 'postgres',  // substitua com seu usuário do banco de dados
  host: '192.168.100.153',    // substitua com seu host do banco de dados
  database: 'RecapPro',  // substitua com seu nome do banco de dados
  password: '123',  // substitua com sua senha do banco de dados
  port: 5432,
});

// Root route
app.get('/', (req, res) => {
  res.send('Bem-vindo ao TireTrack!');
});

// Route for /caminhoes
app.get('/caminhoes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM caminhoes ORDER BY id_caminhao ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Erro ao consultar o banco de dados:', err);
    res.status(500).send('Erro ao consultar o banco de dados');
  }
});
app.get('/caminhoes/:idCaminhao', async (req, res) => {
  const { idCaminhao } = req.params;
  try {
    const result = await pool.query('SELECT * FROM caminhoes WHERE id_caminhao = $1', [idCaminhao]);
    if (result.rows.length === 0) {
      return res.status(404).send('Caminhão não encontrado');
    }
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Erro ao consultar caminhão:', err);
    res.status(500).send('Erro ao consultar caminhão');
  }
});

// Route to add a truck
app.post('/caminhoes', async (req, res) => {
  const { emplacamento, modelo_caminhao, ano_fabricacao, km_total } = req.body;
  if (!emplacamento || !modelo_caminhao || !ano_fabricacao || !km_total) {
    return res.status(400).send('Todos os campos são obrigatórios.');
  }
  try {
    const result = await pool.query(
      'INSERT INTO caminhoes (emplacamento, modelo_caminhao, ano_fabricacao, km_total) VALUES ($1, $2, $3, $4) RETURNING id_caminhao',
      [emplacamento, modelo_caminhao, ano_fabricacao, km_total]
    );
    res.status(201).json({ id_caminhao: result.rows[0].id_caminhao });
  } catch (err) {
    console.error('Erro ao adicionar caminhão:', err);
    res.status(500).send(`Erro ao adicionar caminhão: ${err.message}`);
  }
});

// Route for /pneus
app.get('/pneus', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM pneus');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Erro ao consultar o banco de dados:', err);
    res.status(500).send('Erro ao consultar o banco de dados');
  }
});

// Adicionando rota específica para retornar pneus de um caminhão pelo seu ID
app.get('/pneus/:idCaminhao', async (req, res) => {
  const idCaminhao = req.params.idCaminhao;
  try {
    const result = await pool.query('SELECT * FROM pneus WHERE id_caminhao = $1', [idCaminhao]);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Erro ao consultar pneus do caminhão:', err);
    res.status(500).send('Erro ao consultar pneus do caminhão');
  }
});

// Route to add a tire
app.post('/pneus', async (req, res) => {
  const { pneu_id, id_caminhao, posicao, km_pneu } = req.body;
  if (!pneu_id || !id_caminhao || !posicao || !km_pneu) {
    return res.status(400).send('Todos os campos são obrigatórios.');
  }
  try {
    await pool.query(
      'INSERT INTO pneus (pneu_id, id_caminhao, posicao, km_pneu, data_ultima_manutencao, ult_calibragem, km_limite_manutencao) VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [pneu_id, id_caminhao, posicao, km_pneu, data_ultima_manutencao, ult_calibragem, km_limite_manutencao]
    );
    res.status(201).send('Pneu adicionado com sucesso');
  } catch (err) {
    console.error('Erro ao adicionar pneu:', err);
    res.status(500).send('Erro ao adicionar pneu');
  }
});

// Rota para atualizar um caminhão
app.put('/caminhoes/:id_caminhao', async (req, res) => {
  const { id_caminhao } = req.params;
  const { emplacamento, modelo_caminhao, ano_fabricacao, km_total } = req.body;
  if (!emplacamento || !modelo_caminhao || !ano_fabricacao || !km_total) {
    return res.status(400).send('Todos os campos são obrigatórios.');
  }
  try {
    const result = await pool.query(
      'UPDATE caminhoes SET emplacamento = $1, modelo_caminhao = $2, ano_fabricacao = $3, km_total = $4 WHERE id_caminhao = $5 RETURNING id_caminhao',
      [emplacamento, modelo_caminhao, ano_fabricacao, km_total, id_caminhao]
    );
    if (result.rowCount === 0) {
      return res.status(404).send('Caminhão não encontrado');
    }
    res.status(200).json({ id_caminhao: result.rows[0].id_caminhao });
  } catch (err) {
    console.error('Erro ao atualizar caminhão:', err);
    res.status(500).send('Erro ao atualizar caminhão');
  }
});

// Route to add a service order
app.post('/ordens_servico', async (req, res) => {
  const { id_caminhao, pneu_id, descricao, status } = req.body;
  if (!id_caminhao || !pneu_id || !descricao || !status) {
    return res.status(400).send('Todos os campos são obrigatórios.');
  }
  try {
    const result = await pool.query(
      'INSERT INTO ordens_servico (id_requisicao, id_caminhao, pneu_id, descricao, status, data_solicitacao) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
      [`REQ${Date.now()}`, id_caminhao, pneu_id, descricao, status]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Erro ao criar ordem de serviço:', err);
    res.status(500).send('Erro ao criar ordem de serviço');
  }
});

// Route to get pending service orders
app.get('/ordens_servico', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM ordens_servico WHERE status = $1 ORDER BY data_solicitacao DESC', ['Pendente']);
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Erro ao consultar ordens de serviço:', err);
    res.status(500).send('Erro ao consultar ordens de serviço');
  }
});

// Route to finalize a service order
app.put('/ordens_servico/:id', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  console.log(`Recebido pedido para finalizar ordem de serviço com ID: ${id}`);
  if (status !== 'Finalizado') {
    return res.status(400).send('Status inválido');
  }
  try {
    const result = await pool.query(
      'UPDATE ordens_servico SET status = $1 WHERE id_requisicao = $2 RETURNING *',
      [status, id]
    );
    if (result.rowCount === 0) {
      console.log('Ordem de serviço não encontrada para ID:', id);
      return res.status(404).send('Ordem de serviço não encontrada');
    }
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error('Erro ao finalizar ordem de serviço:', err);
    res.status(500).send('Erro ao finalizar ordem de serviço');
  }
});
// Route to get all finalized service orders
app.get('/ordens_servico/finalizado', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM ordens_servico WHERE status = $1',
      ['Finalizado']
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Error fetching finalized orders:', err);
    res.status(500).send('Error fetching finalized orders');
  }
});

// Route for /alertas
app.get('/alertas', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM alertas');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('Erro ao buscar alertas:', err);
    res.status(500).send('Erro ao buscar alertas');
  }
});

// Starting the server
app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
