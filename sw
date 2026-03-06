// BodyLog Service Worker - PWA Offline Support
const CACHE_NAME = ‘bodylog-v1’;
const STATIC_CACHE = [
‘./’,
‘./index.html’,
‘https://fonts.googleapis.com/css2?family=DM+Mono:ital,wght@0,300;0,400;0,500;1,300&family=Syne:wght@400;500;600;700;800&family=Noto+Sans+JP:wght@300;400;500&display=swap’,
‘https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js’,
];

self.addEventListener(‘install’, e => {
e.waitUntil(
caches.open(CACHE_NAME).then(cache => {
return cache.addAll(STATIC_CACHE).catch(err => {
console.warn(‘Cache addAll partial failure:’, err);
});
})
);
self.skipWaiting();
});

self.addEventListener(‘activate’, e => {
e.waitUntil(
caches.keys().then(keys =>
Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
)
);
self.clients.claim();
});

self.addEventListener(‘fetch’, e => {
// Cache-first for static assets, network-first for everything else
if (e.request.method !== ‘GET’) return;

e.respondWith(
caches.match(e.request).then(cached => {
if (cached) return cached;

```
  return fetch(e.request).then(response => {
    if (!response || response.status !== 200) return response;
    // Cache CDN resources
    if (e.request.url.includes('cdn.jsdelivr.net') || e.request.url.includes('fonts.gstatic.com')) {
      const clone = response.clone();
      caches.open(CACHE_NAME).then(cache => cache.put(e.request, clone));
    }
    return response;
  }).catch(() => {
    // Offline fallback
    if (e.request.destination === 'document') {
      return caches.match('./index.html');
    }
  });
})
```

);
});
