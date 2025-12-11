# 🔍 Troubleshooting - Por Que Não Está Salvando

## 1️⃣ PRIMEIRA COISA: Verificar se está Logado

Antes de tudo, **abra a tela de login** e faça login no app!

- Se não estiver logado, verá mensagem: `❌ Você não está autenticado. Faça login primeiro.`
- Isto aparecerá no console com: `👤 [CadastroIncendio] Verificando autenticação - Usuário: NÃO AUTENTICADO`

---

## 2️⃣ Verificar Regras de Firestore

**Isto é a causa mais comum!**

### ✅ Como Verificar

1. Abra: https://console.firebase.google.com/project/fireapp-17168
2. Vá em: **Firestore Database** > **Rules**
3. Veja qual regra está lá

### ❌ Se ver isto:

```firestore
rules_version = '3';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Está bloqueado! Ninguém consegue salvar.**

### ✅ Precisa ser assim (TESTE):

```firestore
rules_version = '3';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Copie, cole e clique "Publicar"**

---

## 3️⃣ Verificar os Logs

Execute no terminal:

```bash
cd /home/rafael/Documentos/FireApp/fire_app
flutter logs -v
```

### 👀 Procure por estas linhas:

```
🔥 [CadastroIncendio] Iniciando salvamento do incêndio...
📍 Localização: LatLng(latitude: -15.xxx, longitude: -48.xxx)
🗺️ Polígono com N pontos: [...]
👤 Usuário ID: xxxxxxxxxxxxx
📤 Enviando para Firestore...
📋 Dados a enviar: {descricao: ..., nivelRisco: ...}
✅ Incêndio salvo com sucesso! ID: xxxxx
```

### ❌ Se ver isto, há erro:

```
📤 Enviando para Firestore...
❌ Erro: PERMISSION_DENIED: Missing or insufficient permissions.
```

**Significa: As regras de Firestore estão bloqueando.**

```
❌ Erro: The user must be authenticated...
```

**Significa: Não está logado no app.**

---

## 4️⃣ Verificar Firestore Console

1. Abra: https://console.firebase.google.com/project/fireapp-17168/firestore/data
2. Procure por coleção chamada **`incendios`**

### ✅ Se ver assim:

```
incendios (collection)
  └─ documento_id_1
     ├─ descricao: "Casa pegando fogo"
     ├─ nivelRisco: "Alto"
     ├─ criadoPor: "xxxxx"
     ├─ criadoEm: timestamp
     └─ areaPoligono: [array]
```

**Está funcionando!**

### ❌ Se não ver a coleção:

- Os dados não estão sendo salvos
- Revise os passos 1-3 acima

---

## 5️⃣ Checklist Completo

- [ ] Estou logado no app
- [ ] Console Firebase mostra projeto: fireapp-17168
- [ ] Firestore Rules estão em modo "permitir reads/writes para autenticados"
- [ ] Console Firebase > Firestore > Rules > "Publicar" foi clicado
- [ ] Executei `flutter clean` && `flutter pub get`
- [ ] Executei `flutter run` novamente
- [ ] Tentei cadastrar novo incêndio
- [ ] Vejo logs começando com: 🔥 🔥 🔥

---

## 6️⃣ Se Ainda Não Funcionar

**Abra o console do navegador e compartilhe comigo:**

```bash
flutter logs -v > logs.txt
```

E procure por:
- Qualquer linha com ❌
- Qualquer linha com "error"
- Qualquer linha com "denied"

---

## 🆘 Rápido - Passo a Passo

1. **Abra o console do Firebase**
2. **Copie esta regra:**

```firestore
rules_version = '3';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. **Cole na aba Rules**
4. **Clique Publicar**
5. **Aguarde confirmação (verde)**
6. **Volte ao app e tente cadastrar**
7. **Procure pelo log `✅ Incêndio salvo com sucesso!`**

Se o log aparecer = **SUCESSO!** ✅
Se não aparecer = Compartilhe o erro que vir nos logs ❌

