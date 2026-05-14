-- =============================================================================
-- 登录功能模块 - PostgreSQL 数据库脚本
-- 依据文档：公用- 登录功能模块实现.md 第 4 章数据库设计
-- =============================================================================

-- 扩展（如需 UUID 等）
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 枚举类型
-- -----------------------------------------------------------------------------

CREATE TYPE user_status_enum AS ENUM ('active', 'inactive', 'locked', 'suspended');
CREATE TYPE hash_algorithm_enum AS ENUM ('bcrypt', 'argon2', 'pbkdf2', 'scrypt');
CREATE TYPE two_factor_code_type_enum AS ENUM ('sms', 'email', 'totp');
CREATE TYPE qr_login_status_enum AS ENUM ('pending', 'scanned', 'confirmed', 'cancelled', 'expired');
CREATE TYPE gesture_type_enum AS ENUM ('draw', 'swipe', 'pinch', 'rotate', 'tap');
CREATE TYPE salt_type_enum AS ENUM ('static', 'dynamic', 'rotating');
CREATE TYPE security_severity_enum AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE password_operation_type_enum AS ENUM ('hash', 'verify', 'migrate');
CREATE TYPE account_lock_reason_enum AS ENUM ('failed_attempts', 'admin_action', 'suspicious_activity');
CREATE TYPE device_type_enum AS ENUM ('web', 'ios', 'android', 'desktop', 'other');

-- -----------------------------------------------------------------------------
-- 4.1 核心表结构
-- -----------------------------------------------------------------------------

-- 用户主表：存储账号、密码哈希、盐值、2FA 开关及验证状态等
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status user_status_enum NOT NULL DEFAULT 'active',

    -- 密码安全相关
    salt VARCHAR(255) NOT NULL,
    hash_algorithm hash_algorithm_enum NOT NULL DEFAULT 'bcrypt',
    password_strength_score INT DEFAULT 0,
    password_complexity JSONB,

    -- 账户安全相关
    failed_login_attempts INT DEFAULT 0,
    locked_until TIMESTAMPTZ NULL,
    password_changed_at TIMESTAMPTZ NULL,
    password_expires_at TIMESTAMPTZ NULL,
    last_login_at TIMESTAMPTZ NULL,
    last_login_ip VARCHAR(45),

    -- 双因素认证
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    totp_secret VARCHAR(255),
    backup_codes_count INT DEFAULT 0,

    -- 新增认证方式
    qr_login_enabled BOOLEAN DEFAULT FALSE,
    face_recognition_enabled BOOLEAN DEFAULT FALSE,
    gesture_recognition_enabled BOOLEAN DEFAULT FALSE,

    -- 邮箱和手机验证
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    phone_verification_token VARCHAR(255),

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_username ON users (username);
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_phone_number ON users (phone_number);
CREATE INDEX idx_users_status ON users (status);
CREATE INDEX idx_users_password_changed_at ON users (password_changed_at);
CREATE INDEX idx_users_password_expires_at ON users (password_expires_at);
CREATE INDEX idx_users_hash_algorithm ON users (hash_algorithm);
CREATE INDEX idx_users_created_at ON users (created_at);

-- updated_at 自动更新触发器
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

-- -----------------------------------------------------------------------------

