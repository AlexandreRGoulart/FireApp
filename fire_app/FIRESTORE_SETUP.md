# 🔥 Setup do Firestore para FireApp

## Problemas Comuns

### 1. Incêndio fica salvando e não aparece sucesso

**Possíveis causas:**
- ❌ Usuário não está autenticado
- ❌ Regras de segurança do Firestore não permitem escrita
- ❌ Erro de conexão com a internet
- ❌ Firebase não está inicializado corretamente

**Solução:**

1. **Verifique se o usuário está autenticado:**
   - Vá em `tela_inicial_screen.dart` ou `login_register_screen.dart`
   - Certifique-se de fazer login antes de usar a app
   - O `IncendioService` valida se `currentUser` existe

2. **Configure as Regras de Segurança do Firestore:**

   Vá para [Firebase Console](https://console.firebase.google.com/) → Seu projeto → Firestore → Regras

   **Para DESENVOLVIMENTO (permite tudo):**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

   **Para PRODUÇÃO (recomendado):**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Coleção de incêndios
       match /incendios/{incendio} {
         // Qualquer usuário autenticado pode ler
         allow read: if request.auth != null;
         
         // Apenas o criador pode atualizar ou deletar
         allow write: if request.auth.uid == resource.data.criadoPor;
         
         // Qualquer usuário autenticado pode criar novo
         allow create: if request.auth != null;
       }
       
       // Outras coleções
       match /shared_locations/{location} {
         allow read: if request.auth != null;
         allow write: if request.auth != null;
       }
     }
   }
   ```

3. **Verificar a Estrutura do Firestore:**

   Após salvar, verifique em:
   - Firebase Console → Firestore → Coleção `incendios`
   - Deve ter documentos com campos:
     - `descricao`: string
     - `nivelRisco`: string
     - `areaPoligono`: array
     - `criadoPor`: string (UID do usuário)
     - `criadoEm`: timestamp

4. **Verificar Logs da App:**

   No console Flutter, procure por:
   - ✅ `✅ Incêndio salvo com sucesso! ID: xxxxx`
   - ❌ `❌ Erro ao salvar incêndio: ...`
   - 🔥 `🔥 Salvando incêndio - Usuário ID: xxxxx`

## Teste Rápido

1. **Faça login** com qualquer email/senha
2. **Vá em "Reportar Incêndio"**
3. **Preencha:**
   - Descrição: "Teste incêndio"
   - Nível de risco: "Alto"
   - Desenhe a área no mapa (clique 3+ pontos)
4. **Clique "Salvar incêndio"**
5. **Verifique:**
   - Console Flutter deve mostrar logs
   - Devem ver SnackBar com sucesso/erro
   - Firestore console deve ter novo documento

## Troubleshooting

| Problema | Solução |
|----------|---------|
| "Usuário não autenticado" | Faça login antes de usar |
| "Permission denied" | Atualize regras de segurança no Firestore |
| Sem resposta (fica salvando) | Verifique conexão internet e logs |
| Incêndio salva mas não aparece na tela | Reinicie o app ou puxe para baixo para recarregar |

## Arquivos Importantes

- `lib/database/incendio_service.dart` - Service com CRUD
- `lib/model/incendio_model.dart` - Modelo de dados
- `lib/screen/cadastro_incendio_screen.dart` - Tela de registro
- `lib/screen/meus_alertas_screen.dart` - Tela de alertas
- `lib/screen/show_location_screen.dart` - Mapa com incêndios

## Próximas Etapas

1. ✅ Testar salvamento e leitura
2. ⏳ Implementar notificações push (Firebase Messaging)
3. ⏳ Adicionar fotos (Firebase Storage)
4. ⏳ Integrar NDVI para detecção automática
