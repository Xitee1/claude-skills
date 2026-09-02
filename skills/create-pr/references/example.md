# Example — filled-in schema (German heading set)

Real PR, rewritten to the schema: a one-method fix in a .NET service that also changed error
semantics. Note that section 2 makes the hidden behavior change visible; the original description
only listed "propagates Graph errors".

---

**Title:** `fix(mdatasvc): tolerate stale app role assignments`

## Warum

MDataSvc wirft auf dev im Minutentakt `KeyNotFoundException` in `GraphHelper.GetUserRoles`, wenn
eine Entra-AppRole-Zuweisung eines Users auf eine Rolle zeigt, die am Service Principal nicht mehr
existiert. Die Rollen dieser Ressource fehlten dem User dann still. Zusätzlich schrieb die parallele
Verarbeitung in eine gemeinsam genutzte `List<string>`.

## Was sich ändert (Vorher → Nachher)

- **Unbekannte AppRoleId**
  - Vorher: `map?[a.AppRoleId!.Value]` wirft `KeyNotFoundException`; die Ressource liefert keine Rollen.
  - Nachher: `TryGetValue`; unbekannte Ids werden übersprungen, gültige Rollen derselben Ressource
    bleiben, eine `LogWarning` pro Ressource mit den betroffenen Ids.
  - Betroffen: `ContactService.GetMeContact` → `/Contacts/Me` (einziger Aufrufer).
- **Ergebnissammlung**
  - Vorher: `Parallel.ForEachAsync` mit `results.AddRange` auf einer geteilten `List<string>` (nicht threadsicher).
  - Nachher: lokale Liste pro Ressource, Zusammenführung nach `Task.WhenAll`. Parallelität unbegrenzt
    statt `ProcessorCount`; bei 1–3 Ressourcen pro User irrelevant.
  - Betroffen: wie oben.
- **Fehlerverhalten bei Graph-Fehlern**
  - Vorher: Mit Microsoft.Graph 5.97 wirft der Client `ODataError`, nicht `ServiceException`; der
    `catch (ServiceException)` war toter Code. Jeder Graph-Fehler landete im `catch (Exception)` und
    ergab eine leere Liste → `/Contacts/Me` antwortete **200 mit `Roles = []`**. Ein Fehler beim
    Laden eines einzelnen Service Principals wurde nur geloggt, die übrigen Ressourcen kamen zurück.
  - Nachher: kein `try/catch` mehr; jeder Graph-Fehler (auch einer von N Service-Principal-Reads)
    propagiert → `MspExceptionHandler` → **500**.
  - Betroffen: Frontend-Bootstrap (`useUserStore.initialize` wirft, Fehler+Retry-UI;
    `permissions.global` fails open ohne Rollen).

## Kompatibilitäts-Altlasten & Workarounds

Keine.

## Designentscheidungen

### Warum propagieren statt pro Ressource abfangen?
Stille leere Rollen sind der schwerer zu findende Fehler als ein sichtbarer 500 mit Retry. Entspricht
der log-and-rethrow-Konvention der übrigen `GraphHelper`-Methoden. Alternative (verworfen):
`catch (ODataError)` pro Ressource mit Warnung → Login bleibt bei Einzelausfällen robust, Rollenliste
kann aber wieder unvollständig sein. (decided without user input)

### Warum `Task.WhenAll` statt `ConcurrentBag`?
Lokale Listen pro Task brauchen keine Synchronisation und erhalten die Reihenfolge innerhalb einer
Ressource. `ConcurrentBag` wäre ebenfalls korrekt, aber unnötig.

## Auswirkungen & Risiken

- Ein transienter Graph-Fehler (429/503) beim Login ist jetzt sichtbar (500 + Retry) statt unsichtbar
  (leere Rechte). Bei längerem Graph-Ausfall kommt vorher wie nachher niemand sinnvoll in die App.
- Kein API-Vertrag, kein Event, kein SDK geändert. Keine Migration.
- Graph-Berechtigung `Application.ReadWrite.All` ist vorhanden; 403 auf Service-Principal-Reads nicht zu erwarten.

## Nicht Teil dieses PRs

- Aufräumen der veralteten Zuweisung des betroffenen dev-Users in Entra (manuell, siehe Issue).
- `Top = 999` ohne Paging bei `AppRoleAssignments` — vorbestehend, unverändert.

## Verifikation

- `GraphHelperTests`: 5/5 (neu: stale role, mehrere Ressourcen, null/empty Ids, Fehlerpropagation ×2)
- MDataSvc-Gesamtsuite: 1284/1284
- Build: 0 Warnungen, 0 Fehler; `dotnet format --verify-no-changes`: bestanden

## Manuell prüfen vor Merge

- [ ] Login mit einem User, der eine veraltete Zuweisung hat: Rollen der übrigen Apps sind vorhanden, Warning im Log.
- [ ] Login mit mehreren zugewiesenen Apps: alle Rollen kommen an, keine Duplikate.
- [ ] Graph nicht erreichbar (z. B. falsche ClientId lokal): Bootstrap zeigt Fehler + Retry statt leerer Rechte.

Fixes #520


---

# What section 3 must catch — a real near-miss

A feature PR's first description contained, under "API und Messaging":

> - Neuer additiver Endpunkt `POST /Import/contacts/mode-aware` …
> - Der bestehende Endpunkt und sein Consumer bleiben vorerst erhalten, damit bereits vorhandene
>   Nachrichten abgearbeitet werden und alte Frontends während des Rollouts weiter funktionieren.

and a design decision "Warum ein additiver Endpunkt?" built on the assumption that frontend and
backend roll out non-atomically. In that repo everything on `main` is built and deployed together,
so the assumption was false: the legacy endpoint, its consumer and a "separate cleanup later" were
never wanted. The user only caught it because the description mentioned it. The PR was reworked to
switch the existing endpoint directly and delete the old path.

In the schema this belongs in **Kompatibilitäts-Altlasten & Workarounds**, marked
`(decided without user input)`, with the assumption spelled out and the direct alternative named —
so the reviewer can veto it before reading a single line of code.
