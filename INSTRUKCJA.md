# Instrukcja wdrożenia — Magazyn części

Aplikacja składa się z dwóch darmowych elementów:

- **Supabase** — baza danych (produkty, pracownicy, historia wydań) + logowanie administratora
- **GitHub Pages** — darmowy hosting samej strony (pliku `index.html`)

Poniżej krok po kroku, ok. 15-20 minut.

---

## KROK 1 — Załóż projekt w Supabase

1. Wejdź na **https://supabase.com** i załóż darmowe konto (np. przez GitHub).
2. Kliknij **New Project**.
3. Podaj nazwę (np. `magazyn`), ustaw hasło do bazy (zapisz je gdzieś) i region (najlepiej **Central EU / Frankfurt**).
4. Poczekaj ok. 2 minuty, aż projekt się utworzy.

## KROK 2 — Utwórz tabele w bazie

1. W panelu Supabase po lewej wybierz **SQL Editor**.
2. Kliknij **New query**.
3. Wklej całą zawartość pliku **`schema.sql`** (dołączonego do tej wiadomości).
4. Kliknij **Run**. Powinieneś zobaczyć „Success. No rows returned”.

To utworzyło 3 tabele: `products` (baza produktów), `employees` (pracownicy) i `issues` (historia wydań), razem z regułami bezpieczeństwa (RLS) — dzięki nim tylko zalogowany administrator może zmieniać bazę produktów i listę pracowników, a magazyn/mechanicy mogą normalnie skanować i potwierdzać wydania bez logowania.

## KROK 3 — Utwórz konto administratora

1. W panelu Supabase wybierz **Authentication → Users**.
2. Kliknij **Add user → Create new user**.
3. Podaj swój e-mail i hasło (to będzie login do panelu admina w aplikacji).
4. **Ważne:** w **Authentication → Providers → Email** wyłącz opcję „Allow new users to sign up”, żeby nikt obcy nie mógł sobie sam założyć konta admina.

## KROK 4 — Pobierz dane połączenia

1. W panelu Supabase: **Project Settings (ikona koła zębatego) → API**.
2. Skopiuj dwie wartości:
   - **Project URL** (wygląda jak `https://xxxxxxxx.supabase.co`)
   - **anon public** key (długi ciąg znaków w sekcji "Project API keys")

## KROK 5 — Uzupełnij plik index.html

