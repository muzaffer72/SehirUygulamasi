// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/**
 * Flutter loader for web applications.
 */

'use strict';

/**
 * The name of the object containing the Flutter app.
 */
const _flutter = '_flutter';

/**
 * Alias for document.getElementById.
 */
const getDOMElement = id => document.getElementById(id);

const flutterJSPath = 'flutter_bootstrap.js';

/**
 * Auto-detects the baseUrl from which the current script is imported.
 * See: https://stackoverflow.com/a/17753525
 */
const getBaseUrl = () => {
  // The document creates the element running this script.
  const script = document.currentScript;
  // Load the script in a worker, where document.currentScript is null.
  if (script == null) {
    return '';
  }
  const fullUrl = script.src;
  return fullUrl.substring(0, fullUrl.lastIndexOf('/') + 1);
};

/**
 * Creates a configuration object for the Flutter JS entry point.
 * See: https://github.com/flutter/engine/blob/main/lib/web_ui/lib/src/engine/initialization.dart
 */
function createConfig(baseUrl, entrypoint, onEntrypointLoaded, serviceWorkerSettings, serviceWorkerVersion) {
  // A unique identifier for this entrypoint, used to disambiguate different
  // instances of a Flutter app.
  const identifier = Math.random().toString(16).slice(2);

  // The "loading" phase is its own critical path, where performance benchmarking
  // should be done carefully.
  const beforeLoading = window.performance.now();
  const didCreateEngineInitializer = engineInitializer => {
    if (window.console) {
      console.log(`Time to create engine initializer: ${window.performance.now() - beforeLoading} ms`);
    }
    window.performance.mark('bootstrapFinished');
    onEntrypointLoaded(engineInitializer);
  };

  const config = {
    entrypointUrl: baseUrl + entrypoint,
    canvasKitBaseUrl: baseUrl + 'canvaskit/',
    canvasKitVariant: 'auto',
    onEntrypointLoaded: didCreateEngineInitializer
  };

  // Register the service worker.
  if (serviceWorkerSettings && serviceWorkerVersion) {
    // The settings might have been provided by the developer, or by the
    // flutter tool. The latter doesn't know where the service worker lives.
    // Normalize the settings to work regardless of how they're provided.

    // In most cases the serviceWorker.url is provided by the developer
    // (they also may be using an absolute url).
    let serviceWorkerUrl = serviceWorkerSettings.serviceWorkerUrl;
    if (!serviceWorkerUrl) {
      // If serviceWorkerUrl is not provided, assume it lives next to the
      // flutter_bootstrap.js file. The name "flutter_service_worker.js" is
      // hard-coded by the flutter tool.
      serviceWorkerUrl = baseUrl + 'flutter_service_worker.js';
    }
    // Normalize the serviceWorkerVersion by adding a query parameter so the
    // browser can bust the service worker cache.
    if (serviceWorkerUrl.indexOf('?v=') < 0 && serviceWorkerUrl.indexOf('&v=') < 0) {
      serviceWorkerUrl = serviceWorkerUrl + '?v=' + serviceWorkerVersion;
    }
    config.serviceWorkerUrl = serviceWorkerUrl;
    config.serviceWorkerVersion = serviceWorkerVersion;
    config.serviceWorkerScope = serviceWorkerSettings.serviceWorkerScope;
  }

  window.performance.mark('bootstrapWillStart');
  return config;
}

function addModule(config) {
  const script = document.createElement('script');
  script.type = 'text/javascript';
  script.async = true;
  script.defer = true;
  // All our different types of bootstrap.js fetch the config via
  // globalThis._flutter
  script.src = config.entrypointUrl;
  document.body.append(script);
}

function removeBaseElement(baseEl) {
  if (baseEl) {
    document.head.removeChild(baseEl);
  }
}

