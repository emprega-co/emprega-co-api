# Arquitetura

O backend segue arquitetura em camadas.

```
Controller
      │
Service
      │
Repository
      │
Database
```

## Camadas

### Controller

Recebe requisições HTTP.

### Service

Regras de negócio.

### Repository

Persistência.

### Entity

Mapeamento das tabelas.

### DTO

Transferência de dados.

### Security

Autenticação e autorização.

### Config

Configurações do Spring Boot.