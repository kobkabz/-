# ระบบตรวจข้อสอบปรนัย (Answer Sheet Studio)

เว็บแอปสำหรับครู: ตั้งเฉลย → พิมพ์กระดาษคำตอบ (มีชื่อนักเรียนในตัว) → สแกน/ถ่ายรูปตรวจอัตโนมัติ → สรุปผล
ระบบผู้ใช้: **แอดมินสร้างไอดีครูให้เท่านั้น ครูสมัครเองไม่ได้**

โครงสร้างเว็บเป็น **ไฟล์ static ล้วน** (ไม่มีขั้นตอน build) ใช้ Supabase เป็นฐานข้อมูล+ระบบล็อกอิน
Deploy ผ่าน GitHub + Netlify

```
index.html      → หน้าล็อกอิน
admin.html      → แผงแอดมิน (สร้างไอดีครู)
app.html        → แอปตรวจข้อสอบหลัก (สำหรับครู)
shared/         → CSS, Supabase client, config
supabase/       → schema.sql, seed_students.sql, Edge Function
netlify.toml    → ตั้งค่า deploy (ไม่มี build step)
```

---

## ขั้นตอนที่ 1 — สร้างโปรเจกต์ Supabase

1. ไปที่ [supabase.com](https://supabase.com) → สร้างบัญชี/ล็อกอิน → **New project**
2. ตั้งชื่อโปรเจกต์ เลือก region ที่ใกล้ (เช่น Singapore) ตั้งรหัสผ่านฐานข้อมูล แล้วรอสร้างเสร็จ (~2 นาที)
3. ไปที่ **SQL Editor** (เมนูซ้าย) → เปิดไฟล์ `supabase/schema.sql` ในโปรเจกต์นี้ → copy ทั้งหมดมาวางแล้วกด **Run**
4. เปิดไฟล์ `supabase/seed_students.sql` → copy มาวางใน SQL Editor → กด **Run** (นำเข้ารายชื่อนักเรียน 139 คน จาก 11 ชั้นเรียน)

## ขั้นตอนที่ 2 — ปิดการสมัครสมาชิกเอง + สร้างแอดมินคนแรก

1. ไปที่ **Authentication → Providers → Email** → ปิด (toggle off) **"Allow new users to sign up"** แล้วบันทึก
2. ไปที่ **Authentication → Users → Add user**
   - Email: `admin@auth.local`
   - Password: ตั้งรหัสผ่านของแอดมินเอง (จำไว้ให้ดี)
   - ติ๊ก **Auto Confirm User**
3. คลิกที่ user ที่เพิ่งสร้าง คัดลอกค่า **UUID** ของเขา
4. กลับไปที่ **SQL Editor** รันคำสั่ง (แทน UUID ด้วยค่าที่คัดลอกมา):
   ```sql
   insert into profiles (id, username, display_name, role)
   values ('วาง-UUID-ตรงนี้', 'admin', 'ผู้ดูแลระบบ', 'admin');
   ```
5. ตอนนี้ล็อกอินด้วย **username: admin** ได้แล้ว (ระบบแปลง username → email อัตโนมัติ)

## ขั้นตอนที่ 3 — Deploy Edge Function (สำหรับสร้างไอดีครู)

ต้องใช้ [Supabase CLI](https://supabase.com/docs/guides/cli):

```bash
npm install -g supabase
supabase login
cd โฟลเดอร์โปรเจกต์นี้
supabase link --project-ref YOUR_PROJECT_REF   # ดู project ref ได้จาก Settings > General
supabase functions deploy create-teacher
```

ไม่ต้องตั้งค่า secret เพิ่มเติม — Supabase ใส่ `SUPABASE_URL` และ `SUPABASE_SERVICE_ROLE_KEY` ให้ Edge Function โดยอัตโนมัติอยู่แล้ว

## ขั้นตอนที่ 4 — ใส่ค่า Supabase ในโค้ด

เปิดไฟล์ `shared/config.js` แก้ 2 บรรทัดแรกให้เป็นค่าโปรเจกต์คุณ (ดูได้ที่ **Settings → API**):

```js
export const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
export const SUPABASE_ANON_KEY = "eyJxxxxxxxxxxxxxxxxxxxx...";
```

> anon key เป็นคีย์สาธารณะ ใส่ในโค้ด frontend ได้ตามปกติ — ความปลอดภัยของข้อมูลถูกป้องกันด้วย Row Level Security (RLS) ที่ตั้งไว้ใน schema.sql แล้ว ไม่ใช่การซ่อนคีย์

## ขั้นตอนที่ 5 — Push ขึ้น GitHub

```bash
git init
git add .
git commit -m "answer sheet studio"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

## ขั้นตอนที่ 6 — Deploy บน Netlify

1. ไปที่ [netlify.com](https://netlify.com) → **Add new site → Import an existing project**
2. เชื่อมกับ GitHub แล้วเลือก repo นี้
3. Build settings: **ไม่ต้องใส่ build command**, Publish directory ใส่ `.` (repo root) — ไฟล์ `netlify.toml` ตั้งไว้ให้แล้ว
4. กด **Deploy** — เสร็จแล้วจะได้ URL เช่น `https://your-site.netlify.app`

## ขั้นตอนที่ 7 — ใช้งานจริง

1. เปิดเว็บ → ล็อกอินด้วย `admin` / รหัสผ่านที่ตั้งไว้ → เข้าหน้าแอดมินอัตโนมัติ
2. สร้างไอดีครู (ตั้งชื่อผู้ใช้ เช่น `teacher01`, `kruoy`, ฯลฯ + ตั้งรหัสผ่าน) แล้วแจ้งครูแต่ละคน
3. ครูล็อกอินด้วยชื่อผู้ใช้ที่ได้รับ → เข้าใช้แอปตรวจข้อสอบตามปกติ (4 ขั้นตอนเดิม) ข้อมูลทุกอย่างผูกกับบัญชีของครูแต่ละคน ไม่ปนกัน

---

## หมายเหตุเรื่องความปลอดภัย

- ครูแต่ละคนเห็น/แก้ไขได้เฉพาะข้อสอบและผลคะแนนของตัวเอง (บังคับด้วย RLS ในฐานข้อมูล ไม่ใช่แค่ซ่อนใน UI)
- ทะเบียนนักเรียน (`students`) ครูทุกคนที่ล็อกอินแล้วอ่านได้หมดทุกชั้น (ใช้ค้นชื่อจากเลขที่) แต่แก้ไข/เพิ่มได้เฉพาะผ่าน SQL Editor หรือเพิ่มฟีเจอร์ import ในหน้าแอดมินภายหลัง
- การสร้างไอดีครูทำได้เฉพาะผ่านแอดมิน (ปุ่มสมัครเองไม่มีในระบบ และ Edge Function ตรวจ role=admin ก่อนทุกครั้ง)
- อยากรีเซ็ตรหัสผ่านครู: ทำได้ใน Supabase Dashboard → Authentication → Users → เลือกครูคนนั้น → Reset password

## ถ้าอยากปรับเพิ่มภายหลัง

- เพิ่มหน้า "นำเข้ารายชื่อนักเรียน" ในแผงแอดมิน (อัปโหลด Excel/CSV) แทนการรัน SQL มือ
- ให้ครูดูข้อสอบของครูคนอื่นได้ (เช่น หัวหน้ากลุ่มสาระ) — ต้องปรับ RLS policy เพิ่ม
- แจ้งเตือนอีเมล/LINE เมื่อมีการบันทึกผลคะแนนใหม่
