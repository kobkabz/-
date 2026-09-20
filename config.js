// ==== แก้ไข 2 บรรทัดนี้ให้เป็นค่าโปรเจกต์ Supabase ของคุณ ====
// หาได้จาก Supabase Dashboard > Project Settings > API
export const SUPABASE_URL = "https://eoceujniqkdfeadelyfl.supabase.co";
export const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvY2V1am5pcWtkZmVhZGVseWZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk4ODM3MzgsImV4cCI6MjEwNTQ1OTczOH0.8u72SA5UU4hxtudWnFuG948vNe3IMsJrkXMSwmJa_5M";
// ==========================================================

// โดเมนอีเมลปลอมที่ใช้แปลง "ชื่อผู้ใช้" ให้เป็นอีเมลสำหรับ Supabase Auth
// (ไม่ต้องแก้ ยกเว้นต้องการเปลี่ยน)
export const FAKE_EMAIL_DOMAIN = "auth.local";

export function usernameToEmail(username){
  return `${username.trim().toLowerCase()}@${FAKE_EMAIL_DOMAIN}`;
}
