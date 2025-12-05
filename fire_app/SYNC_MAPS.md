# 🔥 Sincronização de Mapas - Diagnóstico

## 📊 Arquitetura Atual

```
Tela 1: cadastro_incendio_screen.dart
  ├─ Mapa mini (mostra localização)
  ├─ Desenha polígono (areaPoligono = List<LatLng>)
  └─ Salva no Firestore → IncendioService.salvarIncendio()

Tela 2: show_location_screen.dart (Mapa Principal)
  ├─ Carrega incêndios em tempo real → IncendioService.streamIncendios()
  ├─ Renderiza PolygonLayer com areaPoligono
  ├─ Renderiza MarkerLayer com latitude/longitude
  └─ Atualiza automaticamente quando dados mudam no Firestore
```

## 🔄 Fluxo de Sincronização

```
1. Usuário preenche descrição + nível de risco
2. Usuário desenha polígono (3+ pontos) em adicionar_mapa_screen.dart
3. Polígono é passado para cadastro_incendio_screen.dart
4. Usuário clica "Salvar incêndio"
   ↓
   IncendioModel é criado com:
   - descricao ✅
   - nivelRisco ✅
   - areaPoligono ✅ (List<LatLng>)
   - latitude ✅ (GPS atual)
   - longitude ✅ (GPS atual)
   - criadoEm ✅ (timestamp)
   - criadoPor ✅ (user ID)
   ↓
   Salva no Firestore:
   /incendios/{docId}
   {
     descricao: "...",
     nivelRisco: "...",
     areaPoligono: [
       { latitude: -15.3080, longitude: -49.6050 },
       { latitude: -15.3085, longitude: -49.6055 },
       ...
     ],
     latitude: -15.3082,
     longitude: -49.6048,
     criadoEm: "2025-12-04T...",
     criadoPor: "uid_usuario"
   }
   ↓
   Firestore emit snapshot para todos os listeners
   ↓
   show_location_screen.dart recebe via streamIncendios()
   ↓
   setState() atualiza _incendios list
   ↓
   PolygonLayer renderiza com areaPoligono
   MarkerLayer renderiza com latitude/longitude
   ✅ Incêndio aparece no mapa!
```

## 🔍 Verificação Passo a Passo

### 1️⃣ Verificar Logs no Console

Quando salva:
```
🔥 [CadastroIncendio] Iniciando salvamento do incêndio...
📍 Localização: LatLng(-15.3082, -49.6048)
🗺️ Polígono com 3 pontos: [LatLng(-15.3080, -49.6050), ...]
📝 [CadastroIncendio] Incêndio criado: teste
🔥 [IncendioService] Salvando incêndio - Usuário ID: uid_abc123
✅ [IncendioService] Incêndio salvo com sucesso! ID: doc_xyz789
✅ [CadastroIncendio] Incêndio salvo com ID: doc_xyz789
```

Quando volta para o mapa:
```
📡 [IncendioService] Stream aberto para coleção "incendios"
📊 [IncendioService] Snapshot recebido com 1 documentos
🗺️ [ShowLocationScreen] Iniciando stream de incêndios...
🔥 [ShowLocationScreen] Recebido 1 incêndios
  - teste: 3 pontos, Lat=-15.3082, Lng=-49.6048
```

### 2️⃣ Verificar Firestore Console

1. Firebase Console → Seu Projeto → Firestore Database
2. Clique na coleção `incendios`
3. Procure pelo documento recém criado
4. Verifique se tem:
   - ✅ `areaPoligono` com array de pontos
   - ✅ `latitude` e `longitude` preenchidos
   - ✅ `criadoPor` com seu UID
   - ✅ `criadoEm` com timestamp

### 3️⃣ Verificar Regras de Segurança

```dart
// Deve permitir leitura para usuários autenticados
match /incendios/{document=**} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

## ⚠️ Possíveis Problemas

### Problema: Incêndio salva mas não aparece no mapa

**Checklist:**

- [ ] Logs mostram "✅ Incêndio salvo com sucesso"?
  - NÃO → Erro antes de salvar, veja mensagem de erro
  
- [ ] Firestore console mostra o documento?
  - NÃO → Firestore não recebeu o dado, verifique auth
  
- [ ] `areaPoligono` tem pontos no Firestore?
  - NÃO → Polígono não foi desenhado corretamente
  
- [ ] Logs mostram "🔥 [ShowLocationScreen] Recebido..."?
  - NÃO → Stream não está recebendo dados, verifique regras

- [ ] Polígono aparece no mapa?
  - NÃO → Verifique se `areaPoligono` não está vazio

### Problema: SnackBar mostra "Salvando..." infinitamente

- Verifique se Firestore está respondendo
- Verifique conexão de internet
- Verifique logs de erro

### Problema: Latitude/Longitude vazias

- GPS pode não estar ativo
- Permissão de localização não concedida
- Use valores padrão ou obtenha do centro do mapa

## 🎯 Cenário Ideal

```
1. Você toca "Reportar Incêndio" na tela inicial
   ↓
2. Preenche: "Fogo na mata" + "Alto"
   ↓
3. Clica "Adicionar área no mapa"
   ↓
4. Desenha polígono (3+ pontos)
   ↓
5. Clica "Salvar área"
   ↓
6. Volta para cadastro e clica "Salvar incêndio"
   ↓
7. Vê SnackBar verde "✓ Incêndio registrado com sucesso!"
   ↓
8. Automaticamente volta para o mapa PRINCIPAL
   ↓
9. NO MAPA PRINCIPAL:
   ✅ Polígono vermelho semi-transparente
   ✅ Marcador com ícone de fogo (vermelho)
   ✅ Clica no marcador → Diálogo com detalhes
   ✅ Clica no polígono → Nada (just visual)
```

## 🚀 Próximas Melhorias

- [ ] Zoom automático para novo incêndio
- [ ] Notificação visual quando novo incêndio é adicionado
- [ ] Botão "Recarregar" no mapa
- [ ] Filter por date/risk level
