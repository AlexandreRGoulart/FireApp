# 🔍 Diagnóstico - Mapa não mostra localização e incêndios

## ⚠️ Sintomas

- ✅ Incêndio salva com sucesso (vê mensagem "Incêndio registrado com sucesso!")
- ❌ Na tela principal, mapa não mostra:
  - Sua localização atual (marcador azul/vermelho)
  - Incêndios cadastrados (marcadores de fogo)
  - Polígonos da área afetada

## 🔧 Passos para Diagnosticar

### 1️⃣ Verificar Localização

Execute no terminal:
```bash
flutter logs -v | grep "📍\|🎯\|Localização"
```

Procure por:
- `📍 [ShowLocationScreen] Iniciando localização...` - tela iniciou
- `✅ [ShowLocationScreen] Permissões concedidas` - permissões ok
- `📍 [ShowLocationScreen] Localização recebida: -15.xxx, -48.xxx` - capturando local
- `🎯 [ShowLocationScreen] Localização definida:` - setando no mapa

**Se não vir estes logs:**
- ❌ Permissões de localização não foram concedidas
- ❌ Serviço de localização do celular está desligado
- ❌ O app não tem permissão de localização

**Solução:**
- Vá em Configurações > Aplicativos > FireApp > Permissões > Localização
- Ative "Permitir o tempo todo" ou "Permitir apenas enquanto usa o app"
- Reinicie o app

### 2️⃣ Verificar Stream de Incêndios

Execute:
```bash
flutter logs -v | grep "🗺️\|🔥\|📊\|Erro"
```

Procure por:
- `🗺️ [ShowLocationScreen] Iniciando stream de incêndios...` - stream iniciou
- `🔥 [ShowLocationScreen] Recebido X incêndios` - dados chegaram (X > 0)
- `❌ [ShowLocationScreen] Erro ao carregar incêndios:` - erro no stream

**Se vir X = 0:**
- Dados não estão no Realtime Database
- Verifique se salvou corretamente (vide passo 3)

**Se vir erro:**
- Cole a mensagem de erro exata

### 3️⃣ Verificar Realtime Database

1) Console Firebase → Realtime Database
2) Procure pelo nó `incendios`
3) Expanda e veja se há documentos

Se não há nada:
- Salvamento falhou silenciosamente
- Verifique logs do cadastro: `🔥 Salvando incêndio` até `✅ Incêndio salvo`

### 4️⃣ Verificar Regras do RTDB

Realtime Database → Rules:

```json
{
  "rules": {
    "incendios": {
      ".read": "auth != null",
      ".write": "auth != null",
      ".indexOn": ["criadoEm", "criadoPor"]
    }
  }
}
```

Se as regras não estão assim, **Publique**.

### 5️⃣ Teste Rápido - Passo a Passo

1) Abra o app logado
2) Aguarde 3-5 segundos (mapa carregando)
3) Procure pelo logs com:
   ```bash
   flutter logs -v | grep "🗺️\|📍\|🔥"
   ```
4) Compartilhe comigo o que vir (ou não vir)

## 📝 Checklist

- [ ] Localização do celular está ativada (GPS, WiFi ou dados móveis)
- [ ] FireApp tem permissão de localização ("Permitir o tempo todo")
- [ ] Firebase está mostrando dados em Realtime Database > incendios
- [ ] Regras do RTDB permitem leitura (`.read: "auth != null"`)
- [ ] Estou logado no app
- [ ] Logs mostram `📍 Localização recebida:` 
- [ ] Logs mostram `🔥 [ShowLocationScreen] Recebido X incêndios` com X > 0

## 🆘 Se Tudo Acima Estiver OK e Ainda Não Funcionar

Compartilhe:
1) Logs completos do app (5-10 segundos de execução)
2) Print do console Realtime Database mostrando dados
3) Mensagem de erro exata (se houver)

Comandos úteis:
```bash
# Coletar logs de 10 segundos
flutter logs -v > diagnostico.txt

# Depois procure por "erro" ou "error"
grep -i "erro\|error" diagnostico.txt

# Ou veja só os emojis
grep "🔥\|📍\|🗺️\|❌\|✅" diagnostico.txt
```

