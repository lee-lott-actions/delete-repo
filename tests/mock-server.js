const express = require('express');
const app = express();
app.use(express.json());

app.delete('/repos/:owner/:repo', (req, res) => {
  console.log(`Mock intercepted: DELETE /repos/${req.params.owner}/${req.params.repo}`);
  console.log('Request headers:', JSON.stringify(req.headers));

  // Simulate repository existence check
  if (req.params.owner === 'invalid-owner' || req.params.repo === 'invalid-repo') {
    return res.status(404).json({ message: 'Repository not found' });
  }

  // Simulate successful deletion
  res.status(204).send();
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
