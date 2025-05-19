const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('./generated/prisma');

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

// Buscar todas as tarefas (com filtros opcionais)
app.get('/tasks', async (req, res) => {
  const { status, orderBy } = req.query;

  const tasks = await prisma.task.findMany({
    where: status ? { status } : {},
    orderBy: {
      dueDate: orderBy === 'desc' ? 'desc' : 'asc',
    },
  });

  res.json(tasks);
});

// Buscar tarefa por ID
app.get('/tasks/:id', async (req, res) => {
  const { id } = req.params;
  const task = await prisma.task.findUnique({
    where: { id: Number(id) },
  });

  if (!task) return res.status(404).json({ error: 'Tarefa não encontrada' });
  res.json(task);
});

// Criar nova tarefa
app.post('/tasks', async (req, res) => {
  const { title, description, dueDate } = req.body;
  const task = await prisma.task.create({
    data: {
      title,
      description,
      dueDate: new Date(dueDate),
    },
  });
  res.status(201).json(task);
});

// Atualizar tarefa existente
app.put('/tasks/:id', async (req, res) => {
  const { id } = req.params;
  const { title, description, dueDate, status } = req.body;

  try {
    const updatedTask = await prisma.task.update({
      where: { id: Number(id) },
      data: { title, description, dueDate: new Date(dueDate), status },
    });
    res.json(updatedTask);
  } catch (error) {
    res.status(404).json({ error: 'Tarefa não encontrada' });
  }
});

// Excluir tarefa
app.delete('/tasks/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await prisma.task.delete({
      where: { id: Number(id) },
    });
    res.status(204).send();
  } catch (error) {
    res.status(404).json({ error: 'Tarefa não encontrada' });
  }
});

app.listen(3000, () => {
  console.log('API rodando em http://localhost:3000');
});