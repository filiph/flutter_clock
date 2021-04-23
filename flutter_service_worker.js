'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "6e5a49adf49b1004cfdf19f31316272e",
"index.html": "4d0a60bfe440ad583a7f7a672ae6fee9",
"/": "4d0a60bfe440ad583a7f7a672ae6fee9",
"main.dart.js": "5da85a0daa08220a985a825573207194",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "2e20e87b51b288c9fb27ef15eb6e89ea",
"assets/AssetManifest.json": "9fb13da019cde50cd2a097a4494a8a5f",
"assets/NOTICES": "88048427943df623b9e572f25e6ad6d8",
"assets/FontManifest.json": "fb5f04542ca8d51d2515870e99060f14",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/assets/fonts/Source_Code_Pro/SourceCodePro-Regular.ttf": "b484b32fcec981a533e3b9694953103b",
"assets/assets/fortunes/computers": "4987e3b5de24354452a2dec623968f6d",
"assets/assets/fortunes/riddles": "16a44a74bdc0dc16365f8c08b1ec1941",
"assets/assets/fortunes/men-women": "5241617ba473682ec08e45cfd86495d6",
"assets/assets/fortunes/literature": "447862e1de4765f92cda585503d349e3",
"assets/assets/fortunes/love": "2e8def0cf5583bf0163b678256c3bdc2",
"assets/assets/fortunes/magic": "e1dd06a899c50bfb920366cd2efb43f0",
"assets/assets/fortunes/linuxcookie": "5fbf8c5aa9176902a14ecc601753d1da",
"assets/assets/fortunes/drugs": "dd9df31a0ba092dbb0c907a4f7947e4e",
"assets/assets/fortunes/pets": "f7235b0d73172e21e5f3ab8f5b9452d1",
"assets/assets/fortunes/art": "5fbee66aa2ed37b53e85884860ad39ba",
"assets/assets/fortunes/law": "eda9b9521a5fccf40a1660855ba39e6b",
"assets/assets/fortunes/goedel": "6b4077b82069fe6506ead822a099c9a4",
"assets/assets/fortunes/education": "36653bf433679950220b4996104efff2",
"assets/assets/fortunes/ethnic": "c583b531c5a0571c958dcaa1a8f1b716",
"assets/assets/fortunes/science": "3cb948982212bd22b262e6fe1903066f",
"assets/assets/fortunes/ascii-art": "b059c3db2c7184fb39d6475b6ab15fb9",
"assets/assets/fortunes/miscellaneous": "79cd4089a765a081ce466db600220b22",
"assets/assets/fortunes/sports": "0e421d76cc6f41d221521e348823cc79",
"assets/assets/fortunes/README.md": "84415407027d78e97208dafe2099cba9",
"assets/assets/fortunes/zippy": "77750a52e9ca4e3f07b0d1560162781d",
"assets/assets/fortunes/politics": "b8e1bee9a37b8a69f8105e6d253c222b",
"assets/assets/fortunes/startrek": "2d7a8c8f4b7797f2e6ee9b3c172b8b80",
"assets/assets/fortunes/wisdom": "732377e250bd54f7da72f721100f4a79",
"assets/assets/fortunes/news": "08467d181c962caea0c04c4da98d3803",
"assets/assets/fortunes/work": "c2ff224324834196f8f4eff049144874",
"assets/assets/fortunes/medicine": "2eb04929858e8cc59e5e0fa9568a9488",
"assets/assets/fortunes/people": "d107143ae8469c647164fb1129c6215a",
"assets/assets/fortunes/food": "24e1315462bc364f84d5857c88ac42ff",
"assets/assets/fortunes/humorists": "1833edd96780b64b1e167f1dde8264d0",
"assets/assets/fortunes/platitudes": "555db21bf3abd77359037e00c9e6389d",
"assets/assets/fortunes/cookie": "020795fa462af1b8d004457e5956de39",
"assets/assets/fortunes/songs-poems": "2293484e139547ba34a336b355e83062",
"assets/assets/fortunes/definitions": "89712063e5d2f402956300855d8823b6",
"assets/assets/fortunes/kids": "c9b9bfad4b0c2a114cf2ba27ee39ab62",
"assets/assets/fortunes/fortunes": "c8d6cf8ce6aff1d51b3410d527976eab",
"assets/assets/fortunes/translate-me": "24856a6834a95449acc27956d2606c78",
"assets/assets/fortunes/off/riddles": "35063175534f2dd64dd4e0e0bdc5685e",
"assets/assets/fortunes/off/drugs": "d0ce0a5dcd7b4eee161bd0956c57e13d",
"assets/assets/fortunes/off/ethnic": "305d077b14a179697853a06c4dc924b0",
"assets/assets/fortunes/off/miscellaneous": "3d02c740b020293234cbfad4e1a8dbd8",
"assets/assets/fortunes/off/politics": "a7bf06373f21132dc201380e14130069",
"assets/assets/fortunes/off/songs-poems": "6084028576ae8fe6febea3fa09b6af16",
"assets/assets/fortunes/off/definitions": "09359ba6744a543861b62dc6f522c808"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
