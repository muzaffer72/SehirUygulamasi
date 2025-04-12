/**
 * ŞikayetVar Admin Panel - Anket Demo Verileri
 * Bu script, uygulama ilk kurulduğunda örnek anket verilerini ekler
 */

document.addEventListener('DOMContentLoaded', function() {
    // Sayfa yüklendiğinde demo anket verilerinin yüklenmesini kontrol et
    checkSurveyCount();
});

/**
 * Veritabanındaki anket sayısını kontrol eder ve gerekirse demo verileri ekler
 */
function checkSurveyCount() {
    // Sadece anket sayfasında çalıştır (URL içinde "page=surveys" varsa)
    if (!window.location.href.includes('page=surveys')) {
        return;
    }
    
    // localStorage kontrol et - daha önce çalıştırıldı mı?
    if (localStorage.getItem('demoSurveysChecked')) {
        return;
    }
    
    console.log("Demo anketler ekleniyor...");
    
    // Veritabanında anket tablosu var mı kontrol et
    executeSQL("SELECT COUNT(*) as count FROM surveys")
        .then(data => {
            if (data && data.rows && data.rows[0] && data.rows[0].count == 0) {
                addDemoSurveys();
            }
            // Kontrolü tamamlandı olarak işaretle
            localStorage.setItem('demoSurveysChecked', 'true');
        })
        .catch(error => {
            // Tablo yok, önce tabloları oluştur sonra demo verileri ekle
            createSurveyTablesIfNotExist()
                .then(() => {
                    addDemoSurveys();
                    // Kontrolü tamamlandı olarak işaretle
                    localStorage.setItem('demoSurveysChecked', 'true');
                })
                .catch(error => {
                    console.error("Anket tabloları oluşturulamadı:", error);
                });
        });
}

/**
 * SQL komutlarını çalıştırmak için yardımcı fonksiyon
 */
function executeSQL(query, params = []) {
    return new Promise((resolve, reject) => {
        fetch('/api/execute_sql.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                query: query,
                params: params
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                console.error("SQL çalıştırılırken hata:", data.error);
                reject(data.error);
            } else {
                resolve(data);
            }
        })
        .catch(error => {
            console.error("Fetch hatası:", error);
            reject(error);
        });
    });
}

/**
 * Anket tablolarını oluşturur (eğer yoksa)
 */
function createSurveyTablesIfNotExist() {
    return new Promise((resolve, reject) => {
        // Bu noktada tablolar zaten oluşturulmuş olacak, bu yüzden direkt çözümlüyoruz
        resolve();
    });
}

/**
 * Demo anketleri ekler
 */
function addDemoSurveys() {
    // Var olan anketleri kontrol et
    getExistingSurveys()
        .then(existingSurveys => {
            // Demo anketleri ekle
            insertDemoSurveys(existingSurveys);
        })
        .catch(error => {
            console.error("Anketler kontrol edilirken hata:", error);
        });
}

/**
 * Veritabanında var olan anketleri getirir
 */
function getExistingSurveys() {
    return new Promise((resolve, reject) => {
        const existingSurveys = [];
        
        // Var olan anketleri başlıklarına göre kontrol et
        const demoSurveyTitles = [
            "Şehir İçi Ulaşım Memnuniyeti",
            "Belediye Hizmetleri Değerlendirme",
            "Çevre Temizliği ve Atık Yönetimi",
            "Kültür ve Sanat Etkinlikleri",
            "Sokak Hayvanları Politikası"
        ];
        
        let completedChecks = 0;
        
        demoSurveyTitles.forEach(title => {
            executeSQL("SELECT id FROM surveys WHERE title = ?", [title])
                .then(data => {
                    if (data && data.rows && data.rows.length > 0) {
                        existingSurveys.push(title);
                    }
                    
                    completedChecks++;
                    if (completedChecks === demoSurveyTitles.length) {
                        resolve(existingSurveys);
                    }
                })
                .catch(error => {
                    completedChecks++;
                    console.error(`'${title}' anketi kontrol edilirken hata:`, error);
                    
                    if (completedChecks === demoSurveyTitles.length) {
                        resolve(existingSurveys);
                    }
                });
        });
    });
}

/**
 * Demo anketleri veritabanına ekler
 */
