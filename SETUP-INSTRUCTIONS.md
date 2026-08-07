# Darzi Khata — Poora Platform Setup Guide

Ye poora system 6 files se bana hai:
- `index.html` — Entry page (role select, signup/login)
- `shop.html` — Shop owner dashboard
- `worker.html` — Worker dashboard
- `admin.html` — Aapka (founder) admin dashboard
- `terms.html` — Terms & Conditions
- `config.js` + `styles.css` — Shared settings/design (sab files inhe use karte hain)

**Zaroori:** Sab files **ek hi folder/repository** mein hone chahiye (alag-alag nahi), warna links kaam nahi karenge.

---

## Step 1: Supabase Account Banayein

1. https://supabase.com → Sign up → **New Project** banayein
2. Database password yaad rakhein
3. Project ready hone tak wait karein (1-2 min)

---

## Step 2: Database Setup

1. Supabase dashboard → **SQL Editor** → **New query**
2. `schema.sql` file poori copy karke paste karein
3. **IMPORTANT:** Paste karne se pehle, is file mein har jagah `YOUR_ADMIN_EMAIL` ko apni **asli email** se replace karein (5 jagah hai — Ctrl+H se find-replace kar lein)
4. **Run** dabayein

---

## Step 3: Storage Buckets Banayein

Sidebar → **Storage** → 3 buckets banayein (har ek **Public** ON karke):
1. `face-photos`
2. `design-photos`
3. `logos`

Har bucket ke liye Policies mein ye 2 rules add karein (SQL Editor se bhi chal sakta hai, bucket ka naam badal kar teeno ke liye run karein):

```sql
create policy "Auth users can upload to face-photos"
on storage.objects for insert to authenticated
with check (bucket_id = 'face-photos');

create policy "Public can view face-photos"
on storage.objects for select to public
using (bucket_id = 'face-photos');
```
(Isi tarah `design-photos` aur `logos` ke liye bhi dohrayein, bucket_id badal kar)

---

## Step 4: Email Auth Confirm Karein

**Authentication → Providers** mein Email ON hona chahiye (default hota hai).
Testing ke liye **Authentication → Settings** mein "Confirm email" OFF kar sakte hain (production mein ON rakhna behtar hai).

---

## Step 5: API Keys Nikalein

**Project Settings → API** se:
- **Project URL**
- **anon public key**

---

## Step 6: config.js Update Karein

`config.js` file kholein, ye 3 lines update karein:

```js
export const SUPABASE_URL = "https://xxxxx.supabase.co";
export const SUPABASE_ANON_KEY = "eyJhbGc...";
export const ADMIN_EMAIL = "aapka-email@example.com";
```

**Ye ADMIN_EMAIL wahi hona chahiye jo Step 2 mein SQL mein daala tha, aur wahi jis se aap khud signup karenge.**

---

## Step 7: GitHub Pe Upload Karein

1. Naya **Public** repository banayein (e.g. `darzi-khata`)
2. In sab files ko upload karein: `index.html`, `shop.html`, `worker.html`, `admin.html`, `terms.html`, `config.js`, `styles.css`
3. Commit karein

---

## Step 8: GitHub Pages Se Live Karein

1. Repository → **Settings → Pages**
2. Source: "Deploy from a branch" → Branch: `main`, folder `/root` → Save
3. 1-2 min baad live: `https://<username>.github.io/<repo-naam>/`

---

## Step 9: Apna Admin Account Banayein

1. Live website kholein
2. **Sign Up** karein — **wahi email use karein jo config.js aur SQL mein ADMIN_EMAIL rakha tha**
3. Role kuch bhi select karein (shop/worker) — system automatically pehchan lega ke ye admin email hai aur seedha **Admin Dashboard** khol dega login ke baad

---

## Kaise Kaam Karta Hai (Summary)

- **Shop Owner:** Sign up → 30 din free trial → customers manage kare (apni marzi ke measurement fields ke sath) → trial khatam hone pe payment screen aa jayegi
- **Worker:** Sign up → free → profile banaye → active shops dhoonde ya khud shops dhoondein unhe
- **Aap (Admin):** Apni email se login → sab shops/workers dekhein, payments verify karein, reports handle karein, kisi ko block karein (CNIC bhi block ho jata hai dobara account na bana sake)

---

## Aage Kya Add Ho Sakta Hai (jab chahein)

- Real phone OTP verification (Twilio account chahiye hoga, paid per-SMS)
- NADRA CNIC verification (paid, business documents chahiye)
- Automated payment gateway (Safepay/PayFast) — abhi manual hai
- Apna logo — abhi ek simple thread-spool icon hai, apna design PNG bana kar `logos` bucket mein daal kar سب jagah use kar sakte hain

Kisi bhi step pe atkein to bataiye.
