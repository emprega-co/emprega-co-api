# Fluxo de Desenvolvimento

O projeto utiliza um fluxo baseado em Git Flow simplificado.

```
main
│
develop
│
feature/*
bugfix/*
hotfix/*
```

## Fluxo

1. Atualizar a develop

```bash
git checkout develop
git pull origin develop
```

2. Criar uma feature

```bash
git checkout -b feature/nome-da-feature
```

3. Desenvolver

4. Commit

```bash
git commit -m "feat: descrição"
```

5. Push

```bash
git push origin feature/nome-da-feature
```

6. Abrir Pull Request para develop.

Após aprovação, realizar o merge.