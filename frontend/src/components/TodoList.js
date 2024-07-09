import React, { useState, useEffect } from 'react';
import { AppBar, Toolbar, Typography, Button, Container, TextField, List, ListItem, ListItemText, ListItemSecondaryAction, IconButton, Checkbox, Box, Snackbar } from '@mui/material';
import { Delete as DeleteIcon, Add as AddIcon, ExitToApp as LogoutIcon } from '@mui/icons-material';
import { motion, AnimatePresence } from 'framer-motion';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const TodoList = () => {
  const [todos, setTodos] = useState([]);
  const [newTodo, setNewTodo] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchTodos();
    // Set up periodic token check
    const tokenCheckInterval = setInterval(checkTokenValidity, 60000); // Check every minute
    return () => clearInterval(tokenCheckInterval);
  }, []);

  const fetchTodos = async () => {
    try {
      const res = await axios.get('http://localhost:5000/api/todos', {
        headers: { 'x-auth-token': localStorage.getItem('token') }
      });
      setTodos(res.data);
    } catch (error) {
      console.error('Failed to fetch todos:', error);
      if (error.response && error.response.status === 401) {
        handleLogout();
      } else {
        setError('Failed to fetch todos. Please try again.');
      }
    }
  };

  const addTodo = async () => {
    if (!newTodo.trim()) return;
    try {
      const res = await axios.post('http://localhost:5000/api/todos', { text: newTodo }, {
        headers: { 'x-auth-token': localStorage.getItem('token') }
      });
      setTodos([...todos, res.data]);
      setNewTodo('');
    } catch (error) {
      console.error('Failed to add todo:', error);
      setError('Failed to add todo. Please try again.');
    }
  };

  const toggleTodo = async (id) => {
    try {
      const todo = todos.find(t => t._id === id);
      const res = await axios.put(`http://localhost:5000/api/todos/${id}`, 
        { completed: !todo.completed },
        { headers: { 'x-auth-token': localStorage.getItem('token') } }
      );
      setTodos(todos.map(t => t._id === id ? res.data : t));
    } catch (error) {
      console.error('Failed to toggle todo:', error);
      setError('Failed to update todo. Please try again.');
    }
  };

  const deleteTodo = async (id) => {
    try {
      await axios.delete(`http://localhost:5000/api/todos/${id}`, {
        headers: { 'x-auth-token': localStorage.getItem('token') }
      });
      setTodos(todos.filter(t => t._id !== id));
    } catch (error) {
      console.error('Failed to delete todo:', error);
      setError('Failed to delete todo. Please try again.');
    }
  };

  const handleLogout = async () => {
    try {
      await axios.post('http://localhost:5000/api/auth/logout', null, {
        headers: { 'x-auth-token': localStorage.getItem('token') }
      });
    } catch (error) {
      console.error('Logout failed:', error);
    } finally {
      localStorage.removeItem('token');
      navigate('/login');
    }
  };

  const checkTokenValidity = async () => {
    try {
      await axios.get('http://localhost:5000/api/auth/checkToken', {
        headers: { 'x-auth-token': localStorage.getItem('token') }
      });
    } catch (error) {
      console.error('Token invalid:', error);
      handleLogout();
    }
  };

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Todo App
          </Typography>
          <Button color="inherit" onClick={handleLogout} startIcon={<LogoutIcon />}>
            Logout
          </Button>
        </Toolbar>
      </AppBar>
      <Container maxWidth="sm">
        <Box sx={{ my: 4 }}>
          <Typography variant="h4" component="h1" gutterBottom>
            Todo List
          </Typography>
          <Box sx={{ display: 'flex', mb: 2 }}>
            <TextField
              fullWidth
              variant="outlined"
              value={newTodo}
              onChange={(e) => setNewTodo(e.target.value)}
              placeholder="Add a new todo"
              onKeyPress={(e) => e.key === 'Enter' && addTodo()}
            />
            <Button
              variant="contained"
              color="primary"
              onClick={addTodo}
              sx={{ ml: 1 }}
            >
              <AddIcon />
            </Button>
          </Box>
          <List>
            <AnimatePresence>
              {todos.map((todo) => (
                <motion.div
                  key={todo._id}
                  initial={{ opacity: 0, y: 50 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -50 }}
                  transition={{ duration: 0.3 }}
                >
                  <ListItem>
                    <Checkbox
                      edge="start"
                      checked={todo.completed}
                      onChange={() => toggleTodo(todo._id)}
                    />
                    <ListItemText
                      primary={todo.text}
                      sx={{ textDecoration: todo.completed ? 'line-through' : 'none' }}
                    />
                    <ListItemSecondaryAction>
                      <IconButton edge="end" onClick={() => deleteTodo(todo._id)}>
                        <DeleteIcon />
                      </IconButton>
                    </ListItemSecondaryAction>
                  </ListItem>
                </motion.div>
              ))}
            </AnimatePresence>
          </List>
        </Box>
      </Container>
      <Snackbar
        open={!!error}
        autoHideDuration={6000}
        onClose={() => setError('')}
        message={error}
      />
    </>
  );
};

export default TodoList;