-- ============================================================
-- SmartFix Database Schema — Full Setup
-- ============================================================
-- HOW TO RUN THIS:
-- 1. Open your Supabase project dashboard
-- 2. Go to SQL Editor > New Query
-- 3. Paste this entire file and click Run
-- 4. After it succeeds, go to Authentication > Users > Add User
--    Email: admin@smartfix.edu
--    Password: admin123
--    Auto-confirm user: Yes
-- ============================================================

-- CATEGORIES
CREATE TABLE IF NOT EXISTS categories (
  key text PRIMARY KEY,
  label text NOT NULL,
  "desc" text DEFAULT '',
  sort_order int DEFAULT 0
);
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_read_categories" ON categories;
CREATE POLICY "public_read_categories" ON categories FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "auth_insert_categories" ON categories;
CREATE POLICY "auth_insert_categories" ON categories FOR INSERT
  TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_update_categories" ON categories;
CREATE POLICY "auth_update_categories" ON categories FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "auth_delete_categories" ON categories;
CREATE POLICY "auth_delete_categories" ON categories FOR DELETE
  TO authenticated USING (true);

-- PRIORITIES
CREATE TABLE IF NOT EXISTS priorities (
  key text PRIMARY KEY,
  label text NOT NULL,
  sort_order int DEFAULT 0
);
ALTER TABLE priorities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_read_priorities" ON priorities;
CREATE POLICY "public_read_priorities" ON priorities FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "auth_update_priorities" ON priorities;
CREATE POLICY "auth_update_priorities" ON priorities FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