// Initializes and loads the Flutter web application.
function loadEntrypoint(options) {
  let entrypoint = options.entrypoint || 'main.dart.js';
  let serviceWorkerSettings = options.serviceWorker;
  let serviceWorkerVersion = serviceWorkerSettings ? serviceWorkerSettings.serviceWorkerVersion : null;
  let baseUrl = options.baseUrl || getBaseUrl();

  // Set this early so other code can respond to failures below.
  window[_flutter] = Object.assign(window[_flutter] || {}, {
    buildConfig: { baseUrl: baseUrl },
    entrypointUrl: baseUrl + entrypoint,
  });

  // If serviceWorkerVersion is provided, we're in DWDS. In that case, if the requested
  // version differs from the current version, we must reload the page.
  // This prevents a DWDS race condition bug: When an app is rebuilt, a new service
  // worker is started, and then the old app code would try to load from that new worker
  // which was already running and caching the new code. We know the code is old by
  // comparing the stored serviceWorkerVersion with the requested one.
  if (serviceWorkerVersion) {
    const scriptTag = document.createElement('script');
    const lastScript = document.scripts[document.scripts.length - 1];
    scriptTag.src = `${baseUrl}flutter_bootstrap.js`;
    // Add a custom attribute just to make it easier to find in devtools.
    scriptTag.setAttribute('entrypoint', entrypoint);
    scriptTag.onload = () => {
      global.flutterConfiguration = {canvasKitBaseUrl: `${baseUrl}canvaskit/`};
      window[_flutter].loader.loadEntrypoint({
        entrypoint,
        onEntrypointLoaded: options.onEntrypointLoaded,
        serviceWorker: serviceWorkerSettings,
      });
    };
    // The umd loader creates a bunch of defines with the current script, so
    // setting the id makes sure they don't get overwritten when a new loader
    // is added.
    scriptTag.id = "flutter_bootstrap";
    lastScript.parentNode.insertBefore(scriptTag, lastScript.nextSibling);

    return;
  }

  try {
    const baseEl = document.createElement('base');
    baseEl.href = baseUrl;
    document.head.insertBefore(baseEl, document.currentScript);

    // Our code makes the following assumptions:
    // - It's running in a browser
    // - The script was loaded with a script tag that contains the attribute, 'src'
    // - The script was loaded from a known URL
    if (!document.currentScript) {
      options.onError('Error: Flutter could not resolve the script source. This can happen if you are using a relative script path.');
      return;
    }

    if (!('src' in document.currentScript) || document.currentScript.src == null) {
      options.onError('Error: Flutter could not resolve the script source. Please check that the script has a valid src attribute.');
      return;
    }

    // Create the Flutter JS Bootstrap and load it.
    let config = createConfig(baseUrl, entrypoint, options.onEntrypointLoaded, serviceWorkerSettings, serviceWorkerVersion);
    config.assetBase = baseUrl;
    window[_flutter] = config;

    // Make the config available globally, through multiple paths.
    window[_flutter] = window[_flutter] || {};
    window[_flutter].loader = window[_flutter].loader || {};
    window[_flutter].loader.load = config => {
      try {
        removeBaseElement(baseEl);
        addModule(config);
      } catch (e) {
        options.onError(e);
      }
    };

    removeBaseElement(baseEl);

    // Load the bootstrap script that ultimately resolves user's Flutter app.
    window[_flutter].loader.load(config);
  } catch (e) {
    options.onError(e);
  }
}

// To support Flutter apps that want to load from a relative path,
// (e.g. <script src="main.dart.js>"), we need our own standardized
// "main.dart.js", which can be optionally used as a convenience.
// The default Flutter-generated "main.dart.js" always needs an
// absolute path.
// 
// Developers using their own non-standard entry point names, or who don't
// want to use the standardized loader formats at all, can always call
// loadEntrypoint directly themselves, to configure how they want to load
// their Flutter app.
//
// We'll add all this code to window._flutter automatically.
window[_flutter] = window[_flutter] || {};
window[_flutter].loader = window[_flutter].loader || {};
window[_flutter].loader.loadEntrypoint = loadEntrypoint;