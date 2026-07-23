# Banco de dados

O banco principal usa PostgreSQL com migrations versionadas pelo Flyway.

## Migration inicial

- `src/main/resources/db/migration/V1__create_main_schema.sql`

## Entidades

- `users`: usuários da plataforma, separados por `CLIENT` e `DOMESTIC`.
- `profiles_domestic`: dados específicos da doméstica, vinculados 1:1 a um usuário.
- `services`: tipos de serviço oferecidos.
- `domestic_profile_services`: relação N:N entre domésticas e serviços.
- `availability`: agenda semanal de disponibilidade da doméstica.
- `matches`: solicitação e relacionamento inicial entre cliente e doméstica.
- `contracts`: contratação efetiva originada de um match aceito.
- `messages`: mensagens de chat ligadas a match ou contrato.
- `payments`: pagamentos de serviços e assinaturas.
- `reviews`: avaliações pós-serviço.

## Regras principais

- Todas as tabelas de negócio usam UUID como chave primária.
- Status e tipos são armazenados como `VARCHAR` com `CHECK` constraints.
- Campos monetários usam `NUMERIC(10, 2)`.
- Datas de auditoria usam `TIMESTAMPTZ`.
- `users.email` é único.
- Cada doméstica tem exatamente um `profiles_domestic`.
- Cada contrato nasce de um único match.
- Cada usuário pode avaliar um contrato apenas uma vez.

## ERD

```mermaid
erDiagram
    users {
        uuid id PK
        varchar name
        varchar email UK
        varchar phone
        varchar password_hash
        varchar type
        varchar status
        timestamptz created_at
        timestamptz updated_at
    }

    profiles_domestic {
        uuid id PK
        uuid user_id FK
        text bio
        smallint experience_years
        numeric hourly_rate
        varchar city
        varchar state
        varchar neighborhood
        varchar document_number
        boolean background_checked
        numeric average_rating
        integer review_count
        timestamptz created_at
        timestamptz updated_at
    }

    services {
        uuid id PK
        varchar name UK
        text description
        boolean active
        timestamptz created_at
        timestamptz updated_at
    }

    domestic_profile_services {
        uuid domestic_profile_id PK,FK
        uuid service_id PK,FK
    }

    availability {
        uuid id PK
        uuid domestic_profile_id FK
        smallint weekday
        time start_time
        time end_time
        boolean active
        timestamptz created_at
        timestamptz updated_at
    }

    matches {
        uuid id PK
        uuid client_id FK
        uuid domestic_profile_id FK
        uuid service_id FK
        varchar status
        timestamptz requested_at
        timestamptz responded_at
        timestamptz created_at
        timestamptz updated_at
    }

    contracts {
        uuid id PK
        uuid match_id FK
        uuid client_id FK
        uuid domestic_profile_id FK
        uuid service_id FK
        varchar status
        timestamptz scheduled_for
        timestamptz started_at
        timestamptz finished_at
        numeric amount
        text notes
        timestamptz created_at
        timestamptz updated_at
    }

    messages {
        uuid id PK
        uuid match_id FK
        uuid contract_id FK
        uuid sender_id FK
        uuid recipient_id FK
        text content
        timestamptz read_at
        timestamptz created_at
    }

    payments {
        uuid id PK
        uuid contract_id FK
        uuid payer_id FK
        uuid domestic_profile_id FK
        varchar type
        varchar status
        varchar provider
        varchar provider_reference
        numeric amount
        varchar currency
        timestamptz paid_at
        timestamptz created_at
        timestamptz updated_at
    }

    reviews {
        uuid id PK
        uuid contract_id FK
        uuid reviewer_id FK
        uuid reviewed_user_id FK
        smallint rating
        text comment
        timestamptz created_at
        timestamptz updated_at
    }

    users ||--o| profiles_domestic : "tem perfil"
    profiles_domestic }o--o{ services : "oferece"
    profiles_domestic ||--o{ availability : "possui"
    users ||--o{ matches : "solicita"
    profiles_domestic ||--o{ matches : "recebe"
    services ||--o{ matches : "classifica"
    matches ||--o| contracts : "gera"
    users ||--o{ contracts : "contrata"
    profiles_domestic ||--o{ contracts : "executa"
    services ||--o{ contracts : "define"
    matches ||--o{ messages : "contextualiza"
    contracts ||--o{ messages : "contextualiza"
    users ||--o{ messages : "envia"
    users ||--o{ messages : "recebe"
    contracts ||--o{ payments : "cobra"
    users ||--o{ payments : "paga"
    profiles_domestic ||--o{ payments : "recebe referencia"
    contracts ||--o{ reviews : "avalia"
    users ||--o{ reviews : "autor"
    users ||--o{ reviews : "avaliado"
```