1. Otwórz plik `index.html` w dowolnym edytorze tekstu (np. Notatnik).
2. Znajdź na początku sekcji `<script>` linie:
   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
   ```
3. Podmień wartości na te skopiowane w Kroku 4. Zapisz plik.

> Klucz „anon public” jest z założenia bezpieczny do umieszczenia w kodzie strony — to nie jest hasło administratora. Prawdziwą ochronę zapewniają reguły RLS ustawione w Kroku 2.

## KROK 6 — Wrzuć pliki na GitHub Pages (darmowy hosting)

1. Załóż darmowe konto na **https://github.com**, jeśli jeszcze nie masz.
2. Kliknij **New repository**. Nazwij np. `magazyn`, zaznacz **Public** (GitHub Pages na darmowym koncie wymaga publicznego repozytorium — patrz uwaga niżej), kliknij **Create repository**.
3. W nowym repozytorium kliknij **Add file → Upload files**.
4. Przeciągnij tam **wszystkie pliki**: `index.html`, `manifest.json`, `sw.js`, `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` i kliknij **Commit changes**.
5. Przejdź do **Settings → Pages** (w menu repozytorium po lewej).
6. W sekcji **Build and deployment** wybierz **Source: Deploy from a branch**, **Branch: main**, folder **/ (root)** → **Save**.
7. Po ok. 1 minucie GitHub pokaże adres strony, np.:
   ```
   https://twoja-nazwa.github.io/magazyn/
   ```

> **Uwaga:** jeśli kiedyś ustawisz to repozytorium jako **prywatne**, GitHub Pages automatycznie przestanie działać (błąd 404) — to ograniczenie darmowego planu GitHub. Repozytorium może być publiczne bez obaw: `SUPABASE_ANON_KEY` w kodzie jest bezpieczny do pokazania publicznie, a prawdziwą ochronę danych zapewniają reguły RLS w Supabase.

Ten adres otwierasz zarówno na tablecie w magazynie, jak i na komputerze biurowym — to jest ta sama, wspólna aplikacja i te same dane.

## KROK 6b — Zainstaluj jako aplikację na tablecie

Dzięki temu ikonka pojawi się na ekranie głównym tabletu i po dotknięciu otworzy się na pełnym ekranie —
bez paska adresu i menu przeglądarki, jak zwykła aplikacja.

**Android (Chrome):**
1. Otwórz adres aplikacji w Chrome na tablecie.
2. Dotknij menu (trzy kropki w prawym górnym rogu) → **„Dodaj do ekranu głównego"** lub **„Zainstaluj aplikację"**.
3. Potwierdź — na ekranie głównym pojawi się ikonka „Magazyn".

**iPad (Safari):**
1. Otwórz adres aplikacji w Safari.
2. Dotknij ikonę udostępniania (kwadrat ze strzałką) → **„Dodaj do ekranu początkowego"**.
3. Potwierdź.

Od tej pory pracownicy uruchamiają aplikację dotykając ikonki, tak jak każdą inną apkę na tablecie —
nie muszą wchodzić do przeglądarki ani pamiętać adresu strony.

Dane odświeżają się automatycznie na żywo (gdy tylko ktoś coś zeskanuje na innym urządzeniu), a dodatkowo
**co 5 minut** aplikacja sama pobiera świeże dane z bazy jako zabezpieczenie, na wypadek chwilowej utraty
połączenia.

## KROK 7 — Wejdź do panelu administratora

Panel admina jest **ukryty** na normalnym adresie strony — pracownicy w magazynie go nie zobaczą.
Aby się zalogować, wejdź na swój adres z dopiskiem `?admin=1`, np.:

```
https://twoja-nazwa.github.io/magazyn/?admin=1
```

Warto zapisać ten adres jako zakładkę na komputerze biurowym.

1. Wejdź na powyższy adres, kliknij **Zaloguj jako admin**, podaj e-mail/hasło z Kroku 3.
2. W panelu administratora wgraj **bazę produktów** (plik CSV lub XLSX z kolumnami `kod` i `nazwa`).
3. Dodaj **pracowników**, **linie produkcyjne** i **urządzenia** — to trzy osobne listy, z których na hali wybiera się gotowe pozycje z rozwijanej listy, bez klawiatury ekranowej.
4. W sekcji **„Logo firmy"** wgraj plik PNG/JPG z logo — pojawi się potem w lewym górnym rogu każdego wygenerowanego protokołu PDF.
5. Wgraj **dwie oddzielne bazy produktów** — „Baza produktów — Części" i „Baza produktów — Atramenty i rozpuszczalniki". To właśnie ten podział decyduje, do którego magazynu system przypisze dany kod po zeskanowaniu.

Zwykły adres strony (bez `?admin=1`) pokazuje tylko ekran skanowania i historię — to jest widok dla tabletów w magazynie.

## Dwa magazyny: części oraz atramenty/rozpuszczalniki

Aplikacja obsługuje teraz **jeden wspólny skaner** dla obu magazynów. Po zeskanowaniu kodu system
sprawdza w bazie produktów, do której kategorii należy dany kod, i **automatycznie przełącza tryb**:

- **Części** — wymaga: pracownik + linia/urządzenie (jak dotychczas).
- **Atramenty / rozpuszczalniki** — wymaga: pracownik + data do zużycia + checkbox „zamieszany przed użyciem".

Na ekranie skanowania widać dwa przełączniki na górze („🔧 Części" / „🧴 Atramenty") z licznikiem
pozycji w każdym z nich — można też przełączyć tryb ręcznie, np. przy ręcznym wpisywaniu kodu, którego
jeszcze nie ma w bazie produktów (system domyślnie potraktuje nieznany kod jako „Część", dopóki go nie
dopiszesz do właściwej listy w adminie).

**Ważne:** rozpoznawanie kategorii działa wyłącznie na podstawie tego, do której z dwóch baz produktów
(część / atrament) dany kod został wcześniej wgrany w adminie — sam kod kreskowy (np. EAN-13) nie niesie
takiej informacji sam w sobie.

W historii wydań pojawił się filtr **„Magazyn"** oraz kolumna „Szczegóły", pokazująca albo linię/urządzenie,
albo datę do zużycia i informację o zamieszaniu — zależnie od kategorii wpisu.

**Protokół PDF** generuje teraz **dwa różne dokumenty** w zależności od ustawionego filtra „Magazyn":
- Filtr „Części" (lub brak filtra, gdy widoczne są tylko części) → protokół z nagłówkiem i numerem
  ustawionym w `DOCUMENT_TITLE_PARTS` / `DOCUMENT_NUMBER_PARTS` / `DOCUMENT_APPROVAL_DATE_PARTS`.
- Filtr „Atramenty i rozpuszczalniki" → protokół z `DOCUMENT_TITLE_INKS` / `DOCUMENT_NUMBER_INKS` /
  `DOCUMENT_APPROVAL_DATE_INKS`, z dodatkowymi kolumnami „Data do zużycia" i „Zamieszany".

Ustaw te cztery pary stałych na górze `index.html` na numery i daty zatwierdzone przez kontrolę jakości
dla obu formularzy — analogicznie do tego, co zrobiliście wcześniej dla protokołu części.

Gotowe — aplikacja jest w pełni funkcjonalna i darmowa (Supabase i GitHub Pages mają darmowe plany, które w zupełności wystarczą do takiego zastosowania).

---

## Aktualizacja bazy produktów w przyszłości

Wystarczy zalogować się jako admin na stronie i wgrać nowy plik CSV/XLSX — istniejące kody zostaną zaktualizowane (nowa nazwa), a nowe kody dodane. Nic nie trzeba zmieniać w kodzie ani w Supabase ręcznie.

## Jeśli coś nie działa

- **„Konfiguracja niekompletna”** na stronie → nie uzupełniono `SUPABASE_URL` / `SUPABASE_ANON_KEY` w Kroku 5.
- **Błąd logowania admina** → sprawdź e-mail/hasło z Kroku 3, upewnij się że użytkownik został utworzony w Supabase i ma **potwierdzony e-mail** (przy tworzeniu zaznacz „Auto Confirm User").
- **Import CSV nic nie dodaje** → sprawdź nagłówki kolumn w pliku (`kod`, `nazwa` lub `code`, `name`) — jeśli nazwy są inne, aplikacja weźmie po prostu pierwszą i drugą kolumnę pliku.
- **Nie widać przycisku „Zaloguj jako admin"** → upewnij się, że wchodzisz na adres z `?admin=1` na końcu — na zwykłym adresie ten przycisk jest celowo ukryty.

## Masz już wdrożoną wcześniejszą wersję?

Jeśli konfigurowałeś aplikację wcześniej (przed dodaniem linii/urządzeń), zrób dwie rzeczy:

1. **Uruchom ponownie `schema.sql`** w Supabase SQL Editor — nowa wersja jest bezpieczna do wielokrotnego uruchomienia i doda tylko brakujące tabele (`lines`, `devices`) oraz kolumnę `device`, nic nie usuwając.
2. **Podmień plik `index.html`** na GitHub na nową wersję (w repozytorium: kliknij plik → ikona ołówka „Edit" → wklej nową zawartość → Commit changes), pamiętając o ponownym wpisaniu `SUPABASE_URL` i `SUPABASE_ANON_KEY` na górze pliku.
3. Zaloguj się do panelu (`?admin=1`) i dodaj przynajmniej jedną linię i jedno urządzenie — inaczej pracownicy nie będą mieli czego wybrać z listy.
