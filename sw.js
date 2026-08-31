// Minimalny service worker — potrzebny wyłącznie po to, żeby przeglądarka
// pozwoliła "zainstalować" tę stronę jako aplikację na ekranie głównym.
// Celowo nic nie cache'uje, żeby dane (historia, produkty) zawsze były świeże.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => e.waitUntil(self.clients.claim()));
self.addEventListener('fetch', () => {}); // pass-through, wymagane przez kryteria instalowalności
