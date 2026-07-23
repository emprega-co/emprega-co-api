CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    phone VARCHAR(30),
    password_hash VARCHAR(255) NOT NULL,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_users_type CHECK (type IN ('CLIENT', 'DOMESTIC')),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'BLOCKED'))
);

CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE profiles_domestic (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    bio TEXT,
    experience_years SMALLINT NOT NULL DEFAULT 0,
    hourly_rate NUMERIC(10, 2),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    neighborhood VARCHAR(100),
    document_number VARCHAR(30),
    background_checked BOOLEAN NOT NULL DEFAULT FALSE,
    average_rating NUMERIC(3, 2) NOT NULL DEFAULT 0,
    review_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_profiles_domestic_experience CHECK (experience_years >= 0),
    CONSTRAINT chk_profiles_domestic_hourly_rate CHECK (hourly_rate IS NULL OR hourly_rate >= 0),
    CONSTRAINT chk_profiles_domestic_rating CHECK (average_rating >= 0 AND average_rating <= 5),
    CONSTRAINT chk_profiles_domestic_review_count CHECK (review_count >= 0)
);

CREATE TABLE domestic_profile_services (
    domestic_profile_id UUID NOT NULL REFERENCES profiles_domestic (id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services (id) ON DELETE RESTRICT,
    PRIMARY KEY (domestic_profile_id, service_id)
);

CREATE TABLE availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domestic_profile_id UUID NOT NULL REFERENCES profiles_domestic (id) ON DELETE CASCADE,
    weekday SMALLINT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_availability_weekday CHECK (weekday BETWEEN 0 AND 6),
    CONSTRAINT chk_availability_time_range CHECK (start_time < end_time)
);

CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    domestic_profile_id UUID NOT NULL REFERENCES profiles_domestic (id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services (id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    responded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_matches_status CHECK (status IN ('REQUESTED', 'ACCEPTED', 'REJECTED', 'CANCELLED'))
);

CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID NOT NULL UNIQUE REFERENCES matches (id) ON DELETE RESTRICT,
    client_id UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    domestic_profile_id UUID NOT NULL REFERENCES profiles_domestic (id) ON DELETE RESTRICT,
    service_id UUID NOT NULL REFERENCES services (id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    scheduled_for TIMESTAMPTZ NOT NULL,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    amount NUMERIC(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_contracts_status CHECK (status IN ('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT chk_contracts_amount CHECK (amount >= 0),
    CONSTRAINT chk_contracts_period CHECK (finished_at IS NULL OR started_at IS NULL OR started_at <= finished_at)
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches (id) ON DELETE CASCADE,
    contract_id UUID REFERENCES contracts (id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_messages_context CHECK (match_id IS NOT NULL OR contract_id IS NOT NULL),
    CONSTRAINT chk_messages_participants CHECK (sender_id <> recipient_id)
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID REFERENCES contracts (id) ON DELETE RESTRICT,
    payer_id UUID NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    domestic_profile_id UUID REFERENCES profiles_domestic (id) ON DELETE RESTRICT,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    provider VARCHAR(40),
    provider_reference VARCHAR(120),
    amount NUMERIC(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'BRL',
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_payments_type CHECK (type IN ('SERVICE', 'SUBSCRIPTION')),
    CONSTRAINT chk_payments_status CHECK (status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'CANCELLED')),
    CONSTRAINT chk_payments_amount CHECK (amount >= 0)
);

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES contracts (id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    reviewed_user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_reviews_contract_reviewer UNIQUE (contract_id, reviewer_id),
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_reviews_users CHECK (reviewer_id <> reviewed_user_id)
);

CREATE INDEX idx_users_type ON users (type);
CREATE INDEX idx_profiles_domestic_city_state ON profiles_domestic (city, state);
CREATE INDEX idx_domestic_profile_services_service ON domestic_profile_services (service_id);
CREATE INDEX idx_availability_profile_weekday ON availability (domestic_profile_id, weekday);
CREATE INDEX idx_matches_client ON matches (client_id);
CREATE INDEX idx_matches_domestic_profile ON matches (domestic_profile_id);
CREATE INDEX idx_matches_status ON matches (status);
CREATE UNIQUE INDEX uq_matches_active_request
    ON matches (client_id, domestic_profile_id, service_id)
    WHERE status IN ('REQUESTED', 'ACCEPTED');
CREATE INDEX idx_contracts_client ON contracts (client_id);
CREATE INDEX idx_contracts_domestic_profile ON contracts (domestic_profile_id);
CREATE INDEX idx_contracts_status ON contracts (status);
CREATE INDEX idx_messages_match_created_at ON messages (match_id, created_at);
CREATE INDEX idx_messages_contract_created_at ON messages (contract_id, created_at);
CREATE INDEX idx_payments_contract ON payments (contract_id);
CREATE INDEX idx_payments_payer ON payments (payer_id);
CREATE INDEX idx_reviews_reviewed_user ON reviews (reviewed_user_id);
