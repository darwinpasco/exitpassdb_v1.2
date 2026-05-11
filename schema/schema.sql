-- ============================================================
-- ExitPass Database Schema v1.2
-- Canonical Atlas State-Based Schema
-- ============================================================

-- ============================================================
-- 00. Extensions
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- 01. Schemas
-- ============================================================

CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS config;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS coupons;
CREATE SCHEMA IF NOT EXISTS discounts;
CREATE SCHEMA IF NOT EXISTS events;
CREATE SCHEMA IF NOT EXISTS gates;
CREATE SCHEMA IF NOT EXISTS identity;
CREATE SCHEMA IF NOT EXISTS integration;
CREATE SCHEMA IF NOT EXISTS merchants;
CREATE SCHEMA IF NOT EXISTS operations;
CREATE SCHEMA IF NOT EXISTS payments;
CREATE SCHEMA IF NOT EXISTS reconciliation;
CREATE SCHEMA IF NOT EXISTS sessions;
CREATE SCHEMA IF NOT EXISTS sites;

-- ============================================================
-- 02. Enum / Type Definitions
-- ============================================================

-- Generated enum definitions will be appended here.

-- ============================================================
-- 03. Table Definitions
-- ============================================================

-- Generated table definitions will be appended here.

-- ============================================================
-- 04. Foreign Key Constraints
-- ============================================================

-- Generated foreign key definitions will be appended here.

-- ============================================================
-- 05. Indexes
-- ============================================================

-- Generated index definitions will be appended here.

-- ============================================================
-- 06. Views
-- ============================================================

-- Generated view definitions will be appended here.

-- ============================================================
-- 07. Functions and Triggers
-- ============================================================

-- Generated function and trigger definitions will be appended here.