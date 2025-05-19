# Organiza Tarefas

Projeto desenvolvido para o desafio do **Rei do Pitaco**, com foco em usabilidade, clareza de código e entrega de valor real.  
Este app permite criar, visualizar, editar e excluir tarefas, organizando compromissos por dia, semana e mês, com filtros inteligentes por status e período.

---

## Como rodar o projeto localmente

Este projeto é dividido em duas partes:
- **Backend** (Node.js + PostgreSQL)
- **Mobile** (Flutter)

---

### 1. Clonar o repositório

```bash
git clone https://github.com/brun-brito/organiza-tarefas.git
cd organiza-tarefas
```

---

### 2. Configurar o backend

#### Pré-requisitos:
- Node.js instalado
- PostgreSQL local instalado

#### Passos:

```bash
cd backend
npm init -y
npm install express cors dotenv prisma @prisma/client
npx prisma init
```

#### Criar banco local:

```bash
createdb organizador
psql -U organizador
# script para criação de super usuário:
CREATE USER admin WITH PASSWORD '123';
ALTER USER admin WITH SUPERUSER;
\q
```

#### Atualize o `.env` criado com as credenciais corretas:

```
DATABASE_URL="postgresql://admin:123@localhost:5432/organizador?schema=public"
```

#### Instalar dependências e rodar migração:

```bash
npm install
npx prisma migrate dev --name init
```

#### Iniciar servidor:

```bash
node index.js
```

> Se tudo der certo, você verá essa mensagem no console:

![Print console](readme-images/console1.png)

---

#### Prisma Studio:
> Se você deseja acessar os dados do banco em uma interface, rode o comando `npx prisma studio`, e abrirá uma interface parecida com essa:

![Prisma Interface](readme-images/prisma.png)

### 3. Executar o app Flutter

#### Pré-requisitos:
- Flutter instalado de acordo com as instruções em: https://docs.flutter.dev/get-started/install
- Emulador Android ou iOS configurado
- Comando `flutter doctor -v` não deve apresentar nenhum problema

#### Passos:
Abra um novo terminal e rode:
```bash
cd mobile
flutter pub get
flutter run
```

> Se tudo der certo, você verá essa algo assim no console:

![Print console](readme-images/console2.png)

---

### O que o app faz?

- CRUD completo de tarefas
- Marcar como concluída
- Filtrar por status: Todas | Pendentes | Concluídas
- Visualizar por período: Hoje | Semana | Mês
- Navegação inteligente por datas (avançar/voltar)

---

### Tecnologias utilizadas

- Flutter + Dart
- Node.js + Express
- PostgreSQL
- Prisma ORM

---

### Uso de IA

Durante o desenvolvimento, utilizei IA como apoio para:
- Discussão das melhores tecnologias para o projeto;
- Geração dos códigos de acordo com as ideias instruídas por mim, isto é, para ganho de produtividade, gasto a maior parte do tempo estruturando as ideias do projeto e como ele vai ser construído (tecnologias, bibliotecas, telas etc.), do que propriamente escrevendo código (porque a IA já faz isso muito bem), dessa forma, posso ser muito mais produtivo.

---

### Vídeos de utilização do app:
- Criação de tarefa:

![Criando tarefa](readme-images/criando.gif)


---
- Edição de tarefa:
![Editando tarefa](readme-images/editando.gif)


---
- Marcar tarefa concluída:
![Tarefa concluída](readme-images/concluido.gif)


---
- Excluir tarefa:
![Excluindo tarefa](readme-images/excluindo.gif)


---
- Usar filtros:
![Aplicando filtros](readme-images/filtros.gif)