function insertDemoSurveys(existingSurveys) {
    const today = new Date();
    const nextMonth = new Date();
    nextMonth.setMonth(nextMonth.getMonth() + 1);
    
    const defaultCategoryId = 3; // Ulaşım kategorisi
    
    const demoSurveys = [
        {
            title: "Şehir İçi Ulaşım Memnuniyeti",
            short_title: "Ulaşım Anketi",
            description: "Bu anket, şehirdeki toplu taşıma ve ulaşım hizmetleri hakkında vatandaş memnuniyetini ölçmek için hazırlanmıştır.",
            category_id: 3, // Ulaşım
            scope_type: "general",
            start_date: formatDate(today),
            end_date: formatDate(nextMonth),
            total_users: 5000,
            is_active: true,
            options: [
                "Çok memnunum",
                "Memnunum",
                "Kararsızım",
                "Memnun değilim",
                "Hiç memnun değilim"
            ]
        },
        {
            title: "Belediye Hizmetleri Değerlendirme",
            short_title: "Belediye Hizmetleri",
            description: "Belediyenin sunduğu hizmetlerden memnuniyet düzeyinizi belirtiniz.",
            category_id: 10, // Diğer
            scope_type: "city",
            city_id: 34, // İstanbul
            start_date: formatDate(today),
            end_date: formatDate(nextMonth),
            total_users: 3000,
            is_active: true,
            options: [
                "Çok iyi",
                "İyi",
                "Ortalama",
                "Kötü",
                "Çok kötü"
            ]
        },
        {
            title: "Çevre Temizliği ve Atık Yönetimi",
            short_title: "Çevre Temizliği",
            description: "Yaşadığınız bölgede çevre temizliği ve atık yönetimi hakkındaki düşünceleriniz nelerdir?",
            category_id: 2, // Çevre
            scope_type: "district",
            city_id: 34, // İstanbul
            district_id: 1, // Örnek ilçe ID'si
            start_date: formatDate(today),
            end_date: formatDate(nextMonth),
            total_users: 2000,
            is_active: true,
            options: [
                "Çok temiz ve düzenli",
                "Yeterince temiz",
                "Bazen sorunlar yaşanıyor",
                "Genellikle kirli",
                "Çok kirli ve düzensiz"
            ]
        },
        {
            title: "Kültür ve Sanat Etkinlikleri",
            short_title: "Kültür-Sanat",
            description: "Şehrinizde düzenlenen kültür ve sanat etkinlikleri hakkında ne düşünüyorsunuz?",
            category_id: 8, // Kültür ve Sanat
            scope_type: "city",
            city_id: 6, // Ankara
            start_date: formatDate(today),
            end_date: formatDate(nextMonth),
            total_users: 1500,
            is_active: false,
            options: [
                "Çok çeşitli ve yeterli",
                "Yeterli sayıda ama çeşitlilik az",
                "Yetersiz ama kaliteli",
                "Hem sayıca hem kalite açısından yetersiz"
            ]
        },
        {
            title: "Sokak Hayvanları Politikası",
            short_title: "Sokak Hayvanları",
            description: "Sokak hayvanlarına yönelik belediye politikalarını nasıl değerlendiriyorsunuz?",
            category_id: 10, // Diğer
            scope_type: "general",
            start_date: formatDate(today),
            end_date: formatDate(nextMonth),
            total_users: 4000,
            is_active: true,
            options: [
                "Çok başarılı buluyorum",
                "Yeterli buluyorum",
                "Kısmen yeterli buluyorum",
                "Yetersiz buluyorum",
                "Çok başarısız buluyorum"
            ]
        }
    ];
    
    // Her bir demo anketi kontrol et ve ekle
    demoSurveys.forEach(survey => {
        // Bu anket zaten var mı kontrol et
        if (existingSurveys.includes(survey.title)) {
            return; // Zaten var, sonraki ankete geç
        }
        
        // Anketi ekle
        executeSQL(`
            INSERT INTO surveys 
                (title, short_title, description, category_id, scope_type, city_id, district_id, start_date, end_date, total_users, is_active)
            VALUES 
                (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            RETURNING id
        `, [
            survey.title,
            survey.short_title,
            survey.description,
            survey.category_id,
            survey.scope_type,
            survey.city_id || null,
            survey.district_id || null,
            survey.start_date,
            survey.end_date,
            survey.total_users,
            survey.is_active
        ])
        .then(data => {
            if (data && data.rows && data.rows.length > 0) {
                const surveyId = data.rows[0].id;
                
                // Anket seçeneklerini ekle
                survey.options.forEach((optionText, index) => {
                    // Varsayılan oy sayısı (rastgele)
                    const voteCount = Math.floor(Math.random() * 100);
                    
                    executeSQL(`
                        INSERT INTO survey_options (survey_id, text, vote_count)
                        VALUES (?, ?, ?)
                    `, [surveyId, optionText, voteCount])
                    .catch(error => {
                        console.error(`Anket seçeneği eklenirken hata (${surveyId}):`, error);
                    });
                });
            }
        })
        .catch(error => {
            console.error(`'${survey.title}' anketi eklenirken hata:`, error);
        });
    });
}

/**
 * Tarihi YYYY-MM-DD formatına dönüştürür
 */
function formatDate(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}