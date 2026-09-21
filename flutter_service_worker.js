'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "ef2ab5f793fd79f2bc0949b1dd519431",
"assets/AssetManifest.bin.json": "5d1a96c9ed1e7ff9ada325f96c07cba8",
"assets/assets/2014/5e-SRD-Ability-Scores.json": "0ecfb75bcc686044f47fba6779a18053",
"assets/assets/2014/5e-SRD-Alignments.json": "09625895dc271ded2e41219363ed2ade",
"assets/assets/2014/5e-SRD-Backgrounds.json": "b9cd078a00524ad43516b29be330f888",
"assets/assets/2014/5e-SRD-Classes.json": "2b6d72ecad22798c6496a86517c4df10",
"assets/assets/2014/5e-SRD-Conditions.json": "a8a6b23dac226894db6e8c886eb2ff05",
"assets/assets/2014/5e-SRD-Damage-Types.json": "0de87433c05541b5785d2cbfe60ff2c9",
"assets/assets/2014/5e-SRD-Equipment-Categories.json": "76643242b09a7695ee5234682b63e6a3",
"assets/assets/2014/5e-SRD-Equipment.json": "d2960a640cd5ab0b2ff75d0ab7ccaffe",
"assets/assets/2014/5e-SRD-Feats.json": "e669d59acfabeb2aa8a2c18af188af62",
"assets/assets/2014/5e-SRD-Features.json": "8474c5b26563679e0c241e2c632b73d0",
"assets/assets/2014/5e-SRD-Languages.json": "92e83f472f527ba71f783d60b44c3b20",
"assets/assets/2014/5e-SRD-Levels.json": "daf4d32c0cd3177caf0bc146034cab0d",
"assets/assets/2014/5e-SRD-Magic-Items.json": "1db572d06946f2c80ef7b01db736ab92",
"assets/assets/2014/5e-SRD-Magic-Schools.json": "2256e9b785f7c36cde1ad235329905c2",
"assets/assets/2014/5e-SRD-Monsters.json": "112c605a1183f2600117a1fafb1396c8",
"assets/assets/2014/5e-SRD-Proficiencies.json": "b46d6426ff8a7a2b12633686a94a36ae",
"assets/assets/2014/5e-SRD-Races.json": "d42cd0eb73277bf09f2605b8a77e1e49",
"assets/assets/2014/5e-SRD-Rule-Sections.json": "792cd85cb6b3adbbfdae0333cc658a49",
"assets/assets/2014/5e-SRD-Rules.json": "1b5710d87dfd86b273802a7931cbc9a2",
"assets/assets/2014/5e-SRD-Skills.json": "98c55b9b846215c3f3ca68d9f39890af",
"assets/assets/2014/5e-SRD-Spells.json": "a9d82557f00db158be1ce2d41693a22b",
"assets/assets/2014/5e-SRD-Subclasses.json": "8b73cf55e4be6f0882507fccfd7cc30a",
"assets/assets/2014/5e-SRD-Subraces.json": "e90c058d508ae245cddf5b458243cc6c",
"assets/assets/2014/5e-SRD-Traits.json": "f227bb4c606627af7daff8925f693c6f",
"assets/assets/2014/5e-SRD-Weapon-Properties.json": "7e49bd00f9ff66c2ca36321c62a438c9",
"assets/assets/2024/5e-SRD-Ability-Scores.json": "e61b7175370dd6a93b21500efbc889cf",
"assets/assets/2024/5e-SRD-Alignments.json": "c1a5f421cb066886937f7141629178f2",
"assets/assets/2024/5e-SRD-Backgrounds.json": "3bd0e0ba0991b15588ceec2031f4a719",
"assets/assets/2024/5e-SRD-Classes.json": "1e54f03d7975c4c1ecaa59647066dcb0",
"assets/assets/2024/5e-SRD-Conditions.json": "fca5d6aa151f2460bc9be627d78befdf",
"assets/assets/2024/5e-SRD-Damage-Types.json": "2c007a3ccb0cc290d53e6a4c10c724c0",
"assets/assets/2024/5e-SRD-Equipment-Categories.json": "0f2e347d3bd90b2b3e1b30fc8d81c7e6",
"assets/assets/2024/5e-SRD-Equipment.json": "3b2d880698b2889d59e3d8802207e05f",
"assets/assets/2024/5e-SRD-Feats.json": "5e596b4f4bc2fce9614fa1f98535dc73",
"assets/assets/2024/5e-SRD-Features.json": "0c890d09ff497189be4fb3acf5415efe",
"assets/assets/2024/5e-SRD-Languages.json": "c11587a7c99f9d3c18de84d3e7d475e8",
"assets/assets/2024/5e-SRD-Levels.json": "a7b31194de20c4e0e757802d0ec1c1ae",
"assets/assets/2024/5e-SRD-Magic-Items.json": "cc32fbf2b8322c62b3fd7694f17f1fd6",
"assets/assets/2024/5e-SRD-Magic-Schools.json": "0182ba1ca298550100ddb43ba86bee1d",
"assets/assets/2024/5e-SRD-Monsters.json": "cdf5a7f0e78276a972e723f55e368e89",
"assets/assets/2024/5e-SRD-Poisons.json": "243a422a7c7838a1e5b6bf8bce0bc1bb",
"assets/assets/2024/5e-SRD-Proficiencies.json": "9c0dd1c9ed765659f5b1a20b4cf2714b",
"assets/assets/2024/5e-SRD-Skills.json": "00a773bea79be64efbd73edf3da1d6fe",
"assets/assets/2024/5e-SRD-Species.json": "ec5a7f3c9cf22a5d6168082d29ca7cdf",
"assets/assets/2024/5e-SRD-Spells.json": "a9d82557f00db158be1ce2d41693a22b",
"assets/assets/2024/5e-SRD-Subclasses.json": "0e1868996174b62463c63c49ea86b942",
"assets/assets/2024/5e-SRD-Subspecies.json": "dd9f83526956cec2808fccbc14bbac56",
"assets/assets/2024/5e-SRD-Traits.json": "11e053f4725dd4e176fa55d16c09bf6a",
"assets/assets/2024/5e-SRD-Weapon-Mastery-Properties.json": "1016973f581b69ae6cddc763a3be74d8",
"assets/assets/2024/5e-SRD-Weapon-Properties.json": "c082c64a238fc030deae25e48383d917",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "bd4bfff5a57f9ab4f15f2739b2b99415",
"assets/NOTICES": "21aa88e2b5aa32e17a79ad3611795272",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "018ac0af9510b1c2b49ed8ec5be103b9",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "f419c7b13b4f9741c86c95d2e4515749",
"/": "f419c7b13b4f9741c86c95d2e4515749",
"main.dart.js": "d0be256501f5078960171e97766e0779",
"manifest.json": "9ff7bdf61d7cafaf89cce2e9f2df7ccd",
"version.json": "f7a415a73e148dc70b28ff22f330ae66"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
