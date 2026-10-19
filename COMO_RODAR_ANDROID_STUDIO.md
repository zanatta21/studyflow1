# Como rodar o StudyFlow no Android Studio (SEM Firebase)

Este app usa **armazenamento local** (SharedPreferences — equivalente ao localStorage).
Não precisa de Firebase, Gmail nem internet para funcionar.

## Passo a passo

### 1. Abrir o projeto
1. Android Studio → **File → Open**
2. Selecione a pasta **studyflow** (tem `pubspec.yaml` e pasta `lib`)
3. OK e espere indexar

### 2. Instalar dependências
No terminal do Android Studio (View → Tool Windows → Terminal):

```bash
flutter pub get
```

### 3. Emulador
1. **Tools → Device Manager**
2. Crie/inicie um emulador (Pixel, API 33+)

### 4. Rodar
Clique no **▶ Run** (ou Shift + F10)

## Usar o app
1. **Cadastre-se** com qualquer e-mail e senha (ficam só no celular)
2. Crie **Disciplinas**
3. Use Tarefas, Provas, Metas, Calendário e Progresso

## Observação para a AV1
O PDF permite "outras soluções de persistência" se o professor autorizar.
Este app usa SharedPreferences (dados no aparelho) no lugar do Firebase.
Mencione isso no README e na apresentação.
