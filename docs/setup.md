# Setup do Ambiente

## Pré-requisitos

- Java 21+
- Maven
- PostgreSQL
- Git
- IntelliJ IDEA ou VS Code

---

## Clonar

```bash
git clone https://github.com/emprega-co/emprega-co-api.git
```

---

## Executar

Crie o banco local:

```bash
createdb emprega_co
```

Configure as variáveis de ambiente se não for usar os defaults:

```bash
DB_URL=jdbc:postgresql://localhost:5432/emprega_co
DB_USERNAME=postgres
DB_PASSWORD=postgres
```

```bash
mvn spring-boot:run
```

As migrations do Flyway são executadas automaticamente na subida da aplicação.

---

## Estrutura

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