-- 登录审计：每次登录尝试（成功/失败）记录 IP、User-Agent、失败原因等
CREATE TABLE login_logs (
    id SERIAL PRIMARY KEY,
    user_id INT NULL,
    username VARCHAR(50),
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT,
    success BOOLEAN NOT NULL,
    failure_reason VARCHAR(100),
    two_factor_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_login_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_login_logs_user_id ON login_logs (user_id);
CREATE INDEX idx_login_logs_ip_address ON login_logs (ip_address);
CREATE INDEX idx_login_logs_success ON login_logs (success);
CREATE INDEX idx_login_logs_created_at ON login_logs (created_at);

-- -----------------------------------------------------------------------------

-- 刷新令牌：用于在 Access Token 过期后换取新 Token，支持登出撤销
CREATE TABLE refresh_tokens (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    revoked_at TIMESTAMPTZ NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens (user_id);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens (expires_at);
CREATE INDEX idx_refresh_tokens_revoked ON refresh_tokens (revoked);

-- -----------------------------------------------------------------------------
-- 4.2 双因素认证相关表
-- -----------------------------------------------------------------------------

-- 2FA 验证码：短信/邮件/TOTP 一次性码，用于二次验证
CREATE TABLE two_factor_codes (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    code VARCHAR(10) NOT NULL,
    type two_factor_code_type_enum NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_two_factor_codes_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_two_factor_codes_user_id ON two_factor_codes (user_id);
CREATE INDEX idx_two_factor_codes_code ON two_factor_codes (code);
CREATE INDEX idx_two_factor_codes_expires_at ON two_factor_codes (expires_at);
CREATE INDEX idx_two_factor_codes_used ON two_factor_codes (used);

-- -----------------------------------------------------------------------------

-- 2FA 备用码：开启 2FA 时生成一批一次性码，用于无法使用主方式时恢复
CREATE TABLE backup_codes (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    code_hash VARCHAR(255) NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_backup_codes_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_backup_codes_user_id ON backup_codes (user_id);
CREATE INDEX idx_backup_codes_used ON backup_codes (used);

-- -----------------------------------------------------------------------------

-- 扫码登录：PC 端展示二维码，移动端扫码确认，记录会话与状态
CREATE TABLE qr_login_sessions (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    session_id VARCHAR(255) NOT NULL UNIQUE,
    login_token VARCHAR(255) NOT NULL UNIQUE,
    status qr_login_status_enum NOT NULL DEFAULT 'pending',
    expires_at TIMESTAMPTZ NOT NULL,
    scanned_at TIMESTAMPTZ NULL,
    scanned_by INT NULL,
    confirmed_at TIMESTAMPTZ NULL,
    cancelled_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_qr_login_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_qr_login_sessions_scanned_by FOREIGN KEY (scanned_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_qr_login_sessions_user_id ON qr_login_sessions (user_id);
CREATE INDEX idx_qr_login_sessions_session_id ON qr_login_sessions (session_id);
CREATE INDEX idx_qr_login_sessions_login_token ON qr_login_sessions (login_token);
CREATE INDEX idx_qr_login_sessions_status ON qr_login_sessions (status);
CREATE INDEX idx_qr_login_sessions_expires_at ON qr_login_sessions (expires_at);

-- -----------------------------------------------------------------------------

-- 人脸识别：存储用户人脸特征向量及质量/活体评分，用于登录校验
CREATE TABLE user_face_descriptors (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    descriptor TEXT NOT NULL,
    face_quality_score DECIMAL(3,2),
    liveness_score DECIMAL(3,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_face_descriptors_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_face_descriptors_user_id ON user_face_descriptors (user_id);
CREATE INDEX idx_user_face_descriptors_created_at ON user_face_descriptors (created_at);

-- -----------------------------------------------------------------------------

-- 手势识别：存储用户注册的手势类型与特征/模板，用于登录校验
CREATE TABLE user_gesture_patterns (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    gesture_type gesture_type_enum NOT NULL,
    features TEXT NOT NULL,
    template TEXT NOT NULL,
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_gesture_patterns_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_gesture_patterns_user_id ON user_gesture_patterns (user_id);
CREATE INDEX idx_user_gesture_patterns_gesture_type ON user_gesture_patterns (gesture_type);
CREATE INDEX idx_user_gesture_patterns_created_at ON user_gesture_patterns (created_at);

-- -----------------------------------------------------------------------------
-- 4.3 OAuth 第三方登录表
-- -----------------------------------------------------------------------------

-- 第三方登录：本系统用户与第三方账号的绑定及 Token
CREATE TABLE oauth_accounts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    provider_username VARCHAR(255),
    provider_email VARCHAR(255),
    provider_avatar_url TEXT,
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_oauth_accounts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_oauth_accounts_provider_user UNIQUE (provider, provider_user_id)
);

CREATE INDEX idx_oauth_accounts_user_id ON oauth_accounts (user_id);
CREATE INDEX idx_oauth_accounts_provider ON oauth_accounts (provider);

CREATE TRIGGER tr_oauth_accounts_updated_at
    BEFORE UPDATE ON oauth_accounts
    FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

-- -----------------------------------------------------------------------------

-- OAuth 授权流程：临时存储 state，防 CSRF，过期后清理
CREATE TABLE oauth_states (
    id SERIAL PRIMARY KEY,
    state VARCHAR(255) NOT NULL UNIQUE,
    user_id INT NULL,
    provider VARCHAR(50) NOT NULL,
    redirect_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT fk_oauth_states_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_oauth_states_state ON oauth_states (state);
CREATE INDEX idx_oauth_states_expires_at ON oauth_states (expires_at);

-- -----------------------------------------------------------------------------
-- 4.4 安全相关表
-- -----------------------------------------------------------------------------

-- 密码历史：禁止用户重复使用最近 N 次密码，用于改密校验
CREATE TABLE password_history (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(255) NOT NULL,
    hash_algorithm hash_algorithm_enum NOT NULL,
    password_strength_score INT DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_password_history_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_password_history_user_id ON password_history (user_id);
CREATE INDEX idx_password_history_created_at ON password_history (created_at);
CREATE INDEX idx_password_history_hash_algorithm ON password_history (hash_algorithm);

-- -----------------------------------------------------------------------------

-- 密码哈希操作审计：记录 hash/verify/migrate 等操作，用于安全与性能分析
CREATE TABLE password_hash_logs (
    id SERIAL PRIMARY KEY,
    user_id INT NULL,
    algorithm VARCHAR(50) NOT NULL,
    salt_rounds INT,
    operation_type password_operation_type_enum NOT NULL,
    success BOOLEAN NOT NULL,
    processing_time_ms INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_password_hash_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_password_hash_logs_user_id ON password_hash_logs (user_id);
CREATE INDEX idx_password_hash_logs_algorithm ON password_hash_logs (algorithm);
CREATE INDEX idx_password_hash_logs_operation_type ON password_hash_logs (operation_type);
CREATE INDEX idx_password_hash_logs_success ON password_hash_logs (success);
CREATE INDEX idx_password_hash_logs_created_at ON password_hash_logs (created_at);

-- -----------------------------------------------------------------------------

-- 密码算法迁移：从旧算法迁移到新算法时的记录与审计
CREATE TABLE password_migration_logs (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    from_algorithm VARCHAR(50) NOT NULL,
    to_algorithm VARCHAR(50) NOT NULL,
    migration_reason VARCHAR(255),
    success BOOLEAN NOT NULL,
    migrated_at TIMESTAMPTZ NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_password_migration_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_password_migration_logs_user_id ON password_migration_logs (user_id);
CREATE INDEX idx_password_migration_logs_from_algorithm ON password_migration_logs (from_algorithm);
CREATE INDEX idx_password_migration_logs_to_algorithm ON password_migration_logs (to_algorithm);
CREATE INDEX idx_password_migration_logs_success ON password_migration_logs (success);
CREATE INDEX idx_password_migration_logs_migrated_at ON password_migration_logs (migrated_at);

-- -----------------------------------------------------------------------------

-- 盐值管理：存储用户密码盐值（静态/动态/轮换），用于审计与轮换
CREATE TABLE salt_management (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    salt_value VARCHAR(255) NOT NULL,
    salt_type salt_type_enum NOT NULL DEFAULT 'static',
    entropy_score DECIMAL(10,2),
    generation_method VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NULL,
    is_active BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_salt_management_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 每用户仅允许一条当前生效的盐值（部分唯一索引）
CREATE UNIQUE INDEX idx_salt_management_user_active ON salt_management (user_id) WHERE is_active = TRUE;

CREATE INDEX idx_salt_management_user_id ON salt_management (user_id);
CREATE INDEX idx_salt_management_salt_type ON salt_management (salt_type);
CREATE INDEX idx_salt_management_is_active ON salt_management (is_active);
CREATE INDEX idx_salt_management_entropy_score ON salt_management (entropy_score);
CREATE INDEX idx_salt_management_expires_at ON salt_management (expires_at);

-- -----------------------------------------------------------------------------

-- 安全事件：异常登录、暴力破解、敏感操作等，用于告警与处置
CREATE TABLE security_events (
    id SERIAL PRIMARY KEY,
    user_id INT NULL,
    event_type VARCHAR(100) NOT NULL,
    severity security_severity_enum NOT NULL DEFAULT 'medium',
    description TEXT,
    details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMPTZ NULL,
    resolved_by INT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_security_events_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_security_events_resolved_by FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_security_events_user_id ON security_events (user_id);
CREATE INDEX idx_security_events_event_type ON security_events (event_type);
CREATE INDEX idx_security_events_severity ON security_events (severity);
CREATE INDEX idx_security_events_resolved ON security_events (resolved);
CREATE INDEX idx_security_events_created_at ON security_events (created_at);

-- -----------------------------------------------------------------------------

-- 忘记密码：重置链接 Token，一次性使用，过期失效
CREATE TABLE password_resets (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMPTZ NULL,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_password_resets_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_password_resets_user_id ON password_resets (user_id);
CREATE INDEX idx_password_resets_expires_at ON password_resets (expires_at);

-- -----------------------------------------------------------------------------

-- 账户锁定：记录锁定原因、解锁时间及操作人，用于审计
CREATE TABLE account_locks (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    reason account_lock_reason_enum NOT NULL,
    locked_until TIMESTAMPTZ NOT NULL,
    ip_address VARCHAR(45),
    admin_user_id INT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_account_locks_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_account_locks_admin FOREIGN KEY (admin_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_account_locks_user_id ON account_locks (user_id);
CREATE INDEX idx_account_locks_locked_until ON account_locks (locked_until);

-- -----------------------------------------------------------------------------
-- 9.3 多设备登录 - 用户会话/设备表
-- -----------------------------------------------------------------------------

-- 用户会话/设备表：多设备列表与远程登出，与 refresh_tokens 一一对应
CREATE TABLE user_sessions (
    id VARCHAR(64) PRIMARY KEY,
    user_id INT NOT NULL,
    refresh_token_id INT NULL,

    device_id VARCHAR(128),
    device_name VARCHAR(100),
    device_type device_type_enum NOT NULL DEFAULT 'other',
    user_agent TEXT,
    ip_address VARCHAR(45),

    last_active_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_sessions_refresh_token FOREIGN KEY (refresh_token_id) REFERENCES refresh_tokens(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions (user_id);
CREATE INDEX idx_user_sessions_last_active_at ON user_sessions (last_active_at);

-- 更新会话时自动刷新 last_active_at
CREATE OR REPLACE FUNCTION set_user_sessions_last_active_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_active_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_user_sessions_last_active_at
    BEFORE UPDATE ON user_sessions
    FOR EACH ROW EXECUTE PROCEDURE set_user_sessions_last_active_at();

-- -----------------------------------------------------------------------------
-- 可选：LDAP 账号关联表
-- -----------------------------------------------------------------------------

-- LDAP 账号关联：本地用户与 LDAP DN 一一对应，用于 LDAP 登录时快速查找
CREATE TABLE ldap_accounts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    provider VARCHAR(32) NOT NULL DEFAULT 'ldap',
    ldap_dn VARCHAR(512) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ldap_accounts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_ldap_accounts_ldap_dn UNIQUE (ldap_dn)
);

CREATE INDEX idx_ldap_accounts_user_id ON ldap_accounts (user_id);

-- -----------------------------------------------------------------------------
-- 说明
-- -----------------------------------------------------------------------------
-- 1. 时间字段统一使用 TIMESTAMPTZ，便于多时区与审计。
-- 2. 枚举使用 CREATE TYPE ... AS ENUM，与文档中 ENUM 语义一致。
-- 3. users、oauth_accounts 的 updated_at 由触发器自动更新。
-- 4. user_sessions.last_active_at 在 UPDATE 时由触发器更新为当前时间。
-- 5. salt_management 使用部分唯一索引，保证每用户仅一条 is_active = true 的记录。
-- 6. 若需 UUID 作为 user_sessions.id，可先 CREATE EXTENSION "uuid-ossp"，
--    并将 id 改为 UUID 类型，默认 gen_random_uuid() 或 uuid_generate_v4()。
