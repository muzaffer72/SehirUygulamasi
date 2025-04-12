/* Flutter web yükleyici - 2.16.1 */
'use strict';

/**
 * This file is the entry point for the Flutter app when it's running in a web
 * browser.
 *
 * This code handles loading the Flutter app's compiled JavaScript, and calling
 * the app's main entrypoint function.
 */

/**
 * The element to display while the app is loading.
 * @type {Element}
 */
const loader = document.querySelector('#loading');

/**
 * The main entrypoint for the Flutter app.
 * @type {string}
 */
const entrypointUrl = 'main.dart.js';

/**
 * A global object to track initialization, and provide facilities to register
 * Flutter web plugins.
 * @type {Object}
 */
window._flutter = window._flutter || {};

/**
 * Set up the Flutter bootstrapping code.
 */
(function() {
  // Set up the global _flutter object with required parts.
  window._flutter.loader = window._flutter.loader || {};
  
  // Set build configuration as an early initialization step.
  window._flutter.buildMode = 'debug';
  window._flutter.buildConfig = window._flutter.buildConfig || {
    canvasKitBaseUrl: '/canvaskit/',
    canvasKitVariant: 'auto'
  };
  
  // Define common functions and callbacks.
  const appStarted = () => {
    if (loader) {
      loader.remove();
    }
  };
  
  const appFailed = (error) => {
    console.error('Flutter app initialization failed:', error);
    if (loader) {
      loader.innerHTML = `
        <div style="color: red; text-align: center; padding: 20px;">
          <p>Uygulama yüklenemedi</p>
          <p style="font-size: 12px;">Detaylar: ${error}</p>
        </div>
      `;
    }
  };
  
  // Set up the loader to call the main entrypoint.
  window._flutter.loader.loadEntrypoint = function(options) {
    try {
      // Create a script tag to load the main entrypoint.
      const scriptTag = document.createElement('script');
      scriptTag.src = entrypointUrl;
      scriptTag.type = 'text/javascript';
      scriptTag.addEventListener('load', function() {
        // Script loaded, notify user app is ready.
        if (window.console) {
          console.log('Flutter app loaded successfully!');
        }
      });
      scriptTag.addEventListener('error', function(e) {
        appFailed(e);
      });
      
      // Add the script tag to the body.
      document.body.appendChild(scriptTag);
    } catch (e) {
      appFailed(e);
    }
  };
  
  // Simplified load method for direct bootstrap.
  window._flutter.loader.load = function() {
    window._flutter.loader.loadEntrypoint({});
  };
})();