-- STAFF
CREATE TABLE IF NOT EXISTS staff (
  id text PRIMARY KEY,
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  phone text DEFAULT '',
  department text NOT NULL,
  skills text DEFAULT '',
  active boolean DEFAULT true,
  completed_count int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "auth_read_staff" ON staff;
CREATE POLICY "auth_read_staff" ON staff FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "auth_insert_staff" ON staff;
CREATE POLICY "auth_insert_staff" ON staff FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_update_staff" ON staff;
CREATE POLICY "auth_update_staff" ON staff FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "auth_delete_staff" ON staff;
CREATE POLICY "auth_delete_staff" ON staff FOR DELETE TO authenticated USING (true);

-- COMPLAINTS
CREATE TABLE IF NOT EXISTS complaints (
  id text PRIMARY KEY,
  title text NOT NULL,
  category text NOT NULL,
  location text NOT NULL,
  room text DEFAULT '',
  priority text NOT NULL DEFAULT 'medium',
  status text NOT NULL DEFAULT 'pending',
  assigned_staff_id text DEFAULT NULL,
  submitter_name text NOT NULL,
  submitter_contact text NOT NULL,
  description text NOT NULL,
  photo_url text DEFAULT NULL,
  after_photo_url text DEFAULT NULL,
  resolution_notes text DEFAULT '',
  internal_notes text DEFAULT '',
  public_display boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  assigned_at timestamptz DEFAULT NULL,
  resolved_at timestamptz DEFAULT NULL,
  verified_at timestamptz DEFAULT NULL,
  CONSTRAINT fk_staff FOREIGN KEY (assigned_staff_id) REFERENCES staff(id) ON DELETE SET NULL
);
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_read_complaints" ON complaints;
CREATE POLICY "public_read_complaints" ON complaints FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "public_insert_complaints" ON complaints;
CREATE POLICY "public_insert_complaints" ON complaints FOR INSERT
  TO anon, authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_update_complaints" ON complaints;
CREATE POLICY "auth_update_complaints" ON complaints FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "auth_delete_complaints" ON complaints;
CREATE POLICY "auth_delete_complaints" ON complaints FOR DELETE
  TO authenticated USING (true);

-- COMPLAINT TIMELINE
CREATE TABLE IF NOT EXISTS complaint_timeline (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  complaint_id text NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text DEFAULT '',
  type text DEFAULT 'status',
  created_at timestamptz DEFAULT now()
);
ALTER TABLE complaint_timeline ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "public_read_timeline" ON complaint_timeline;
CREATE POLICY "public_read_timeline" ON complaint_timeline FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "auth_insert_timeline" ON complaint_timeline;
CREATE POLICY "auth_insert_timeline" ON complaint_timeline FOR INSERT
  TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_delete_timeline" ON complaint_timeline;
CREATE POLICY "auth_delete_timeline" ON complaint_timeline FOR DELETE
  TO authenticated USING (true);

-- NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL,
  message text NOT NULL,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "auth_read_notifications" ON notifications;
CREATE POLICY "auth_read_notifications" ON notifications FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "auth_insert_notifications" ON notifications;
CREATE POLICY "auth_insert_notifications" ON notifications FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_update_notifications" ON notifications;
CREATE POLICY "auth_update_notifications" ON notifications FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "auth_delete_notifications" ON notifications;
CREATE POLICY "auth_delete_notifications" ON notifications FOR DELETE TO authenticated USING (true);

-- ACTIVITY LOG
CREATE TABLE IF NOT EXISTS activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action text NOT NULL,
  admin text DEFAULT 'Admin',
  created_at timestamptz DEFAULT now()
);
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "auth_read_activity" ON activity_log;
CREATE POLICY "auth_read_activity" ON activity_log FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "auth_insert_activity" ON activity_log;
CREATE POLICY "auth_insert_activity" ON activity_log FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "auth_delete_activity" ON activity_log;
CREATE POLICY "auth_delete_activity" ON activity_log FOR DELETE TO authenticated USING (true);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_category ON complaints(category);
CREATE INDEX IF NOT EXISTS idx_complaints_assigned_staff ON complaints(assigned_staff_id);
CREATE INDEX IF NOT EXISTS idx_complaints_created_at ON complaints(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_timeline_complaint_id ON complaint_timeline(complaint_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_activity_created_at ON activity_log(created_at DESC);

-- SEED: CATEGORIES
INSERT INTO categories (key, label, "desc", sort_order) VALUES
  ('electrical', 'Electrical', 'Lights, fans, switches, wiring', 1),
  ('plumbing', 'Plumbing', 'Taps, leaks, drainage, toilets', 2),
  ('cleaning', 'Cleaning', 'Classroom & corridor cleanliness', 3),
  ('furniture', 'Furniture', 'Desks, chairs, benches, boards', 4),
  ('internet', 'Internet/IT', 'Wi-Fi, LAN, network issues', 5),
  ('infrastructure', 'Infrastructure', 'Walls, doors, windows, building', 6),
  ('other', 'Other', 'Anything not listed above', 7)
ON CONFLICT (key) DO NOTHING;

-- SEED: PRIORITIES
INSERT INTO priorities (key, label, sort_order) VALUES
  ('low', 'Low', 1),
  ('medium', 'Medium', 2),
  ('high', 'High', 3),
  ('urgent', 'Urgent', 4)
ON CONFLICT (key) DO NOTHING;

-- SEED: STAFF
INSERT INTO staff (id, name, email, phone, department, skills, active, completed_count) VALUES
  ('S-01', 'Ramesh Kumar', 'ramesh.kumar@smartfix.edu', '9876500001', 'electrical', 'Electrical', true, 14),
  ('S-02', 'Suresh Patel', 'suresh.patel@smartfix.edu', '9876500002', 'plumbing', 'Plumbing', true, 9),
  ('S-03', 'Anita Verma', 'anita.verma@smartfix.edu', '9876500003', 'cleaning', 'Cleaning', true, 22),
  ('S-04', 'Mahesh Singh', 'mahesh.singh@smartfix.edu', '9876500004', 'furniture', 'Furniture, Carpentry', false, 6),
  ('S-05', 'Priya Nair', 'priya.nair@smartfix.edu', '9876500005', 'internet', 'Internet/IT', true, 11),
  ('S-06', 'Vikram Desai', 'vikram.desai@smartfix.edu', '9876500006', 'infrastructure', 'Infrastructure', true, 4)
ON CONFLICT (id) DO NOTHING;

-- SEED: COMPLAINTS
INSERT INTO complaints (id, title, category, location, room, priority, status, assigned_staff_id, submitter_name, submitter_contact, description, resolution_notes, internal_notes, public_display, created_at, assigned_at, resolved_at, verified_at) VALUES
  ('SF-1001', 'Tube light not working in Lab 3', 'Electrical', 'Science Block, Lab 3', 'Lab 3', 'medium', 'resolved', 'S-01', 'Aarav Sharma', 'aarav@example.com', 'Two tube lights near the window are flickering and one is completely dead.', 'Both tube lights replaced with new fittings. Tested and working normally.', 'Verified by admin. No further action needed.', true, '2026-09-28 09:15:00', '2026-09-28 11:00:00', '2026-09-30 10:45:00', '2026-09-30 11:00:00'),
  ('SF-1002', 'Leaking tap in washroom near Library', 'Plumbing', 'Library Block, Ground Floor', 'Washroom G-2', 'high', 'in-progress', 'S-02', 'Divya Rao', '9876543210', 'Continuous water leakage from the washbasin tap causing waterlogging.', '', '', false, '2026-10-10 08:40:00', '2026-10-10 10:05:00', NULL, NULL),
  ('SF-1003', 'Broken desk in Classroom 204', 'Furniture', 'Arts Block, Room 204', '204', 'low', 'pending', NULL, 'Karan Mehta', 'karan@example.com', 'One desk has a broken leg and is unstable.', '', '', false, '2026-10-14 13:10:00', NULL, NULL, NULL),
  ('SF-1004', 'Wi-Fi not working in Computer Lab 2', 'Internet/IT', 'IT Block, Lab 2', 'Lab 2', 'urgent', 'pending-verification', 'S-05', 'Sneha Iyer', 'sneha@example.com', 'No internet access on any PC in the lab since morning.', 'Router reconfigured and switch ports reset. Internet restored on all PCs.', '', false, '2026-10-15 09:00:00', '2026-10-15 09:30:00', '2026-10-16 15:00:00', NULL),
  ('SF-1005', 'Classroom not swept in the morning', 'Cleaning', 'Science Block, Room 101', '101', 'medium', 'resolved', 'S-03', 'Rahul Gupta', 'rahul@example.com', 'Room 101 was not cleaned before the first lecture.', 'Room cleaned thoroughly. Cleaning schedule adjusted for morning slot.', '', true, '2026-10-05 08:20:00', '2026-10-05 09:00:00', '2026-10-05 10:30:00', '2026-10-05 11:00:00'),
  ('SF-1006', 'Cracked window pane in corridor', 'Infrastructure', 'Admin Block, 1st Floor Corridor', 'Corridor 1F', 'medium', 'assigned', 'S-06', 'Megha Joshi', 'megha@example.com', 'A window pane in the corridor is cracked and could be a safety hazard.', '', '', false, '2026-10-16 10:00:00', '2026-10-16 10:30:00', NULL, NULL),
  ('SF-1007', 'Fan making loud noise in Lecture Hall 1', 'Electrical', 'Main Building, Lecture Hall 1', 'LH-1', 'low', 'pending', NULL, 'Arjun Reddy', 'arjun@example.com', 'Ceiling fan in Lecture Hall 1 makes a grinding noise when switched on.', '', '', false, '2026-10-17 08:05:00', NULL, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- SEED: TIMELINE
INSERT INTO complaint_timeline (complaint_id, title, description, type, created_at) VALUES
  ('SF-1001', 'Complaint submitted', 'Submitted by Aarav Sharma.', 'submit', '2026-09-28 09:15:00'),
  ('SF-1001', 'Staff assigned', 'Assigned to Ramesh Kumar (Electrical).', 'assign', '2026-09-28 11:00:00'),
  ('SF-1001', 'Work in progress', 'Tube lights inspected, replacement ordered.', 'status', '2026-09-29 14:30:00'),
  ('SF-1001', 'Resolution submitted', 'Both tube lights replaced and tested.', 'resolution', '2026-09-30 10:45:00'),
  ('SF-1001', 'Verified & resolved', 'Admin verified the resolution.', 'verify', '2026-09-30 11:00:00'),
  ('SF-1002', 'Complaint submitted', 'Submitted by Divya Rao.', 'submit', '2026-10-10 08:40:00'),
  ('SF-1002', 'Staff assigned', 'Assigned to Suresh Patel (Plumbing).', 'assign', '2026-10-10 10:05:00'),
  ('SF-1002', 'Work in progress', 'Washer replaced, checking for further leaks.', 'status', '2026-10-11 09:20:00'),
  ('SF-1003', 'Complaint submitted', 'Submitted by Karan Mehta. Awaiting assignment.', 'submit', '2026-10-14 13:10:00'),
  ('SF-1004', 'Complaint submitted', 'Submitted by Sneha Iyer.', 'submit', '2026-10-15 09:00:00'),
  ('SF-1004', 'Staff assigned', 'Assigned to Priya Nair (Internet/IT).', 'assign', '2026-10-15 09:30:00'),
  ('SF-1004', 'Work in progress', 'Router rebooted, checking switch ports.', 'status', '2026-10-15 11:10:00'),
  ('SF-1004', 'Resolution submitted', 'Router reconfigured, internet restored.', 'resolution', '2026-10-16 15:00:00'),
  ('SF-1005', 'Complaint submitted', 'Submitted by Rahul Gupta.', 'submit', '2026-10-05 08:20:00'),
  ('SF-1005', 'Staff assigned', 'Assigned to Anita Verma (Cleaning).', 'assign', '2026-10-05 09:00:00'),
  ('SF-1005', 'Resolution submitted', 'Room cleaned and inspected.', 'resolution', '2026-10-05 10:30:00'),
  ('SF-1005', 'Verified & resolved', 'Admin verified the resolution.', 'verify', '2026-10-05 11:00:00'),
  ('SF-1006', 'Complaint submitted', 'Submitted by Megha Joshi.', 'submit', '2026-10-16 10:00:00'),
  ('SF-1006', 'Staff assigned', 'Assigned to Vikram Desai (Infrastructure).', 'assign', '2026-10-16 10:30:00'),
  ('SF-1007', 'Complaint submitted', 'Submitted by Arjun Reddy. Awaiting assignment.', 'submit', '2026-10-17 08:05:00')
ON CONFLICT DO NOTHING;

-- SEED: NOTIFICATIONS
INSERT INTO notifications (type, message, read, created_at) VALUES
  ('new_complaint', 'New complaint SF-1007 submitted (Fan making loud noise).', false, '2026-10-17 08:05:00'),
  ('awaiting_verification', 'Complaint SF-1004 is awaiting verification.', false, '2026-10-16 15:00:00'),
  ('awaiting_assignment', 'Complaint SF-1003 is awaiting staff assignment.', true, '2026-10-14 13:10:00')
ON CONFLICT DO NOTHING;

-- SEED: ACTIVITY LOG
INSERT INTO activity_log (action, admin, created_at) VALUES
  ('Verified resolution for SF-1001', 'Admin', '2026-09-30 11:00:00'),
  ('Assigned SF-1004 to Priya Nair', 'Admin', '2026-10-15 09:30:00'),
  ('Assigned SF-1006 to Vikram Desai', 'Admin', '2026-10-16 10:30:00'),
  ('Reviewed new complaint SF-1007', 'Admin', '2026-10-17 08:10:00')
ON CONFLICT DO NOTHING;
