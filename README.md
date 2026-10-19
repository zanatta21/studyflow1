# StudyFlow

Aplicativo de organização dos estudos — **armazenamento local** (sem Firebase).

**Projeto AV1 — 2º Ano Técnico em Informática**

## Banco de dados

Usa **SharedPreferences** (equivalente ao localStorage do navegador):
- Login e cadastro salvos no celular
- Disciplinas, tarefas, provas e metas salvos no celular
- Não precisa de internet nem conta Google

> O documento da AV1 indica Firebase, mas permite outras soluções se o professor autorizar.

## Funcionalidades

- Progresso (dashboard)
- Disciplinas (CRUD)
- Tarefas (CRUD)
- Provas (CRUD)
- Calendário
- Metas (CRUD)

## Como rodar no Android Studio

1. File → Open → pasta `studyflow`
2. Terminal: `flutter pub get`
3. Inicie um emulador
4. Clique em Run ▶

Ver também: `COMO_RODAR_ANDROID_STUDIO.md`

## Tecnologias

Flutter, Dart, Provider, SharedPreferences, table_calendar, percent_indicator, Google Fonts
