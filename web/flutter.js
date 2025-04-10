/**
 * Flutter'ın resmi web starter şablonundan uyarlanmıştır.
 * Daha basit ve daha güvenilir bir yapılandırma sağlar.
 */

'use strict';

/**
 * Flutter uygulamasının yüklendiği global nesne
 */
var _flutter = '_flutter';

/**
 * Temel URL'yi belirle
 */
function getBaseUrl() {
  // Get the URL from the script's location
  const scripts = document.getElementsByTagName('script');
  for (let i = 0; i < scripts.length; i++) {
    if (scripts[i].src.indexOf('flutter.js') !== -1) {
      const url = scripts[i].src;
      return url.substring(0, url.lastIndexOf('/') + 1);
    }
  }
  return './';
}

/**
 * Güvenli şekilde global Flutter yapılandırmasını oluştur 
 */
function initializeFlutterConfig() {
  // Make sure _flutter object exists and has proper structures
  if (typeof window[_flutter] === 'undefined') {
    window[_flutter] = {};
  }
  
  // Loader function
  if (typeof window[_flutter].loader === 'undefined') {
    window[_flutter].loader = {};
  }
  
  // Always set a buildConfig
  if (typeof window[_flutter].buildConfig === 'undefined') {
    window[_flutter].buildConfig = {
      canvasKitBaseUrl: "/canvaskit/",
      useColorEmoji: true
    };
  }
}

/**
 * Flutter'ı yüklemek için ana fonksiyon
 */
function load(options) {
  // Initialize Flutter configuration 
  initializeFlutterConfig();
  
  try {
    // Default options
    options = options || {};
    const entrypoint = options.entrypoint || 'main.dart.js';
    const serviceWorker = options.serviceWorker;
    const onEntrypointLoaded = options.onEntrypointLoaded || function(){};
    const baseUrl = options.baseUrl || getBaseUrl();
    
    // Update buildConfig with baseUrl
    window[_flutter].buildConfig.baseUrl = baseUrl;
    
    // Create script element to load main.dart.js
    const script = document.createElement('script');
    script.src = baseUrl + entrypoint;
    script.type = 'text/javascript';
    
    // When the script is loaded, it will automatically call
    // the entrypoint loader function with engineInitializer
    script.onload = function() {
      console.log('Flutter script loaded successfully');
    };
    
    // Append to document
    document.body.appendChild(script);
    
  } catch (error) {
    console.error('Error loading Flutter application:', error);
    
    // Try to show error on page
    const errorDiv = document.createElement('div');
    errorDiv.innerHTML = 'Failed to load Flutter application. Check console for details.';
    errorDiv.style.color = 'red';
    errorDiv.style.padding = '20px';
    errorDiv.style.fontFamily = 'sans-serif';
    document.body.appendChild(errorDiv);
  }
}

// Make sure global _flutter object is initialized
window[_flutter] = window[_flutter] || {};
window[_flutter].loader = window[_flutter].loader || {};

// Define the load function that will be called from index.html
window[_flutter].loader.load = load;