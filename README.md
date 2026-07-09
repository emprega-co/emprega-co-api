# ☕ Emprega.co API

API REST responsável pelas regras de negócio da plataforma Emprega.co.

---

# Tecnologias

- Java 21
- Spring Boot
- Spring Security
- Spring Data JPA
- Hibernate
- Maven
- PostgreSQL

---

# Pré-requisitos

- Java 21+
- Maven
- PostgreSQL
- Git

---

# Executando

Clone:

```bash
git clone https://github.com/emprega-co/emprega-co-api.git
```

Entre na pasta:

```bash
cd emprega-co-api
```

Execute:

```bash
mvn spring-boot:run
```

---

# Arquitetura

```
Controller

↓

Service

↓

Repository

↓

Database
```

---

# Estrutura

```
controller/
service/
repository/
entity/
dto/
config/
security/
exception/
util/
```

---

# Fluxo de Desenvolvimento

```
main
│
develop
│
feature/*
bugfix/*
hotfix/*
```

---

# Commits

Utilizamos Conventional Commits.

---

# Documentação

Consulte a pasta:

```
docs/
```

---

# Projeto relacionado

- emprega-co-mobile

---

# Licença

MIT
