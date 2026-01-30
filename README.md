# Firezone Self-Hosted VPN - 0.7.36

Bu proje, **Firezone 0.7.36** sürümünü kendi sunucularınızda **Docker ile self-hosted** olarak çalıştırmak için hazırlanmıştır.
Proje, kullanıcıların `.env` dosyasını kolayca oluşturmasını sağlayan bir **kurulum scripti** (`install.sh`) içerir ve gerekli Docker yapılandırmasını barındırır.

---

## Proje Görevleri

1. **PostgreSQL veritabanını çalıştırmak**
   Firezone veritabanı için gerekli tabloların oluşturulması ve yönetimi.

2. **.env dosyasını oluşturmak**
   Kullanıcıdan gerekli bilgiler alınarak (FIREZONE_SERVER_HOSTNAME, DEFAULT_ADMIN_EMAIL) ve diğer secret değerler otomatik üretilerek `.env` dosyası hazırlanır.

3. **Database migration ve admin hesabının oluşturulması**
   Firezone’un düzgün çalışabilmesi için gerekli migration’lar uygulanır ve admin hesabı oluşturulur.

4. **Firezone konteynerlerini başlatmak**
   Tüm servislerin Docker üzerinde ayağa kaldırılması.

---

## Gereksinimler

* Docker ≥ 24.0
* Docker Compose ≥ 2.0
* `.env.example` dosyası

---

## Kurulum Adımları

### 1️⃣ .env Dosyasını Oluşturma

Proje kök dizininde aşağıdaki komutu çalıştırın:

```bash
./install.sh
```

Script şunları yapar:

* `.env.example` dosyasını `.env` olarak kopyalar
* Kullanıcıdan:
    * `FIREZONE_SERVER_HOSTNAME` (örn: vpn.example.com)
    * `DEFAULT_ADMIN_EMAIL` (örn: [admin@example.com](mailto:admin@example.com)) bilgilerini ister
* `DEFAULT_ADMIN_PASSWORD` sorulur, boş bırakılırsa **12 karakterlik otomatik bir şifre** oluşturur
* Firezone’un çalışması için gerekli tüm **secret** değerleri otomatik üretilir
* `.env` dosyası güncellenir

Script çalışması sonunda ekranınıza EXTERNAL_URL, admin e-posta ve şifre bilgisi yazdırılır. ⚠️ Şifreyi güvenli bir yerde saklayın.

---

### 2️⃣ PostgreSQL Konteynerini Başlatma

Öncelikle yalnızca PostgreSQL konteynerini başlatın:

```bash
docker compose up -d postgres
```

> Firezone servislerinin başlamadan önce veritabanına erişebilmesi için bu adım kritik.

---

### 3️⃣ Database Migration ve Admin Hesabı Oluşturma

PostgreSQL çalıştıktan sonra sırasıyla şu komutları çalıştırın:

```bash
docker compose run --rm firezone bin/migrate
docker compose run --rm firezone bin/create-or-reset-admin
```

* `bin/migrate`: Firezone veritabanı tablolarını oluşturur / günceller
* `bin/create-or-reset-admin`: Admin hesabını oluşturur veya şifreyi resetler

---

### 4️⃣ Tüm Konteynerleri Başlatma

Migration ve admin oluşturma işlemleri tamamlandıktan sonra Firezone’u başlatın:

```bash
docker compose up -d
```

Tüm servisler ayağa kalkacak ve Web UI’ye **EXTERNAL_URL** üzerinden erişebilirsiniz.

---

## .env Dosyası Hakkında

* `FIREZONE_SERVER_HOSTNAME`: Sunucunuzun adresi (örn: vpn.example.com)
* `EXTERNAL_URL`: `https://` ile başlayan tam URL
* `DEFAULT_ADMIN_EMAIL` ve `DEFAULT_ADMIN_PASSWORD`: Admin giriş bilgileri
* Secret değerler (`GUARDIAN_SECRET_KEY`, `SECRET_KEY_BASE`, vb.) otomatik üretilir
* `DATABASE_*` değerleri Firezone’un PostgreSQL ile iletişimi için gereklidir

---

## Docker Servisleri

* **firezone**: VPN ve web arayüzü
* **postgres**: Firezone veritabanı
* (Opsiyonel) **traefik / reverse proxy**: EXTERNAL_URL yönlendirmesi için

---

## Öneriler

* Admin şifresini mutlaka güvenli bir yerde saklayın
* EXTERNAL_URL doğru tanımlanmalı, aksi takdirde login ve callback URL’leri çalışmaz
* Firezone ve PostgreSQL için persistent volume kullanmak önerilir

---

## Kaynaklar

* [Firezone GitHub](https://github.com/firezone/firezone)
* [Firezone Documentation](https://docs.firezone.dev/)
