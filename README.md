# AWS CI/CD Pipeline con Node.js

Este proyecto demuestra cómo configurar un pipeline de CI/CD completo en AWS para una aplicación Node.js, utilizando servicios como CodePipeline, CodeBuild, CodeDeploy, y una instancia EC2.

## Arquitectura del Pipeline

```
GitHub → CodePipeline → CodeBuild → S3 (Artifacts) → CodeDeploy → EC2
```

## Componentes Principales

1. **GitHub**: Almacena el código fuente
2. **AWS CodePipeline**: Orquesta el flujo de CI/CD
3. **AWS CodeBuild**: Compila y prueba la aplicación
4. **Amazon S3**: Almacena los artefactos de construcción
5. **AWS CodeDeploy**: Gestiona el despliegue en EC2
6. **Amazon EC2**: Ejecuta la aplicación

## Estructura del Proyecto

```
.
├── app.js                    # Aplicación Node.js
├── appspec.yml              # Configuración de CodeDeploy
├── buildspec.yml            # Configuración de CodeBuild
├── package.json             # Dependencias de Node.js
├── scripts/                 # Scripts de despliegue
│   ├── before_install.sh    # Script pre-instalación
│   └── start_application.sh # Script de inicio
└── s3-access-policy.json    # Política IAM para acceso a S3
```

## Configuración Paso a Paso

### 1. Preparación del Entorno AWS

#### Crear Roles IAM

```bash
# Rol para CodeDeploy
aws iam create-role --role-name CodeDeployRole --assume-role-policy-document file://codedeploy-trust.json

# Rol para EC2
aws iam create-role --role-name EC2CodeDeployRole --assume-role-policy-document file://ec2-trust.json
```

### 2. Configuración de la Instancia EC2

```bash
# Conectar a la instancia EC2
ssh -i nodejs-demo-app-key.pem ec2-user@<EC2-IP>

# Verificar estado del agente CodeDeploy
sudo service codedeploy-agent status

# Instalar Node.js y PM2
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs
npm install -g pm2
```

### 3. Configuración de CodeDeploy (appspec.yml)

```yaml
version: 0.0
os: linux
files:
  - source: /
    destination: /home/ec2-user/nodejs-demo-app
hooks:
  BeforeInstall:
    - location: scripts/before_install.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: scripts/start_application.sh
      timeout: 300
      runas: root
```

### 4. Configuración de CodeBuild (buildspec.yml)

```yaml
version: 0.2
phases:
  install:
    runtime-versions:
      nodejs: 16
    commands:
      - echo "Installing dependencies..."
      - npm install
  build:
    commands:
      - echo "Running build..."
      - npm run build || true
  post_build:
    commands:
      - echo "Build completed"
artifacts:
  files:
    - '**/*'
  base-directory: '.'
```

### 5. Scripts de Despliegue

#### before_install.sh

```bash
#!/bin/bash
if ! command -v node &> /dev/null; then
    curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
    sudo yum install -y nodejs
fi

if [ ! -d "/home/ec2-user/nodejs-demo-app" ]; then
    mkdir -p /home/ec2-user/nodejs-demo-app
fi

chown -R ec2-user:ec2-user /home/ec2-user/nodejs-demo-app
```

#### start_application.sh

```bash
#!/bin/bash
cd /home/ec2-user/nodejs-demo-app

# Install dependencies
npm install

# Start with PM2
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi

pm2 stop nodejs-demo-app || true
pm2 delete nodejs-demo-app || true
pm2 start app.js --name nodejs-demo-app
pm2 save
```

## Comandos Útiles

### Gestión de CodeDeploy

```bash
# Verificar estado del agente
sudo service codedeploy-agent status

# Reiniciar agente
sudo service codedeploy-agent restart

# Ver logs del agente
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

### Gestión del Pipeline

```bash
# Listar pipelines
aws codepipeline list-pipelines

# Iniciar ejecución del pipeline
aws codepipeline start-pipeline-execution --name nodejs-demo-app-pipeline

# Ver estado de ejecución
aws codepipeline get-pipeline-execution --pipeline-name nodejs-demo-app-pipeline --pipeline-execution-id <ID>
```

### Gestión de la Aplicación

```bash
# Ver logs de PM2
pm2 logs

# Listar aplicaciones
pm2 list

# Reiniciar aplicación
pm2 restart nodejs-demo-app

# Guardar configuración de PM2
pm2 save
```

## Solución de Problemas Comunes

### 1. Error de Acceso a S3

Si CodeDeploy no puede acceder a los artefactos en S3, agregar la siguiente política al rol EC2CodeDeployRole:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::nombre-bucket/*",
                "arn:aws:s3:::nombre-bucket"
            ]
        }
    ]
}
```

### 2. Problemas con el Agente de CodeDeploy

```bash
# Reinstalar el agente
sudo yum remove -y codedeploy-agent
sudo yum install -y codedeploy-agent
```

## Mejores Prácticas

1. **Seguridad**:

   - Usar roles IAM con privilegios mínimos
   - Mantener las claves SSH y credenciales seguras
   - Regularmente rotar credenciales
2. **Monitoreo**:

   - Configurar alarmas en CloudWatch
   - Monitorear logs de la aplicación
   - Revisar métricas de EC2
3. **Despliegue**:

   - Usar estrategias de despliegue gradual
   - Mantener scripts de rollback
   - Probar scripts de despliegue localmente

## Recursos Adicionales

- [Documentación AWS CodePipeline](https://docs.aws.amazon.com/codepipeline)
- [Documentación AWS CodeDeploy](https://docs.aws.amazon.com/codedeploy)
- [Documentación PM2](https://pm2.keymetrics.io/docs/usage/quick-start/)
