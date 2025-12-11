# 🔐 Regras de Segurança do Firestore - CRÍTICO

## ⚠️ PROBLEMA IDENTIFICADO

O Firebase pode estar **bloqueando a escrita** por falta de regras de segurança. Siga este guia para configurar.

## 📋 Passo 1: Verificar Regras no Console Firebase

1. Acesse: https://console.firebase.google.com/
2. Selecione o projeto: **fireapp-17168**
3. Vá em: **Firestore Database** > **Rules**

## 🔧 Passo 2: Configurar Regras para Desenvolvimento

**Cole estas regras (TEMPORÁRIO - apenas para testes):**

```firestore
rules_version = '3';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir leitura e escrita para usuários autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## ✅ Passo 3: Publicar as Regras

1. Clique em **"Publicar"** no console
2. Aguarde a confirmação

## 🔒 Passo 4: Regras para Produção (depois)

```firestore
rules_version = '3';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários só podem ler/escrever seus próprios incêndios
    match /incendios/{docId} {
      allow create: if request.auth != null && 
                       request.resource.data.criadoPor == request.auth.uid;
      allow read: if request.auth != null;
      allow update, delete: if request.auth != null && 
                              resource.data.criadoPor == request.auth.uid;
    }
  }
}
```

## 🧪 Teste Rápido Após Configurar

1. Limpe os logs: `flutter logs --clear`
2. Execute: `flutter run -v`
3. Cadastre um novo incêndio
4. Procure nos logs por:
   - ✅ `✅ Incêndio salvo com sucesso! ID:`
   - ❌ Se ver erro de permissão, as regras não estão corretas

## 📱 Logs Esperados

```
🔥 Salvando incêndio - Usuário ID: xxxxx
📤 Enviando para Firestore...
📋 Dados a enviar: {...}
✅ Incêndio salvo com sucesso! ID: yyyyyyy
```

## 🚨 Se Ainda Não Funcionar

1. **Verifique no Console Firebase:**
   - Collection `incendios` foi criada?
   - Documentos estão sendo inseridos?

2. **Verifique no app:**
   ```bash
   flutter logs -v | grep "❌\|✅\|🔥"
   ```

3. **Se vir erro de autenticação:**
   - Faça login primeiro na app
   - Verifique se `request.auth != null` no Firestore

4. **Se vir erro de estrutura:**
   - Pode ser problema no modelo de dados
   - Verifique o arquivo `FIRESTORE_SCHEMA.md`

