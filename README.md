# 🔥 Organização das Branches

Para deixar o desenvolvimento do **FireApp**, vamos seguir um padrão de branches bem simples. Nada rígido — só o suficiente para evitar conflitos e facilitar o trabalho.

---

## 🌱 Branches principais

### **`main`**
Nossa base estável.  
Fica o código que já está funcionando certinho.

### **`developer`**
Onde juntamos tudo o que está sendo desenvolvido.  
Antes de algo ir para `main`, ele passa por aqui.

---

## ✨ Features

Sempre que criarmos algo novo (telas, ajustes, funcionalidades…), usamos:

```
feature/nome-da-coisa
```

Exemplos:

```
feature/tela-inicial
feature/tela-login
feature/mapa
```

Essas branches devem ser criadas **a partir da `developer`**, assim todo mundo trabalha na mesma base.

---

## 🚀 Como criar uma nova feature

1. Ir para a developer:
```bash
git checkout developer
git pull
```

2. Criar sua feature:
```bash
git checkout -b feature/nome-da-feature
```

3. Quando terminar:
```bash
git add .
git commit -m "feat: implementa nome-da-feature"
git push origin feature/nome-da-feature
```

Depois disso é só abrir um **Pull Request** para `developer`.

---

## 🤝 Por que usar esse padrão?

Só pra facilitar a vida de todo mundo:
- Menos conflitos de código  
- Todo mundo trabalha sincronizado  
- A `main` sempre fica estável  
- Cada um desenvolve sem impactar o outro  

---

## 😄 Resumindo

- **`main`** → versão estável  
- **`developer`** → integração do desenvolvimento  
- **`feature/**`** → cada funcionalidade separada  

