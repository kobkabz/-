-- ==========================================================
-- Answer Sheet Studio — Supabase schema
-- รันไฟล์นี้ใน Supabase Dashboard > SQL Editor (ครั้งเดียวตอนตั้งระบบ)
-- ==========================================================

-- 1) โปรไฟล์ผู้ใช้ (ครู/แอดมิน) — เชื่อมกับ auth.users
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text,
  role text not null default 'teacher' check (role in ('admin','teacher')),
  created_at timestamptz default now()
);

-- 2) ทะเบียนนักเรียนทั้งโรงเรียน (แอดมินนำเข้า/แก้ไข)
create table if not exists students (
  id bigint generated always as identity primary key,
  class_name text not null,
  seat_no int not null,
  full_name text not null,
  unique(class_name, seat_no)
);

-- 3) ข้อสอบที่ครูสร้าง
create table if not exists exams (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid references auth.users(id) not null,
  title text not null,
  class_name text,
  num_questions int not null,
  num_choices int not null default 4,
  answer_key jsonb not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 4) ผลคะแนนของนักเรียนแต่ละคนต่อข้อสอบหนึ่งชุด
create table if not exists exam_results (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid references exams(id) on delete cascade not null,
  teacher_id uuid references auth.users(id) not null,
  class_name text,
  seat_no int,
  student_name text not null,
  score int not null,
  total int not null,
  answers jsonb not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ================= ROW LEVEL SECURITY =================

alter table profiles enable row level security;
alter table students enable row level security;
alter table exams enable row level security;
alter table exam_results enable row level security;

-- profiles: ทุกคนที่ล็อกอินแล้วอ่านโปรไฟล์ตัวเองได้ / แอดมินอ่านได้ทุกคน
create policy "read own profile" on profiles
  for select using (auth.uid() = id);

create policy "admin read all profiles" on profiles
  for select using (
    exists (select 1 from profiles p where p.id = auth.uid() and p.role = 'admin')
  );

-- students: ครู/แอดมินที่ล็อกอินแล้วอ่านได้ทุกคน (ใช้ค้นชื่อจากเลขที่)
create policy "authenticated read students" on students
  for select using (auth.role() = 'authenticated');

-- exams: ครูเห็น/แก้ไขได้เฉพาะของตัวเอง
create policy "teacher manage own exams" on exams
  for all using (auth.uid() = teacher_id) with check (auth.uid() = teacher_id);

-- exam_results: ครูเห็น/แก้ไขได้เฉพาะของตัวเอง
create policy "teacher manage own results" on exam_results
  for all using (auth.uid() = teacher_id) with check (auth.uid() = teacher_id);

-- ==========================================================
-- ขั้นตอนถัดไป (ทำใน Supabase Dashboard):
-- 1) Authentication > Providers > Email: ปิด "Allow new users to sign up"
--    (เพื่อไม่ให้ใครสมัครเองได้ ต้องให้แอดมินสร้างให้เท่านั้น)
-- 2) Authentication > Users > Add user: สร้างแอดมินคนแรกด้วยมือ
--    Email: admin@auth.local   Password: (ตั้งเอง)  ติ๊ก Auto Confirm User
-- 3) คัดลอก UUID ของ user ที่เพิ่งสร้าง แล้วรัน:
--    insert into profiles (id, username, display_name, role)
--    values ('<UUID ที่คัดลอกมา>', 'admin', 'ผู้ดูแลระบบ', 'admin');
-- 4) รันไฟล์ seed_students.sql เพื่อนำเข้ารายชื่อนักเรียน
-- ==========================================================
