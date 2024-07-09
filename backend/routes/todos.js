const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Todo = require('../models/Todo');

// Get all todos
router.get('/', auth, async (req, res) => {
  try {
    const todos = await Todo.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.json(todos);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Add new todo
router.post('/', auth, async (req, res) => {
  const { text } = req.body;

  try {
    const newTodo = new Todo({
      text,
      user: req.user.id
    });

    const todo = await newTodo.save();
    res.json(todo);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Update todo
router.put('/:id', auth, async (req, res) => {
  const { text, completed } = req.body;

  try {
    let todo = await Todo.findById(req.params.id);

    if (!todo) return res.status(404).json({ msg: 'Todo not found' });

    // Make sure user owns todo
    if (todo.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    todo = await Todo.findByIdAndUpdate(
      req.params.id,
      { text, completed },
      { new: true }
    );

    res.json(todo);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// Delete todo
router.delete('/:id', auth, async (req, res) => {
  try {
    let todo = await Todo.findById(req.params.id);

    if (!todo) return res.status(404).json({ msg: 'Todo not found' });

    // Make sure user owns todo
    if (todo.user.toString() !== req.user.id) {
      return res.status(401).json({ msg: 'Not authorized' });
    }

    await Todo.findByIdAndRemove(req.params.id);

    res.json({ msg: 'Todo removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

module.exports = router;