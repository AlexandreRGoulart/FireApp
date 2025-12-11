# 🔐 Regras de Segurança do Firebase Storage - CRÍTICO

## ⚠️ PROBLEMA IDENTIFICADO

O Firebase Storage **por padrão nega toda escrita**. As regras precisam ser configuradas para permitir uploads de fotos.

## 📋 Passo 1: Acessar o Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Selecione o projeto: **fireapp-17168**
3. Vá em: **Storage** (lado esquerdo)

## 🔧 Passo 2: Configurar Regras para Desenvolvimento

**Clique na aba "Rules" e cole estas regras:**

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Permitir leitura para usuários autenticados
    match /incendios/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## ✅ Passo 3: Publicar as Regras

1. Clique em **"Publicar"** no canto inferior direito
2. Aguarde a confirmação (geralmente 1-2 minutos)
3. A página deve mostrar: "Regras publicadas com sucesso"

## 📊 Buckets Disponíveis

Seu bucket de Storage é: **fireapp-17168.firebasestorage.app**

## 🧪 Teste Manual

Após publicar, tente:
1. Abrir a app
2. Ir para "Cadastro de Incêndio"
3. Tirar uma foto
4. Salvar o incêndio
5. Verificar nos logs se a foto foi salva

## ✅ Sinais de Sucesso

- Log mostra: `✅ Upload concluído`
- Log mostra: `📸 Foto URL obtida: gs://...`
- A foto aparece no mapa quando clicado no incêndio

## ❌ Sinais de Erro

Se vir logs assim, as rules ainda não estão corretas:
- `❌ FirebaseException ao enviar foto`
- `Code: permission-denied`
- `403` ou `404` errors

## 🔒 Regras Seguras para Produção

Quando quiser mais segurança, use:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /incendios/{userId}/{allPaths=**} {
      // Permite ler qualquer foto
      allow read: if request.auth != null;
      
      // Permite escrever apenas suas próprias fotos
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 5 * 1024 * 1024; // Max 5MB
    }
  }
}
```

## 📝 Notas Importantes

- `{userId}` na URL deve ser o UID do Firebase Auth do usuário
- As fotos são salvas em: `gs://fireapp-17168.firebasestorage.app/incendios/{userId}/{timestamp}.jpg`
- Regras levam 1-2 minutos para serem aplicadas globalmente
- Se mudar as rules, pode precisar fazer hot restart no app
