-- ================================================================
-- ロレクエ（2期生）Supabase スキーマ
-- 1期生（ロレポチ）と同じ Supabase プロジェクトに追加する専用テーブル。
-- すべて lq_ プレフィックス付き。既存テーブル（members 等）には一切触れません。
-- Supabase SQL Editor で全文実行してください
-- ================================================================

-- 1. lq_members テーブル
CREATE TABLE IF NOT EXISTS lq_members (
  id INTEGER PRIMARY KEY,
  line_name TEXT,
  name TEXT,
  status TEXT DEFAULT '未当選',
  priority TEXT DEFAULT '1:アクティブ',
  won1 TEXT,
  won2 TEXT,
  won3 TEXT,
  last_active TEXT,
  total_reward INTEGER DEFAULT 0,
  note TEXT DEFAULT '',
  no_purchase BOOLEAN DEFAULT FALSE,
  store_purchase_date TEXT,
  line_user_id TEXT
);

-- 2. lq_weekly_inputs テーブル
CREATE TABLE IF NOT EXISTS lq_weekly_inputs (
  month INTEGER NOT NULL,
  week INTEGER NOT NULL,
  member_id INTEGER NOT NULL,
  apply INTEGER DEFAULT 0,
  result_ss BOOLEAN DEFAULT FALSE,
  won_date TEXT,
  won_shop TEXT,
  restricted_applied BOOLEAN DEFAULT FALSE,
  restricted_result TEXT,
  PRIMARY KEY (month, week, member_id)
);

-- 3. lq_win_history テーブル
CREATE TABLE IF NOT EXISTS lq_win_history (
  id INTEGER PRIMARY KEY,
  member_id INTEGER,
  line_name TEXT,
  name TEXT,
  won_date TEXT,
  shop TEXT,
  win_num INTEGER,
  month INTEGER,
  week INTEGER,
  is_companion_mode BOOLEAN DEFAULT FALSE,
  visit_date TEXT
);

-- 4. lq_purchase_results テーブル
CREATE TABLE IF NOT EXISTS lq_purchase_results (
  win_idx INTEGER PRIMARY KEY,
  result TEXT,
  purchase_date TEXT,
  units INTEGER,
  companion TEXT,
  companion_result TEXT,
  companion_units INTEGER,
  note TEXT,
  restriction_memo TEXT
);

-- 5. lq_store_purchases テーブル
-- ※ id は Date.now()（ミリ秒）を使うため BIGINT（1期生スキーマの INTEGER では桁あふれする）
CREATE TABLE IF NOT EXISTS lq_store_purchases (
  id BIGINT PRIMARY KEY,
  member_id INTEGER,
  line_name TEXT,
  name TEXT,
  purchase_date TEXT,
  shop TEXT,
  result TEXT,
  units INTEGER,
  companion TEXT,
  note TEXT
);

-- 6. lq_reward_payments テーブル（★2期生の新機能: 報酬ストック支払い記録）
CREATE TABLE IF NOT EXISTS lq_reward_payments (
  id BIGINT PRIMARY KEY,
  member_id INTEGER,
  amount INTEGER,
  paid_date TEXT,
  note TEXT DEFAULT ''
);

-- 7. lq_app_config テーブル（月・週の状態管理）
CREATE TABLE IF NOT EXISTS lq_app_config (
  key TEXT PRIMARY KEY,
  cur_month INTEGER DEFAULT 6,
  cur_week INTEGER DEFAULT 1,
  available_months JSONB DEFAULT '[6]'
);

-- ================================================================
-- RLS（Row Level Security）設定
-- 認証済みユーザー（管理者）のみ全操作可
-- ※ anon key を HTML に埋め込む前提のため、RLS 有効化は必須
-- ================================================================
ALTER TABLE lq_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE lq_weekly_inputs ENABLE ROW LEVEL SECURITY;
ALTER TABLE lq_win_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE lq_purchase_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE lq_store_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE lq_reward_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lq_app_config ENABLE ROW LEVEL SECURITY;

-- 既存ポリシーを削除してから再作成（lq_ テーブルのみ対象）
DROP POLICY IF EXISTS "Allow authenticated" ON lq_members;
DROP POLICY IF EXISTS "Allow authenticated" ON lq_weekly_inputs;
DROP POLICY IF EXISTS "Allow authenticated" ON lq_win_history;
DROP POLICY IF EXISTS "Allow authenticated" ON lq_purchase_results;
DROP POLICY IF EXISTS "Allow authenticated" ON lq_store_purchases;
DROP POLICY IF EXISTS "Allow authenticated" ON lq_reward_payments;
DROP POLICY IF EXISTS "Allow authenticated" ON lq_app_config;

CREATE POLICY "Allow authenticated" ON lq_members
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated" ON lq_weekly_inputs
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated" ON lq_win_history
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated" ON lq_purchase_results
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated" ON lq_store_purchases
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated" ON lq_reward_payments
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated" ON lq_app_config
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ================================================================
-- 初期データ投入（lq_app_config のデフォルト行: 2026年6月スタート）
-- ================================================================
INSERT INTO lq_app_config (key, cur_month, cur_week, available_months)
VALUES ('main', 6, 1, '[6]')
ON CONFLICT (key) DO NOTHING;

-- ================================================================
-- ロールバック（撤去したい場合のみ。1期生テーブルには影響しません）
-- ================================================================
-- DROP TABLE IF EXISTS lq_reward_payments;
-- DROP TABLE IF EXISTS lq_app_config;
-- DROP TABLE IF EXISTS lq_store_purchases;
-- DROP TABLE IF EXISTS lq_purchase_results;
-- DROP TABLE IF EXISTS lq_win_history;
-- DROP TABLE IF EXISTS lq_weekly_inputs;
-- DROP TABLE IF EXISTS lq_members;
