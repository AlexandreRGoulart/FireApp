# 📋 Checklist de Teste - Firestore Persistence

## ✅ Pré-requisitos

- [ ] Estar na branch `feature/firestore-persistence`
- [ ] Ter executado `flutter pub get`
- [ ] Ter compilado a app (sem erros)

## 🧪 Teste Completo

### 1️⃣ **Autenticação**
```
1. Abra a app
2. Clique em "Login/Cadastro"
3. Registre uma nova conta OU faça login
4. Vá para "Menu Rápido" (hamburger)
5. ✅ Verifique: Console mostra "Usuário autenticado"
```

### 2️⃣ **Reportar Incêndio**
```
1. No "Menu Rápido", clique em "Reportar Incêndio"
2. Preencha:
   - Descrição: "Teste - Fogo na mata"
   - Nível de risco: "Alto"
3. Clique "Adicionar área no mapa"
4. Clique 3 pontos no mapa para desenhar polígono
5. Clique "Salvar área"
6. Volte para tela anterior
7. Clique "Salvar incêndio"
```

### 3️⃣ **Verificar Logs da App**

No console do Flutter, procure por:

```
✅ SUCESSO:
🔥 Salvando incêndio - Usuário ID: [uid]
📝 Incêndio criado: Teste - Fogo na mata
✅ Incêndio salvo com sucesso! ID: [docId]

❌ ERRO (se houver):
❌ Erro ao salvar incêndio: [mensagem]
```

**Copie a mensagem de erro e me envie se der problema!**

### 4️⃣ **Verificar Firebase Console**

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Selecione projeto "FireApp"
3. Vá em "Firestore Database"
4. Vá em aba "Data"
5. Procure pela coleção `incendios`
6. Verifique se tem um novo documento com:
   - ✅ `descricao`: "Teste - Fogo na mata"
   - ✅ `nivelRisco`: "Alto"
   - ✅ `areaPoligono`: array com 3+ pontos
   - ✅ `criadoPor`: [seu uid]
   - ✅ `criadoEm`: timestamp

### 5️⃣ **Visualizar no Mapa**

1. No "Menu Rápido", clique em "Mapa"
2. Verifique:
   - 🔥 Marcador vermelho (se nível = Alto) no local do incêndio
   - 🗺️ Polígono vermelho semi-transparente
   - 📍 Sua localização atual

### 6️⃣ **Visualizar em Meus Alertas**

1. No "Menu Rápido", clique em "Meus Alertas"
2. Verifique:
   - 🔥 Card com seu incêndio
   - ✅ Mostra descrição
   - ✅ Mostra nível de risco
   - ✅ Data/hora

3. Clique no card
4. Verifique:
   - ✅ Diálogo com descrição completa
   - ✅ Nível de risco com cor
   - ✅ Coordenadas e data
   - ✅ Botão "Traçar Rota"

## 🐛 Se Não Funcionar

### Problema 1: SnackBar mostra "Usuário não autenticado"
**Solução:**
- Certifique-se de fazer LOGIN antes
- Verifique no Firebase se usuário existe em Authentication

### Problema 2: SnackBar mostra "Permission denied"
**Solução:**
- Vá em Firebase Console → Firestore → Regras
- Cole as regras de desenvolvimento (veja `FIRESTORE_SETUP.md`)
- Salve

### Problema 3: Incêndio não aparece após salvar
**Solução:**
- Verifique console por erros (✅ ou ❌)
- Reabra a app ou puxe para baixo em "Meus Alertas"
- Verifique se está logado com a mesma conta

### Problema 4: Mapa não mostra marcador
**Solução:**
- Verifique se `latitude` e `longitude` foram salvos no Firestore
- Certifique-se de que GPS está ativo
- Reinicie a app

## 📊 Dados Esperados

Após registrar um incêndio, no Firestore deve ter:

```json
{
  "descricao": "Teste - Fogo na mata",
  "nivelRisco": "Alto",
  "areaPoligono": [
    {
      "latitude": -15.3080,
      "longitude": -49.6050
    },
    {
      "latitude": -15.3085,
      "longitude": -49.6055
    },
    {
      "latitude": -15.3075,
      "longitude": -49.6045
    }
  ],
  "criadoEm": "2025-12-04T10:30:00.000",
  "criadoPor": "uid_do_usuario",
  "latitude": -15.3082,
  "longitude": -49.6048,
  "fotoUrl": null
}
```

## ✨ Parabéns!

Se passou em todos os testes, o Firestore está funcionando! 🎉

**Próximo passo:** Branch `feature/realtime-alerts` para notificações push
