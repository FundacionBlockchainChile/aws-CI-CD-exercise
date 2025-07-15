const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('¡Hola! Esta es una prueba del pipeline CI/CD en AWS. La aplicación se ha desplegado correctamente. [Versión 2]');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
}); 