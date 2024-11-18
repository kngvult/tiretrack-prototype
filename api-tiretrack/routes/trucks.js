const express = require('express');
const router = express.Router();

// Dados mockados (substitua por dados reais do banco)
let trucks = [
  { id: 'CAM001', emplacamento: 'ABC-1234', modeloCaminhao: 'Volvo FH', anoFabricacao: 2018, kmTotal: 120000 },
  { id: 'CAM002', emplacamento: 'DEF-5678', modeloCaminhao: 'Scania R', anoFabricacao: 2019, kmTotal: 90000 }
];

// GET /api/trucks - Lista todos os caminhões
router.get('/', (req, res) => {
  res.json(trucks);
});

// GET /api/trucks/:id - Retorna um caminhão específico
router.get('/:id', (req, res) => {
  const truck = trucks.find(t => t.id === req.params.id);
  if (truck) {
    res.json(truck);
  } else {
    res.status(404).send('Caminhão não encontrado');
  }
});

// POST /api/trucks - Adiciona um novo caminhão
router.post('/', (req, res) => {
  const newTruck = req.body;
  trucks.push(newTruck);
  res.status(201).json(newTruck);
});

// PUT /api/trucks/:id - Atualiza um caminhão existente
router.put('/:id', (req, res) => {
  const index = trucks.findIndex(t => t.id === req.params.id);
  if (index !== -1) {
    trucks[index] = req.body;
    res.json(trucks[index]);
  } else {
    res.status(404).send('Caminhão não encontrado');
  }
});

// DELETE /api/trucks/:id - Remove um caminhão
router.delete('/:id', (req, res) => {
  const index = trucks.findIndex(t => t.id === req.params.id);
  if (index !== -1) {
    const removedTruck = trucks.splice(index, 1);
    res.json(removedTruck);
  } else {
    res.status(404).send('Caminhão não encontrado');
  }
});

module.exports = router;
