// API yardımcı fonksiyonları - Web platformuna özel JS kodları
// Bu dosya, dart:html gibi web platformuna özel kodları içerir
// Bu sayede Android gibi mobil platformlarda dart:html importu hataları önlenir

// Web URL bilgilerini alan JS fonksiyonu
function getApiBaseUrl() {
  const protocol = window.location.protocol; // "http:" veya "https:"
  const hostname = window.location.hostname; // "domain.com" veya "localhost"
  
  // API proxy 9000 portundan yayınlanıyor
  return `${protocol}//${hostname}:9000`;
}

// Flutter tarafından çağrılacak köprü fonksiyonu
function getWebApiBaseUrl() {
  return getApiBaseUrl();
}

// Flutter ile köprü oluşturma
if (window.flutter_inappwebview) {
  window.flutter_inappwebview.callHandler('getWebApiBaseUrl', getWebApiBaseUrl());
}